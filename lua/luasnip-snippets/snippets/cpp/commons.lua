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

return {
  header_ext = header_ext,
  in_header_file = in_header_file,
}
