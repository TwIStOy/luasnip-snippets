local ls = require("luasnip")
local f = ls.function_node
local snippet = require("luasnip-snippets.nodes").construct_snippet
local fmta = require("luasnip.extras.fmt").fmta
local extras = require("luasnip.extras")
local rep = extras.rep
local i = require("luasnip-snippets.nodes").insert_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")

return {
  snippet {
    "pvf",
    name = "(pvf) public abstract function",
    dscr = "Expands to public abstract function declaration",
    mode = "bw",
    nodes = fmta(
      [[
      public abstract <name>(<args>): <retType>;
      ]],
      {
        name = i(1, "name", { desc = "Function Name" }),
        args = i(2, "", { desc = "Function Arguments" }),
        retType = i(3, "void", { desc = "Return Type" }),
      }
    ),
  },
}
