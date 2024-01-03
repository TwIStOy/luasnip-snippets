local ls = require("luasnip")
local snippet = require("luasnip-snippets.nodes").construct_snippet
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
local fmta = require("luasnip.extras.fmt").fmta
local f = ls.function_node
local t = ls.text_node

local function cpo_snippet()
  local function cpo_func_to_namespace(name)
    -- try to convert name from pascal case to snake case
    if name:match("^[A-Z]") then
      -- is pascal case now, change to snake case
      name = name:gsub("(%u+)(%u%l)", "%1_%2")
      name = name:gsub("([a-z0-9])([A-Z])", "%1_%2")
      name = name:gsub("-", "_")
      name = name:lower()
    end
    return ("%s_fn"):format(name)
  end
  return snippet {
    "cpo",
    name = "(cpo) Customization point object",
    dscr = "Expands to a customization point object",
    mode = "bw",
    nodes = fmta(
      [[
      namespace <ns_name> {
      struct Fn {
        template<<typename T, bool _noexcept = true>>
        decltype(auto) operator()(T&& value) const noexcept(_noexcept) {
          <cursor>
        }
      };
      }  // namespace <ns_name>
      inline constexpr <ns_name>::Fn <name>{};
      ]],
      {
        name = i(1, "function name"),
        ns_name = f(function(args)
          return cpo_func_to_namespace(args[1][1])
        end, { 1 }),
        cursor = i(0),
      }
    ),
  }
end

---@param trig string
---@param func string
local function ranges_views_snippet(trig, func)
  return snippet {
    trig,
    name = ("(%s) %s"):format(trig, func:gsub("^%l", string.upper)),
    dscr = ("Expands to %s view"):format(func),
    nodes = fmta(
      [[
      | <namespace>::views::<func>([&](auto&& value) {
        <body>
      })
      ]],
      {
        namespace = c(1, {
          t("ranges"),
          t("std"),
        }, { desc = "library" }),
        body = i(0),
        func = t(func),
      }
    ),
  }
end

return {
  cpo_snippet,

  ranges_views_snippet("|trans", "transform"),
  ranges_views_snippet("|filter", "filter"),
}
