---@param idx number
---@param placeholder? string
---@param opts? table
local function insert_node(idx, placeholder, opts)
  local ls = require("luasnip")
  if idx == 0 then
    return ls.insert_node(idx)
  end
  opts = opts or {}
  local extra_opts = {
    node_ext_opts = {
      active = {
        virt_text = {
          {
            " " .. idx .. ": " .. (opts.desc or placeholder or "insert"),
            "Comment",
          },
        },
      },
    },
  }
  opts = vim.tbl_extend("keep", opts, extra_opts)
  return ls.insert_node(idx, placeholder, opts)
end

---@param idx number
---@param choices table
---@param opts? table
local function choice_node(idx, choices, opts)
  local ls = require("luasnip")
  opts = opts or {}
  local extra_opts = {
    node_ext_opts = {
      active = {
        virt_text = {
          { " " .. idx .. ": " .. (opts.desc or "choice"), "Comment" },
        },
      },
    },
  }
  opts = vim.tbl_extend("keep", opts, extra_opts)
  return ls.choice_node(idx, choices, opts)
end

---@alias LSSnippets.TrigMatcher fun(line_to_cursor: string, trigger: string): string, table
---@alias LSSnippets.CustomTrigEngine fun(trigger: string): LSSnippets.TrigMatcher
---@alias LSSnippets.TrigEngine "plain"|"pattern"|"ecma"|"vim"|LSSnippets.CustomTrigEngine

---@class LSSnippets.SnippetOptions
---@field [1] string Trigger
---@field name string? Snippet name
---@field dscr string? Snippet description
---@field mode string? Snippet mode, "w" for word trigger, "h" for hidden, "A" for autosnippet, "b" for line begin, "r" for regex pattern
---@field engine LSSnippets.TrigEngine? Snippet trigger engine. If "r" in mode, defaults to "pattern".
---@field hidden boolean? Hidden from completion, If "h" in mode, defaults to true.
---@field nodes LuaSnip.Node[] Expansion nodes
---@field priority number? Snippet priority
---@field cond LSSnippets.ConditionObject? Condition object, including condition and show_condition
---@field resolveExpandParams nil|fun(snippet: LuaSnip.Snippet, line_to_cursor: string, matched_trigger: string, captures: table): table Function to decide whether the snippet can be expanded or not.
---@field opts table? Other options

---@param opts LSSnippets.SnippetOptions
local function construct_snippet(opts)
  local CommonCond = require("luasnip-snippets.utils.common_cond")
  local ls = require("luasnip")

  local trig = opts[1]
  local name = vim.F.if_nil(opts.name, trig)
  local dscr = vim.F.if_nil(opts.dscr, "Snippet: " .. name)
  local mode = vim.F.if_nil(opts.mode, "")
  local wordTrig = mode:match("w") ~= nil
  local trigEngine = vim.F.if_nil(opts.engine, "plain")
  if mode:match("r") ~= nil and opts.engine == nil then
    trigEngine = "pattern"
  end
  local hidden = vim.F.if_nil(opts.hidden, mode:match("h") ~= nil)
  local snippetType = mode:match("A") ~= nil and "autosnippet" or "snippet"
  local nodes = opts.nodes
  local priority = opts.priority or nil
  local cond = opts.cond or nil
  if mode:match("b") ~= nil then
    local line_begin = CommonCond.at_line_begin(trig)
    cond = cond and (cond + line_begin) or line_begin
  end
  local trig_arg = {
    trig = trig,
    name = name,
    dscr = dscr,
    wordTrig = wordTrig,
    trigEngine = trigEngine,
    hidden = hidden,
    priority = priority,
    snippetType = snippetType,
    condition = cond and cond.condition,
    show_condition = cond and cond.show_condition,
    resolveExpandParams = opts.resolveExpandParams,
  }
  return ls.s(trig_arg, nodes, opts.opts)
end

---Construct a snippet for simple expansion. (word) -> (expand)
---@param word string
---@param expand string
---@param mode? string
local function word_expand(word, expand, mode)
  local ls = require("luasnip")

  mode = mode or "w"
  if mode:match("w") == nil then
    mode = mode .. "w"
  end
  return construct_snippet {
    word,
    name = ("(%s) %s"):format(word, expand),
    dscr = ("Quickly expands %s to %s"):format(word, expand),
    mode = mode,
    nodes = ls.text_node(expand),
  }
end

---@class luasnip-snippets.nodes
local M = {
  insert_node = insert_node,
  choice_node = choice_node,
  construct_snippet = construct_snippet,
  word_expand = word_expand,
}

return M
