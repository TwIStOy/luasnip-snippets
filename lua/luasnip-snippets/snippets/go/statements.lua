local ls = require("luasnip")
local UtilsTS = require("luasnip-snippets.utils.treesitter")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta
local CppCommons = require("luasnip-snippets.snippets.cpp.commons")
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
local f = ls.function_node

---@param fn_node TSNode `function_declaration` node
---@return number?, number? index of `error` in return type, or nil if not found
local function get_error_in_return_type_index(fn_node, source)
  if fn_node == nil then
    return nil
  end
  local result_node = fn_node:field("result")[1]
  if result_node == nil then
    return nil
  end

  local result_node_type = result_node:type()
  if result_node_type == "type_identifier" then
    local type_name = vim.treesitter.get_node_text(result_node, source)
    if type_name == "error" then
      return 1, 1
    end
  elseif result_node_type == "parameter_list" then
    local index = 1
    local error_index = 0
    for parameter in result_node:iter_children() do
      if parameter:type() == "parameter_declaration" then
        local parameter_type_node = parameter:field("type")[1]
        if
          parameter_type_node ~= nil
          and parameter_type_node:type() == "type_identifier"
          then
            local type_name =
            vim.treesitter.get_node_text(parameter_type_node, source)
            if type_name == "error" then
              error_index = index
            end
          end
          index = index + 1
      end
    end
    if error_index > 0 then
      return error_index, index - 1
    end
  end
  return nil
end

local function inject_expanding_environment(_, line_to_cursor, match, captures)
  -- check if at the line begin
  if not line_to_cursor:sub(1, -(#match + 1)):match("^%s*$") then
    return nil
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()

  return UtilsTS.invoke_after_reparse_buffer(
    buf,
    match,
    function(parser, source)
      local pos = {
        row - 1,
        col - #match,
      }
      local node = parser:named_node_for_range {
        pos[1],
        pos[2],
        pos[1],
        pos[2],
      }
      if node == nil then
        return nil
      end

      local ret = {
        trigger = match,
        capture = captures,
        env_override = {},
      }
      local fn_node = UtilsTS.find_first_parent(node, {
        "function_declaration",
      })
      if fn_node == nil then
        return nil
      end

      if fn_node ~= nil then
        ret.env_override.GO_IN_FUNCTION = true
        local index, count = get_error_in_return_type_index(fn_node, source)
        ret.env_override.GO_ERROR_IN_RETURN_TYPE_INDEX = index
        ret.env_override.GO_RETURN_TYPE_COUNT = count
      end

      vim.api.nvim_win_set_cursor(0, { row, col })
      return ret
    end
  )
end

return {
  ls.s(
    {
      trig = "err!",
      wordTrig = true,
      name = "(err!) check error and return if not nil",
      resolveExpandParams = inject_expanding_environment,
    },
    d(1, function(_, parent)
      local env = parent.env
      local err_index = env.GO_ERROR_IN_RETURN_TYPE_INDEX
      local ret = ""
      if err_index ~= nil then
        local count = env.GO_RETURN_TYPE_COUNT or 1
        local ret_parts = {}
        for j = 1, count do
          if j == err_index then
            table.insert(ret_parts, "err")
          else
            table.insert(ret_parts, "nil")
          end
        end
        ret = table.concat(ret_parts, ", ")
      end
      return sn(
        nil,
        fmta(
          [[
          if err != nil {
            return <ret>
          }
          ]],
          {
            ret = t(ret),
          }
        )
      )
    end)
  ),
}
