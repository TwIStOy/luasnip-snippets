local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local i = require("luasnip-snippets.nodes").insert_node

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

local indent_query = [[
[
  (identifier)
  (field_identifier)
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
  expr_tsp(
    ".cbe",
    "?.cbegin(), ?.cend()",
    "Completes an expr with both cbegin() and cend()"
  ),
  expr_tsp(".mv", "std::move(?)"),
  expr_tsp(".fwd", "std::forward<decltype(?)>(?)"),
  expr_tsp(".val", "std::declval<?>()"),
  expr_tsp(".dt", "decltype(?)"),
  expr_tsp(".uu", "(void)?"),
  expr_tsp(".single", "ranges::views::single(?)"),
  expr_tsp(".await", "co_await ?"),

  tsp.treesitter_postfix({
    trig = ".ts",
    name = "(.ts) Toggle style",
    dscr = "Toggle previous indent's style",
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = indent_query,
      query_lang = "cpp",
    },
  }, {
    f(function(_, parent)
      -- switch name style from snake to pascal or vice versa
      -- name must be a oneline identifier
      local name = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      if name:match("^[A-Z]") then
        -- is pascal case now, change to snake case
        name = name:gsub("(%u+)(%u%l)", "%1_%2")
        name = name:gsub("([a-z0-9])([A-Z])", "%1_%2")
        name = name:gsub("-", "_")
        return name:lower()
      else
        -- is snake case now, change to pascal case
        return name
          :gsub("_(%l)", function(s)
            return s:upper()
          end)
          :gsub("^%l", string.upper)
          :gsub("_$", "")
      end
    end, {}),
  }),

  tsp.treesitter_postfix(
    {
      trig = ".sc",
      name = "(.sc) static_cast<TYPE>(?)",
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

  tsp.treesitter_postfix(
    {
      trig = ".in",
      name = "(.in) if (...find)",
      dscr = "Expands to an if-expr to find an element in map-like object",
      wordTrig = false,
      reparseBuffer = "live",
      matchTSNode = {
        query = expr_query,
        query_lang = "cpp",
      },
    },
    fmta(
      [[
      if (auto it = <expr>.find(<key>); it != <expr>.end()) {
        <cursor>
      }
      ]],
      {
        cursor = i(0),
        key = i(1, "Key"),
        expr = f(function(_, parent)
          return Utils.replace_all(parent.snippet.env.LS_TSMATCH, "%s")
        end, {}),
      }
    )
  ),
}
