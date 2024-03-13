local UtilsTS = require("luasnip-snippets.utils.treesitter")
local ls = require("luasnip")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node

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
              attr = c(2, {
                t("#[test]"),
                t("#[tokio::test]"),
              }, { desc = "function attributes" }),
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
