local ls = require("luasnip")
local snippet = require("luasnip-snippets.nodes").construct_snippet
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
local word_snippet = require("luasnip-snippets.nodes").word_expand
local fmta = require("luasnip.extras.fmt").fmta
local f = ls.function_node
local t = ls.text_node
local CommonCond = require("luasnip-snippets.utils.common_cond")

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

---@param bits number
---@param unsigned boolean
local function int_type_snippet(bits, unsigned)
  local prefix = unsigned and "u" or ""
  local trig = (unsigned and "u" or "i") .. bits
  local expand = ("%sint%s_t"):format(prefix, bits)
  return snippet {
    trig,
    name = ("(%s) %s"):format(trig, expand),
    desc = ("Expands to %s"):format(expand),
    mode = "wA",
    nodes = {
      t(expand),
    },
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

local all_lines_before_are_all_comments =
  CommonCond.generate_all_lines_before_match_cond {
    "^%s*//.*$",
    "^%s*$",
  }

return {
  cpo_snippet,

  ranges_views_snippet("|trans", "transform"),
  ranges_views_snippet("|filter", "filter"),

  -- progma once
  snippet {
    "once",
    name = "(once) #Progma once",
    dscr = "Expands to progma once with comments",
    mode = "bwA",
    cond = all_lines_before_are_all_comments,
    nodes = {
      t { "#pragma once  // NOLINT(build/header_guard)", "" },
    },
  },

  -- fast int types
  int_type_snippet(8, true),
  int_type_snippet(8, false),
  int_type_snippet(16, true),
  int_type_snippet(16, false),
  int_type_snippet(32, true),
  int_type_snippet(32, false),
  int_type_snippet(64, true),
  int_type_snippet(64, false),
}
