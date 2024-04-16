---@type luasnip-snippets.nodes
local Nodes = require("luasnip-snippets.nodes")
---@type luasnip-snippets.config
local Config = require("luasnip-snippets.config")
---@type luasnip-snippets.utils.cond
local Cond = require("luasnip-snippets.utils.cond")
---@type luasnip-snippets.utils.treesitter
local UtilsTS = require("luasnip-snippets.utils.treesitter")
---@type luasnip-snippets.utils
local Utils = require("luasnip-snippets.utils")

local fmt = require("luasnip.extras.fmt").fmt
local i = require("luasnip-snippets.nodes").insert_node
local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")

---@param opts LSSnippets.SnippetOptions
local function snippet(opts)
  local cond = Config.get("snippet.lua.cond")
  if cond then
    local cond_obj = Cond.make_condition(cond, cond)
    local previous_cond = opts.cond
    if previous_cond ~= nil then
      opts.cond = previous_cond + cond_obj
    else
      opts.cond = cond_obj
    end
  end
  return Nodes.construct_snippet(opts)
end

local index_expression_query = [[
[
  (dot_index_expression)
  (bracket_index_expression)
] @prefix
]]

local index_expression_matcher = UtilsTS.make_type_matcher {
  "dot_index_expression",
  "bracket_index_expression",
}

---@param context LSSnippets.ProcessMatchesContext
---@param previous any
local function inject_matches(context, previous)
  local fields = {}
  local node = context.prefix_node
  while node ~= nil and index_expression_matcher[node:type()] == 1 do
    local field = context.ts_parser:get_node_text(node:field("field")[1])
    if node:type() == "dot_index_expression" then
      fields[#fields + 1] = ('"%s"'):format(field)
    else
      fields[#fields + 1] = field
    end
    node = node:field("table")[1]
  end
  fields[#fields + 1] = context.ts_parser:get_node_text(node)
  Utils.reverse_list(fields)

  previous = vim.tbl_deep_extend("force", previous, {
    env_override = {
      INDEX_FIELDS = fields,
    },
  })

  return previous
end

return {
  snippet {
    "ifn",
    name = "(ifn) vim.F.if_nil",
    dscr = "Wraps an expression in vim.F.if_nil",
    mode = "w",
    nodes = fmt("vim.F.if_nil({}, {})", {
      i(1, "expr", { desc = "Expression" }),
      i(2, "{}", { desc = "Default value" }),
    }),
  },

  UtilsTS.treesitter_postfix({
    trig = ".tget",
    name = "(.tget) vim.tbl_get(...)",
    dscr = "Expands index_expression to vim.tbl_get syntax",
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = index_expression_query,
      query_lang = "lua",
    },
    injectMatches = inject_matches,
  }, {
    f(function(_, parent)
      local fields = parent.snippet.env.INDEX_FIELDS
      return ("vim.tbl_get(%s)"):format(table.concat(fields, ", "))
    end, {}),
  }),
}
