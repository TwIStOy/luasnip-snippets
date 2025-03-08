local header_ext = {
  "hh",
  "h",
  "hpp",
  "hxx",
  "h++",
  "inl",
  "ipp",
  "tcc",
}

local function in_header_file()
  local ext = vim.fn.expand("%:e")
  if vim.list_contains(header_ext, ext) then
    return true
  end
  return false
end

---@param lines string[]
---@return string[]
local function fix_leading_whitespace(lines, indent)
  indent = vim.F.if_nil(indent, 2)
  local leading_whitespace = string.rep(" ", indent)
  local ret = {}
  local first = true
  for _, line in ipairs(lines) do
    if not first then
      table.insert(ret, leading_whitespace .. line)
    else
      first = false
      table.insert(ret, line)
    end
  end
  return ret
end

local function add_trailing_slash(lines)
  local ret = {}
  local max_len = 0
  for _, line in ipairs(lines) do
    max_len = math.max(max_len, #line)
  end
  for _, line in ipairs(lines) do
    local len = #line
    local diff = max_len - len
    table.insert(ret, line .. string.rep(" ", diff) .. " \\")
  end
  return ret
end

return {
  header_ext = header_ext,
  in_header_file = in_header_file,
  fix_leading_whitespace = fix_leading_whitespace,
  add_trailing_slash = add_trailing_slash,
}
