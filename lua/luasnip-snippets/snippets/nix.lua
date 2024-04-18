local ls = require("luasnip")
local f = ls.function_node
local snippet = require("luasnip-snippets.nodes").construct_snippet
local fmta = require("luasnip.extras.fmt").fmta
local extras = require("luasnip.extras")
local rep = extras.rep
local i = require("luasnip-snippets.nodes").insert_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")
---@type luasnip-snippets.utils.treesitter
local UtilsTS = require("luasnip-snippets.utils.treesitter")

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

local bind_query = [[
[
((binding
  expression: (_) @expr
)) 
] @prefix
]]

---@param context LSSnippets.ProcessMatchesContext
---@param previous any
local function inject_bind_matches(context, previous)
  vim.print("???")
  local node = context.prefix_node
  local attr_path = node:field("attrpath")[1]
  local attrs_nodes = attr_path:field("attr")
  local attrs = {}

  for _, attr in ipairs(attrs_nodes) do
    local attr_text = context.ts_parser:get_node_text(attr)
    attrs[#attrs + 1] = attr_text
  end

  previous = vim.tbl_deep_extend("force", previous, {
    env_override = {
      ATTRS = attrs,
    },
  })

  return previous
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
        module = i(1, "module", { desc = "Module name" }),
        module_r = rep(1),
      }
    ),
  },

  identifier_tsp(
    ".on",
    "? = { enable = true; };",
    "Completes an identifier with an enable option"
  ),

  UtilsTS.treesitter_postfix({
    trig = ".split",
    name = "(.split) foo.bar = xxx; -> foo = { bar = xxx; };",
    dscr = "Split a dot expression into full attrset declaration",
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = bind_query,
      query_lang = "nix",
    },
    injectMatches = inject_bind_matches,
  }, {
    f(function(_, parent)
      vim.print(parent.snippet.env)
      local attrs = parent.snippet.env.ATTRS
      local expr = table.concat(parent.snippet.env.LS_TSCAPTURE_EXPR, "\n")
      Utils.reverse_list(attrs)

      local generate_bindings = function(first, attr, previous)
        if first then
          return ("%s = %s;"):format(attr, previous)
        else
          return ("%s = { %s };"):format(attr, previous)
        end
      end

      for j, attr in ipairs(attrs) do
        expr = generate_bindings(j == 1, attr, expr)
      end

      return expr
    end, {}),
  }),
}
