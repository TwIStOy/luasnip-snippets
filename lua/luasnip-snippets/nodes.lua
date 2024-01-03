---@param idx number
---@param placeholder? string
---@param opts? table
local function insert_node(idx, placeholder, opts)
  local ls = require("luasnip")
  if idx == 0 then
    return ls.insert_node(idx)
  end
  opts = opts or {}
  local extra_opts = {
    node_ext_opts = {
      active = {
        virt_text = {
          {
            " " .. idx .. ": " .. (opts.desc or placeholder or "insert"),
            "Comment",
          },
        },
      },
    },
  }
  opts = vim.tbl_extend("keep", opts, extra_opts)
  return ls.insert_node(idx, placeholder, opts)
end

---@param idx number
---@param choices table
---@param opts? table
local function choice_node(idx, choices, opts)
  local ls = require("luasnip")
  opts = opts or {}
  local extra_opts = {
    node_ext_opts = {
      active = {
        virt_text = {
          { " " .. idx .. ": " .. (opts.desc or "choice"), "Comment" },
        },
      },
    },
  }
  opts = vim.tbl_extend("keep", opts, extra_opts)
  return ls.choice_node(idx, choices, opts)
end

return {
  insert_node = insert_node,
  choice_node = choice_node,
}
