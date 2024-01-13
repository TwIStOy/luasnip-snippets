local M = {}

---@alias SnippetOrBuilder LuaSnip.Snippet|fun():SnippetOrBuilder

---Register snippets to luasnip.
---@param ft string filetype
---@param snippets SnippetOrBuilder[]
local function add_snippets(ft, snippets)
  local ls = require("luasnip")
  local ret = {}
  for _, snippet in ipairs(snippets) do
    if type(snippet) == "function" then
      snippet = snippet()
    end
    ret[#ret + 1] = snippet
  end
  ls.add_snippets(ft, ret)
end

---Load snippets from ft module.
---@param ft string
---@return SnippetOrBuilder[]
local function load_snippets(ft)
  local snippets = require("luasnip-snippets.snippets." .. ft)
  if type(snippets) == "function" then
    snippets = snippets()
  end
  return snippets
end

---Load and register snippets.
---@param fts string[]
local function load_and_add_snippet(fts)
  for _, ft in ipairs(fts) do
    local snippets = load_snippets(ft)
    add_snippets(ft, snippets)
  end
end

---@param opts? LSSnippets.Config
function M.setup(opts)
  local Config = require("luasnip-snippets.config")
  Config.setup(opts)

  -- register snippets
  load_and_add_snippet {
    "cpp",
    "rust",
    "lua",
    "dart",
    "all",
  }
end

return M
