local Cond = require("luasnip-snippets.utils.cond")

local function line_begin_cond(line_to_cursor, matched_trigger, _)
  if matched_trigger == nil or line_to_cursor == nil then
    return false
  end
  return line_to_cursor:sub(1, -(#matched_trigger + 1)):match("^%s*$")
end

local function line_begin_show_maker(trig)
  local function line_begin_show(line_to_cursor)
    if line_to_cursor == nil then
      return false
    end
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local trigger = line:sub(1, col):match("%S+$")
    if #trigger > #trig then
      return false
    end
    return trigger == trig:sub(1, #trigger)
  end
  return line_begin_show
end

---@param trig string
---@return LSSnippets.ConditionObject
local function at_line_begin(trig)
  return Cond.make_condition(line_begin_cond, line_begin_show_maker(trig))
end

return {
  at_line_begin = at_line_begin,
}
