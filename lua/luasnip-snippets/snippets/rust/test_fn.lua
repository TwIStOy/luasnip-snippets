local UtilsTS = require("luasnip-snippets.utils.treesitter")
local Config = require("luasnip-snippets.config")
local UtilsTbl = require("luasnip-snippets.utils.tbl")
local ls = require("luasnip")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node

---@param left string[]
---@param right string[]
---@param sep string
---@return string[]
local function dot_concat(left, right, sep)
  local ret = {}

  for _, l in ipairs(left) do
    for _, r in ipairs(right) do
      ret[#ret + 1] = l .. sep .. r
    end
  end

  return ret
end

---@param node TSNode?
---@return string[]
local function flat_scoped_use_list(source, node)
  if node == nil then
    return {}
  end
  if node:type() ~= "scoped_use_list" then
    return {
      vim.treesitter.get_node_text(node, source),
    }
  end

  local path_nodes = node:field("path")
  if #path_nodes == 0 then
    return {}
  end

  local paths = {}
  for _, path_node in ipairs(path_nodes) do
    vim.list_extend(paths, flat_scoped_use_list(source, path_node))
  end

  local items = {}
  local name_nodes = node:field("name")
  for _, name_node in ipairs(name_nodes) do
    vim.list_extend(items, flat_scoped_use_list(source, name_node))
  end
  local list_nodes = node:field("list")
  local allow_list = {
    scoped_use_list = 1,
    use_wildcard = 1,
    identifier = 1,
  }
  for _, list_node in ipairs(list_nodes) do
    for child in list_node:iter_children() do
      if allow_list[child:type()] == 1 then
        vim.list_extend(items, flat_scoped_use_list(source, child))
      end
    end
  end

  return dot_concat(paths, items, "::")
end

local function inject_expanding_environment(_, _, match, captures)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()

  return UtilsTS.invoke_after_reparse_buffer(
    buf,
    match,
    function(parser, source)
      local pos = {
        row - 1,
        col - #match,
      }
      local node = parser:named_node_for_range {
        pos[1],
        pos[2],
        pos[1],
        pos[2],
      }

      local ret = {
        trigger = match,
        capture = captures,
        env_override = {
          IMPL_ITEM_START = UtilsTS.start_pos(
            UtilsTS.find_first_parent(node, { "impl_item" })
          ),
          FUNCTION_ITEM_START = UtilsTS.start_pos(
            UtilsTS.find_first_parent(node, { "function_item" })
          ),
          CLOSURE_EXPRESSION_START = UtilsTS.start_pos(
            UtilsTS.find_first_parent(node, { "closure_expression" })
          ),
        },
      }

      ---@type TSNode?
      local mod_item = UtilsTS.find_first_parent(node, { "mod_item" })
      if mod_item ~= nil then
        ret.env_override["MOD_ITEM_START"] =
          UtilsTS.start_pos(UtilsTS.find_first_parent(node, { "mod_item" }))
        local name_node = mod_item:field("name")[1]
        if name_node ~= nil then
          ret.env_override["MOD_ITEM_NAME"] =
            vim.treesitter.get_node_text(name_node, source)
        end
        local prev = mod_item:prev_sibling()
        local attributes = {}
        -- try to fild
        while true do
          if prev == nil then
            break
          end
          if
            prev:type() == "line_comment" or prev:type() == "block_comment"
          then
          -- skip this
          elseif prev:type() == "attribute_item" then
            attributes[#attributes + 1] =
              vim.treesitter.get_node_text(prev, source)
          else
            break
          end
          prev = prev:prev_sibling()
        end
        ret.env_override["ATTRIBUTES_ITEMS"] = attributes

        if Config.get("snippet.rust.rstest_support") == true then
          -- check if this mod contains `use rstest::rstest;`
          local use_list = {}
          for _, body in ipairs(mod_item:field("body")) do
            for child in body:iter_children() do
              if child:type() == "use_declaration" then
                local nodes = child:field("argument")
                for _, use_node in ipairs(nodes) do
                  local node_type = use_node:type()
                  if node_type == "scoped_use_list" then
                    vim.list_extend(
                      use_list,
                      flat_scoped_use_list(source, use_node)
                    )
                  elseif node_type == "scoped_identifier" then
                    use_list[#use_list + 1] =
                      vim.treesitter.get_node_text(use_node, source)
                  end
                end
              end
            end
          end
          ret.env_override["USE_LIST"] = use_list
        end
      end

      vim.api.nvim_win_set_cursor(0, { row, col })
      return ret
    end
  )
end

return {
  ls.s(
    {
      trig = "tfn",
      wordTrig = true,
      name = "(tfn) Test function definition",
      resolveExpandParams = inject_expanding_environment,
    },
    d(1, function(_, parent)
      local env = parent.env
      local in_test_cfg = false
      if env["ATTRIBUTES_ITEMS"] ~= nil then
        for _, v in ipairs(env["ATTRIBUTES_ITEMS"]) do
          if v == "#[cfg(test)]" then
            in_test_cfg = true
            break
          end
        end
      end

      if in_test_cfg and env.MOD_ITEM_NAME == "tests" then
        local test_fn_attrs = {
          t("#[test]"),
          t("#[tokio::test]"),
        }

        if Config.get("snippet.rust.rstest_support") == true then
          local use_list = env["USE_LIST"] or {}
          if vim.list_contains(use_list, "rstest::rstest") then
            test_fn_attrs[#test_fn_attrs + 1] = t("#[rstest]")
          elseif vim.list_contains(use_list, "rstest::*") then
            test_fn_attrs[#test_fn_attrs + 1] = t("#[rstest]")
          end
        end

        -- function item
        return sn(
          nil,
          fmta(
            [[
            <attr>
            <modifier>fn test_<name>() {
              <body>
            }
            ]],
            {
              modifier = f(function(args, _)
                if vim.tbl_get(args, 1, 1) == "#[tokio::test]" then
                  return "async "
                else
                  return ""
                end
              end, { 2 }),
              name = i(1, "new_fn", { desc = "function name" }),
              attr = c(2, test_fn_attrs, { desc = "function attributes" }),
              body = i(0),
            }
          )
        )
      else
        -- function item
        return sn(
          nil,
          fmta(
            [[
            <modifier><visible>fn <name>(<args>) {
              <body>
            }
            ]],
            {
              modifier = c(1, {
                t(""),
                t("async "),
              }, { desc = "function modifier" }),
              visible = c(2, {
                t(""),
                t("pub "),
                t("pub(crate) "),
                t("pub(super) "),
              }, { desc = "visibility" }),
              name = i(3, "new_fn", { desc = "function name" }),
              args = i(4, "args", { desc = "function arguments" }),
              body = i(0),
            }
          )
        )
      end
    end, {})
  ),
}
