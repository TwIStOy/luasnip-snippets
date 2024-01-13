local UtilsTS = require("luasnip-snippets.utils.treesitter")

---@class LSSnippets.snippet.dart.Declaration
---@field ty string
---@field nullable boolean
---@field identifier string
---@field final boolean

--[[
declaration [11, 2] - [11, 23]
  type_identifier [11, 2] - [11, 6]
  type_arguments [11, 6] - [11, 11]
    type_identifier [11, 7] - [11, 10]
  nullable_type [11, 11] - [11, 12]
  initialized_identifier_list [11, 13] - [11, 23]
    initialized_identifier [11, 13] - [11, 17]
      identifier [11, 13] - [11, 17]
    initialized_identifier [11, 19] - [11, 23]
      identifier [11, 19] - [11, 23]
]]

---@param node TSNode
---@param source string|number
---@return LSSnippets.snippet.dart.Declaration[]
local function _handle_declaration(node, source)
  local ty
  local nullable = false
  local final = false
  local fields = {}

  for c in node:iter_children() do
    if c:type() == "type_identifier" then
      ty = vim.treesitter.get_node_text(c, source)
    elseif c:type() == "type_arguments" then
      ty = ty .. vim.treesitter.get_node_text(c, source)
    elseif c:type() == "nullable_type" then
      nullable = true
    elseif c:type() == "final_builtin" then
      final = true
    elseif c:type() == "initialized_identifier_list" then
      for cc in c:iter_children() do
        if cc:type() == "initialized_identifier" then
          local id_node = cc:child(0)
          assert(id_node ~= nil)
          fields[#fields + 1] = vim.treesitter.get_node_text(id_node, source)
        end
      end
    end
  end

  local ret = {}
  for _, field in ipairs(fields) do
    ret[#ret + 1] = {
      ty = ty,
      nullable = nullable,
      final = final,
      identifier = field,
    }
  end

  return ret
end

---@param _ any
---@param line_to_cursor string
---@param match string
---@param captures any
local function resolve_class_decls(_, line_to_cursor, match, captures)
  -- check if at the line begin
  if not line_to_cursor:sub(1, -(#match + 1)):match("^%s*$") then
    return nil
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  ---@param parser LanguageTree
  ---@param source number|string
  return UtilsTS.invoke_after_reparse_buffer(
    buf,
    match,
    function(parser, source)
      local pos = {
        row - 1,
        col - #match,
      }
      local node =
        parser:named_node_for_range { pos[1], pos[2], pos[1], pos[2] }
      if node == nil then
        return nil
      end
      local class_node = UtilsTS.find_first_parent(node, "class_definition")
      if class_node == nil then
        return nil
      end

      local name = class_node:field("name")
      if name == nil or #name == 0 then
        return nil
      end
      local class_name = vim.treesitter.get_node_text(name[1], source)

      local body = class_node:field("body")
      if body == nil or #body == 0 then
        return nil
      end

      local decls = {}

      for c in body[1]:iter_children() do
        if c:type() == "declaration" then
          vim.list_extend(decls, _handle_declaration(c, source))
        end
      end

      return {
        trigger = match,
        captures = captures,
        env_override = {
          CLASS_NAME = class_name,
          CLASS_DECLS = decls,
        },
      }
    end
  )
end

---@param _ any
---@param line_to_cursor string
---@param match string
---@param captures any
local function resolve_maybe_class_decl(_, line_to_cursor, match, captures)
  -- check if at the line begin
  if not line_to_cursor:sub(1, -(#match + 1)):match("^%s*$") then
    return nil
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  ---@param parser LanguageTree
  ---@param source number|string
  return UtilsTS.invoke_after_reparse_buffer(
    buf,
    match,
    function(parser, source)
      local pos = {
        row - 1,
        col - #match,
      }
      local node =
        parser:named_node_for_range { pos[1], pos[2], pos[1], pos[2] }
      if node == nil then
        return nil
      end

      local env = {}

      local class_node = UtilsTS.find_first_parent(node, "class_definition")
      if class_node == nil then
        env.IN_CLASS = false
      else
        env.IN_CLASS = true
        local name = class_node:field("name")
        if name == nil or #name == 0 then
          return nil
        end
        env.CLASS_NAME = vim.treesitter.get_node_text(name[1], source)

        local body = class_node:field("body")
        if body == nil or #body == 0 then
          return nil
        end

        local decls = {}
        for c in body[1]:iter_children() do
          if c:type() == "declaration" then
            vim.list_extend(decls, _handle_declaration(c, source))
          end
        end
        env.CLASS_DECLS = decls
      end

      return {
        trigger = match,
        captures = captures,
        env_override = env,
      }
    end
  )
end

return {
  resolve_class_decls = resolve_class_decls,
  resolve_maybe_class_decl = resolve_maybe_class_decl,
}
