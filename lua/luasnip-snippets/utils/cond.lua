---@class luasnip-snippets.utils.cond
local M = {}

---@class LSSnippets.ConditionFuncObject
---@operator unm: LSSnippets.ConditionFuncObject
---@operator add(LSSnippets.ConditionFuncObject): LSSnippets.ConditionFuncObject
---@operator div(LSSnippets.ConditionFuncObject): LSSnippets.ConditionFuncObject
---@operator pow(LSSnippets.ConditionFuncObject): LSSnippets.ConditionFuncObject
---@operator call: boolean
local ConditionFuncObject = {
  -- not '-'
  __unm = function(o1)
    return M.make_condition_func(function(...)
      return not o1(...)
    end)
  end,
  -- and '+'
  __add = function(o1, o2)
    return M.make_condition_func(function(...)
      return o1(...) and o2(...)
    end)
  end,
  -- or '/'
  __div = function(o1, o2)
    return M.make_condition_func(function(...)
      return o1(...) or o2(...)
    end)
  end,
  -- xor '^'
  __pow = function(o1, o2)
    return M.make_condition_func(function(...)
      return o1(...) ~= o2(...)
    end)
  end,
  -- use table like a function by overloading __call
  __call = function(tab, line_to_cursor, matched_trigger, captures)
    return tab.func(line_to_cursor, matched_trigger, captures)
  end,
}

---@class LSSnippets.ConditionObject
---@field condition LSSnippets.ConditionFuncObject
---@field show_condition LSSnippets.ConditionFuncObject
local ConditionObject = {
  ---@param tbl LSSnippets.ConditionObject
  ---@return LSSnippets.ConditionObject
  __unm = function(tbl)
    return M.make_condition(-tbl.condition, -tbl.show_condition)
  end,
  ---@param o1 LSSnippets.ConditionObject
  ---@param o2 LSSnippets.ConditionObject
  ---@return LSSnippets.ConditionObject
  __add = function(o1, o2)
    return M.make_condition(
      o1.condition + o2.condition,
      o1.show_condition + o2.show_condition
    )
  end,
  ---@param o1 LSSnippets.ConditionObject
  ---@param o2 LSSnippets.ConditionObject
  ---@return LSSnippets.ConditionObject
  __div = function(o1, o2)
    return M.make_condition(
      o1.condition / o2.condition,
      o1.show_condition / o2.show_condition
    )
  end,
  ---@param o1 LSSnippets.ConditionObject
  ---@param o2 LSSnippets.ConditionObject
  ---@return LSSnippets.ConditionObject
  __pow = function(o1, o2)
    return M.make_condition(
      o1.condition ^ o2.condition,
      o1.show_condition ^ o2.show_condition
    )
  end,
}

---@param fn function
---@return LSSnippets.ConditionFuncObject
function M.make_condition_func(fn)
  return setmetatable({ func = fn }, ConditionFuncObject)
end

---@param condition function|LSSnippets.ConditionFuncObject
---@param show_condition function|LSSnippets.ConditionFuncObject
---@return LSSnippets.ConditionObject
function M.make_condition(condition, show_condition)
  if type(condition) == "function" then
    condition = M.make_condition_func(condition)
  end
  if type(show_condition) == "function" then
    show_condition = M.make_condition_func(show_condition)
  end

  return setmetatable({
    condition = condition,
    show_condition = show_condition,
  }, ConditionObject)
end

return M
