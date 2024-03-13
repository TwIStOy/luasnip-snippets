local UtilsTS = require("luasnip-snippets.utils.treesitter")
local ls = require("luasnip")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node

local function inject_expanding_environment(_, _, match, captures)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()

  return UtilsTS.invoke_after_reparse_buffer(buf, match, function(parser, _)
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

    vim.api.nvim_win_set_cursor(0, { row, col })
    return ret
  end)
end

---@class LSSnippets.Rust.Fn.Env
---@field IMPL_ITEM_START? { [1]: number, [2]: number }
---@field FUNCTION_ITEM_START? { [1]: number, [2]: number }
---@field CLOSURE_EXPRESSION_START? { [1]: number, [2]: number }

return {
  ls.s(
    {
      trig = "fn",
      wordTrig = true,
      name = "(fn) Function-Definition/Lambda",
      resolveExpandParams = inject_expanding_environment,
    },
    d(1, function(_, parent)
      local env = parent.env
      if
        env.FUNCTION_ITEM_START ~= nil or env.CLOSURE_EXPRESSION_START ~= nil
      then
        -- closure expression
        return sn(
          nil,
          fmta(
            [[
            <modifier>|<args>| {
              <body>
            }
            ]],
            {
              modifier = c(1, {
                t(""),
                t("async "),
                t("move "),
              }, { desc = "function modifier" }),
              args = i(2, "args"),
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
