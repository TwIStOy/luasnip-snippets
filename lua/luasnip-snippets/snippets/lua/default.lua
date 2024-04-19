local snippet = require("luasnip-snippets.nodes").construct_snippet
local fmt = require("luasnip.extras.fmt").fmt
local i = require("luasnip-snippets.nodes").insert_node
local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")
local rep = require("luasnip.extras").rep

local function last_lua_module_section(args)
  local text = args[1][1] or ""
  local split = vim.split(text, ".", { plain = true })

  local options = {}
  for len = 0, #split - 1 do
    local node =
      ls.t(table.concat(vim.list_slice(split, #split - len, #split), "_"))
    table.insert(options, node)
  end

  return ls.sn(nil, {
    ls.c(1, options),
  })
end

local expr_query = [[
[
  (function_call)
  (identifier)
  (expression_list)
  (dot_index_expression)
  (bracket_index_expression)
] @prefix
]]

return {
  snippet {
    "fn",
    name = "(fn) function",
    dscr = "Expands to function definition",
    mode = "w",
    nodes = fmt(
      [[
          function {}({})
            {}
          end
        ]],
      {
        i(1, "function name", { desc = "Function Name" }),
        i(2, "arguments", { desc = "Function Arguments" }),
        i(0),
      }
    ),
  },

  snippet {
    "req",
    name = "require(...)",
    dscr = "Require statement",
    mode = "wb",
    nodes = fmt([[local {} = require("{}")]], {
      ls.d(2, last_lua_module_section, { 1 }),
      i(1, "module"),
    }),
  },

  snippet {
    '#i',
    name = "require(...)",
    dscr = "Expands to require statement with type annotation",
    mode = "bwA",
    nodes = fmt(
      [[
      ---@type {}
      local {} = require("{}")
      ]],
      {
        rep(1),
        f(function(args)
          local module_name = args[1][1]
          local parts = vim.split(module_name, ".", {
            plain = true,
            trimempty = true,
          })
          module_name = parts[#parts]
          parts = vim.split(module_name, "/", {
            plain = true,
            trimempty = true,
          })
          module_name = parts[#parts]
          return module_name:gsub("^%l", string.upper)
        end, { 1 }),
        i(1, "module"),
      }
    ),
  },

  tsp.treesitter_postfix(
    {
      trig = ".ipairs",
      name = "(.ipairs) for in ipairs(...)",
      dscr = "Expands expression to for in ipairs(...) do ... end",
      wordTrig = false,
      reparseBuffer = "live",
      matchTSNode = {
        query = expr_query,
        query_lang = "lua",
      },
    },
    fmt(
      [[
        for i, value in ipairs({}) do
          {}
        end
        ]],
      {
        f(function(_, parent)
          local match = parent.snippet.env.LS_TSMATCH
          return match
        end, {}),
        i(0),
      }
    )
  ),

  tsp.treesitter_postfix(
    {
      trig = ".pairs",
      name = "(.pairs) for in pairs(...)",
      dscr = "Expands expression to for in pairs(...) do ... end",
      wordTrig = false,
      reparseBuffer = "live",
      matchTSNode = {
        query = expr_query,
        query_lang = "lua",
      },
    },
    fmt(
      [[
        for key, value in pairs({}) do
          {}
        end
        ]],
      {
        f(function(_, parent)
          local match = parent.snippet.env.LS_TSMATCH
          return match
        end, {}),
        i(0),
      }
    )
  ),

  tsp.treesitter_postfix(
    {
      trig = ".isnil",
      name = "(.isnil) if ... == nil",
      dscr = "Expands expression to if ... == nil then ... end",
      wordTrig = false,
      reparseBuffer = "live",
      matchTSNode = {
        query = expr_query,
        query_lang = "lua",
      },
    },
    fmt(
      [[
        if {} == nil then
          {}
        end
        ]],
      {
        f(function(_, parent)
          local match = parent.snippet.env.LS_TSMATCH
          return match
        end, {}),
        i(0, "return"),
      }
    )
  ),
}
