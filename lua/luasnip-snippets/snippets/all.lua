---@param keyword string
local todo_comment = function(keyword)
  local ls = require("luasnip")
  local f = ls.function_node
  local snippet = require("luasnip-snippets.nodes").construct_snippet
  local Config = require("luasnip-snippets.config")

  return snippet {
    keyword,
    mode = "bw",
    nodes = {
      f(function()
        local CommentFt = require("luasnip-snippets.utils.comment")
        local ft = vim.api.nvim_get_option_value("filetype", {
          buf = 0,
        })
        local pattern = CommentFt.get(ft, 1)
        local name = Config.get("user.name")
        if pattern == nil then
          -- keep the input
          pattern = "%s"
        end
        if type(pattern) == "table" then
          pattern = pattern[1]
        end
        local marker
        if name == nil then
          marker = (" %s: "):format(keyword:upper())
        else
          marker = (" %s(%s): "):format(keyword:upper(), name)
        end
        return pattern:format(marker)
      end, {}),
    },
  }
end

return {
  todo_comment("todo"),
  todo_comment("fixme"),
  todo_comment("note"),
}
