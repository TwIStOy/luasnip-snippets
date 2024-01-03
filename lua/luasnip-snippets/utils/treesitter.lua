local M = {}

---Invoke the given function after the matched trigger removed and the buffer
---has been reparsed.
---@generic T
---@param ori_bufnr number
---@param match string
---@param fun fun(parser: LanguageTree, source: string):T
---@return T
function M.invoke_after_reparse_buffer(ori_bufnr, match, fun)
  local function reparse_buffer()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.api.nvim_buf_get_lines(ori_bufnr, 0, -1, false)
    local current_line = lines[row]
    local current_line_left = current_line:sub(1, col - #match)
    local current_line_right = current_line:sub(col + 1)
    lines[row] = current_line_left .. current_line_right
    local lang = vim.treesitter.language.get_lang(vim.bo[ori_bufnr].filetype)
      or vim.bo[ori_bufnr].filetype

    local source = table.concat(lines, "\n")
    ---@type LanguageTree
    local parser = vim.treesitter.get_string_parser(source, lang)
    parser:parse(true)

    return parser, source
  end

  local parser, source = reparse_buffer()

  local ret = { fun(parser, source) }

  parser:destroy()

  return unpack(ret)
end

---@param types table | string
---@return table<string, number>
function M.make_type_matcher(types)
  if type(types) == "string" then
    return { [types] = 1 }
  end

  if type(types) == "table" then
    if vim.tbl_islist(types) then
      local new_types = {}
      for _, v in ipairs(types) do
        new_types[v] = 1
      end
      return new_types
    end
  end

  return types
end

---Find the first parent node whose type in `types`.
---@param node TSNode?
---@param types table|string
---@return TSNode|nil
function M.find_first_parent(node, types)
  local matcher = M.make_type_matcher(types)

  ---@param root TSNode|nil
  ---@return TSNode|nil
  local function find_parent_impl(root)
    if root == nil then
      return nil
    end
    if matcher[root:type()] == 1 then
      return root
    end
    return find_parent_impl(root:parent())
  end

  return find_parent_impl(node)
end

return M
