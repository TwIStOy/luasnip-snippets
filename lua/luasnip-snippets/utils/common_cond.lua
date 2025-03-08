local Cond = require("luasnip-snippets.utils.cond")
local Utils = require("luasnip-snippets.utils")

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
    if trigger == nil then
      return false
    end
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

local function generate_all_lines_before_match_cond(pattern)
  if type(pattern) == "string" then
    pattern = { pattern }
  end

  local function condition()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.api.nvim_buf_get_lines(0, 0, row - 1, false)
    for _, line in ipairs(lines) do
      local match = false
      for _, p in ipairs(pattern) do
        if line:match(p) then
          match = true
          break
        end
      end
      if not match then
        return false
      end
    end
    return true
  end
  return Cond.make_condition(condition, condition)
end

local function has_select_raw_fn(_, _, _)
  return Utils.get_buf_var(0, "LUASNIP_SELECT_RAW") ~= nil
end
local has_select_raw = Cond.make_condition(has_select_raw_fn, has_select_raw_fn)

return {
  at_line_begin = at_line_begin,
  generate_all_lines_before_match_cond = generate_all_lines_before_match_cond,
  has_select_raw = has_select_raw,
}
