local ls = require("luasnip")
local snippet = require("luasnip-snippets.nodes").construct_snippet
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
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

---@param shortcut string
---@return string?
local function quick_type(shortcut)
  --   v = std::vector, 1
  --   i = int32_t, 0
  --   s = std::string, 0
  --   u = uint32_t, 0
  --   m = absl::flat_hash_map, 2
  --   t = std::tuple, *
  ---@param s string
  ---@return string?, string?
  local function expect_typename(s)
    local first, rest = s:match("^(%l)(.*)$")
    if first == nil then
      return nil, nil
    end
    if first == "v" then
      local typename, sub_rest = expect_typename(rest)
      if typename == nil then
        return "std::vector", rest
      else
        return ("std::vector<%s>"):format(typename), sub_rest
      end
    elseif first == "i" then
      return "int32_t", rest
    elseif first == "s" then
      return "std::string", rest
    elseif first == "u" then
      return "uint32_t", rest
    elseif first == "m" then
      local key_type, key_rest = expect_typename(rest)
      if key_type == nil or key_rest == nil then
        return "absl::flat_hash_map", rest
      end
      local value_type, value_rest = expect_typename(key_rest)
      if value_type == nil or value_rest == nil then
        return "absl::flat_hash_map", rest
      end
      return ("absl::flat_hash_map<%s, %s>"):format(key_type, value_type),
        value_rest
    elseif first == "t" then
      local parameters = {}
      while #rest > 0 do
        local typename, sub_rest = expect_typename(rest)
        if typename == nil or sub_rest == nil then
          if #parameters == 0 then
            return "std::tuple", rest
          end
          return ("std::tuple<%s>"):format(table.concat(parameters, ", ")), rest
        end
        parameters[#parameters + 1] = typename
        rest = sub_rest
      end
      return ("std::tuple<%s>"):format(table.concat(parameters, ", ")), rest
    end
  end

  local result, rest = expect_typename(shortcut)
  if rest and #rest > 0 then
    print(("After QET eval, rest not empty: %s"):format(rest))
  end
  return result
end

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

  -- include short cuts
  snippet {
    '#"',
    name = 'include ""',
    dscr = "#include with quotes",
    mode = "bA",
    nodes = {
      t('#include "'),
      i(1, "header"),
      t('"'),
    },
  },
  snippet {
    "#<",
    name = "include <>",
    dscr = "#include with <>",
    mode = "bA",
    nodes = {
      t("#include <"),
      i(1, "header"),
      t(">"),
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

  -- quick expand, expand stl types
  --   v = std::vector
  --   i = int32_t
  --   s = std::string
  --   u = uint32_t
  --   m = absl::flat_hash_map
  --   t = std::tuple
  ls.s({
    trig = "t(%l+)!",
    wordTrig = true,
    regTrig = true,
    snippetType = "autosnippet",
    name = "(t) Quick types",
    desc = "Expands to a type",
  }, {
    f(function(_, snip)
      local shortcut = snip.captures[1]
      return quick_type(shortcut)
    end),
  }),

  snippet {
    "ns%s+(%S+)",
    name = "namespace",
    dscr = "namespace",
    mode = "br",
    nodes = fmta(
      [[
      namespace <name> {
      <body>
      }  // namespace <name>
      ]],
      {
        body = i(0),
        name = f(function(_, snip)
          local parts = vim.split(snip.captures[1], "::", {
            plain = true,
            trimempty = true,
          })
          local names = {}
          for _, part in ipairs(parts) do
            local nest_parts = vim.split(part, ".", {
              plain = true,
              trimempty = true,
            })
            vim.list_extend(names, nest_parts)
          end
          return table.concat(names, "::")
        end),
      }
    ),
  },
}
