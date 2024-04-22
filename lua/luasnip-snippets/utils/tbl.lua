---@class luasnip-snippets.utils.tbl
local M = {}

function M.list_contains(t, value)
  for _, v in ipairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

return M
