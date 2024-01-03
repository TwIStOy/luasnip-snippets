local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")
local fmt = require("luasnip.extras.fmt").fmt
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
local t = ls.text_node

local expr_query = [[
[
  (call_expression)
  (identifier)
  (template_function)
  (subscript_expression)
  (field_expression)
  (user_defined_literal)
] @prefix
]]

---@param trig string
---@param expand string
---@param dscr string?
local function expr_tsp(trig, expand, dscr)
  local name = ("(%s) %s"):format(trig, expand)
  if dscr == nil then
    dscr = ("Wraps an expression with %s"):format(expand)
  else
    dscr = dscr:format(expand)
  end
  local replaced = expand:gsub("?", "%%s")

  return tsp.treesitter_postfix({
    trig = trig,
    name = name,
    dscr = dscr,
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = expr_query,
      query_lang = "cpp",
    },
  }, {
    f(function(_, parent)
      return Utils.replace_all(parent.snippet.env.LS_TSMATCH, replaced)
    end, {}),
  })
end

return {
  expr_tsp(
    ".be",
    "?.begin(), ?.end()",
    "Completes an expr with both begin() and end()"
  ),
  expr_tsp(".mv", "std::move(?)"),
  expr_tsp(".fwd", "std::forward<decltype(?)>(?)"),
  expr_tsp(".val", "std::declval<?>()"),
  expr_tsp(".dt", "decltype(?)"),
  tsp.treesitter_postfix(
    {
      trig = ".sc",
      name = "static_cast<TYPE>(?)",
      dscr = "Wraps an expression with static_cast<TYPE>(?)",
      wordTrig = false,
      reparseBuffer = "live",
      matchTSNode = {
        query = expr_query,
        query_lang = "cpp",
      },
    },
    fmt(
      [[
      static_cast<{body}>({expr}){end}
      ]],
      {
        body = i(1),
        expr = f(function(_, parent)
          return Utils.replace_all(parent.snippet.env.LS_TSMATCH, "%s")
        end, {}),
        ["end"] = i(0),
      }
    )
  ),
}
