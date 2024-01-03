local M = {}

---Replace all occurences of %s in template with match.
---@param match string|string[]
---@param template string
---@return string[]
function M.replace_all(match, template)
  ---@type string
  local match_str = ""
  if type(match) == "table" then
    match_str = table.concat(match, "\n")
  else
    match_str = match
  end

  local ret = template:gsub("%%s", match_str)
  local ret_lines = vim.split(ret, "\n", {
    trimempty = false,
  })

  return ret_lines
end

---Load and concat snippets.
---@param base string
---@param snippets string[]
---@return LuaSnip.Snippet[]
function M.concat_snippets(base, snippets)
  local ret = {}
  for _, snippet in ipairs(snippets) do
    local snippet_module = require(base .. "." .. snippet)
    if type(snippet_module) == "function" then
      snippet_module = snippet_module()
    end
    vim.list_extend(ret, snippet_module)
  end
  return ret
end

return M
