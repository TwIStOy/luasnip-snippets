local ls = require("luasnip")
local f = ls.function_node
local snippet = require("luasnip-snippets.nodes").construct_snippet
local fmta = require("luasnip.extras.fmt").fmta
local extras = require("luasnip.extras")
local rep = extras.rep
local i = require("luasnip-snippets.nodes").insert_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")

local identifier_query = [[
[
  (identifier)
] @prefix
]]

local function identifier_tsp(trig, expand, dscr)
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
      query = identifier_query,
      query_lang = "nix",
    },
  }, {
    f(function(_, parent)
      return Utils.replace_all(parent.snippet.env.LS_TSMATCH, replaced)
    end, {}),
  })
end

return {
  snippet {
    "@module",
    name = "(@module) ...",
    dscr = "Expands to a common module skeleton",
    mode = "bw",
    nodes = fmta(
      [[
      {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.<module>;
      in {
        options.<module_r> = {
          enable = lib.mkEnableOption "Enable module <module_r>";
        };

        config = lib.mkIf cfg.enable {
        };
      }
      ]],
      {
        module = i(1, "module", { dscr = "Module name" }),
        module_r = rep(1),
      }
    ),
  },

  identifier_tsp(
    ".on",
    "? = { enable = true; };",
    "Completes an identifier with an enable option"
  ),
}
