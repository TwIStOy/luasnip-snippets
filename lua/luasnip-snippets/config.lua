---@class LSSnippets.Config.User
---@field name? string
---@field email? string

---@class LSSnippets.Config.Snippet.Lua
---@field vim_snippet? boolean
---@field cond? fun():boolean

---@class LSSnippets.Config.Snippet
---@field lua LSSnippets.Config.Snippet.Lua

---@class LSSnippets.Config
---@field copyright_header? string
---@field user? LSSnippets.Config.User
---@field snippet? LSSnippets.Config.Snippet
local config = {}

---@param opts? LSSnippets.Config
local function setup(opts)
  opts = opts or {}
  config = vim.tbl_extend("force", config, opts)
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

---@class luasnip-snippets.config
local M = {
  setup = setup,
  get = get,
}

return M
