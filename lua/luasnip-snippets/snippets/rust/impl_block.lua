local UtilsTS = require("luasnip-snippets.utils.treesitter")
local ls = require("luasnip")
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node

local function require_impl_block(_, _, match, captures)
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

    if
      ret.env_override.IMPL_ITEM_START ~= nil
      and ret.env_override.FUNCTION_ITEM_START == nil
      and ret.env_override.CLOSURE_EXPRESSION_START == nil
    then
      return ret
    end

    return nil
  end)
end

return {
  ls.s(
    {
      trig = "pm",
      wordTrig = true,
      name = "(pm) pub method",
      resolveExpandParams = require_impl_block,
    },
    fmta(
      [[
      pub fn <name>(<_self>) {
        <body>
      }
      ]],
      {
        body = i(0),
        name = i(1, "new_fn", { desc = "function name" }),
        _self = c(2, {
          t("&self"),
          t("&mut self"),
          t("self"),
        }, { desc = "self" }),
      }
    )
  ),
}
