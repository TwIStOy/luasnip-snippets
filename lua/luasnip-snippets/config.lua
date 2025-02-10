---@class LSSnippets.Config.User
---@field name? string
---@field email? string

---@class LSSnippets.Config.Snippet.Lua
---@field vim_snippet? boolean
---@field cond? fun():boolean

---@class LSSnippets.Config.Snippet.Cpp.QuickType
---@field extra_trig? LSSnippets.Config.Snippet.Cpp.QuickType.Shortcut[]

---@class LSSnippets.Config.Snippet.Cpp.QuickType.Shortcut
---@field trig string One character trigger. Supports lowercase letters only.
---@field params number Number of template parameters.
---@field template string Template string.

---@class LSSnippets.Config.Snippet.Cpp
---@field quick_type? LSSnippets.Config.Snippet.Cpp.QuickType
---@field qt? boolean Enable Qt related snippets.

---@class LSSnippets.Config.Snippet.Rust
---@field rstest_support? boolean

---@alias LSSnippets.Config.Snippet.DisableSnippets string[]
---@alias LSSnippets.SupportLangs 'cpp'|'dart'|'lua'|'rust'|'nix'|'typescript'|'*'

---@class LSSnippets.Config.Snippet
---@field lua? LSSnippets.Config.Snippet.Lua
---@field cpp? LSSnippets.Config.Snippet.Cpp
---@field rust? LSSnippets.Config.Snippet.Rust

---@class LSSnippets.Config
---@field copyright_header? string
---@field user? LSSnippets.Config.User
---@field snippet? LSSnippets.Config.Snippet
---@field disable_auto_expansion? table<LSSnippets.SupportLangs, LSSnippets.Config.Snippet.DisableSnippets>
---@field disable_langs? LSSnippets.SupportLangs[]
local config = {}

---@param opts? LSSnippets.Config
local function setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)
end

---@return any
local function get(key)
  local keys = vim.split(key, ".", {
    plain = true,
    trimempty = true,
  })
  local value = config
  for _, k in ipairs(keys) do
    value = value[k]
    if value == nil then
      return nil
    end
  end
  return value
end

---return bool
local function auto_expansion_disabled(lang, trig)
  ---@type luasnip-snippets.utils.tbl
  local Tbl = require("luasnip-snippets.utils.tbl")
  local disabled_trigs =
    vim.F.if_nil(vim.tbl_get(config, "disable_auto_expansion", lang), {})
  return Tbl.list_contains(disabled_trigs, trig)
end

---@class luasnip-snippets.config
local M = {
  setup = setup,
  get = get,
  auto_expansion_disabled = auto_expansion_disabled,
}

return M
