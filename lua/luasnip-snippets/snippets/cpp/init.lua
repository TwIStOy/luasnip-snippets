local Utils = require("luasnip-snippets.utils")

local function setup()
  local collections = {
    "statements",
    "lambda_fn",
    "postfix",
    "selection",
    "default",
  }

  local Config = require("luasnip-snippets.config")
  local qt_enabled = vim.F.if_nil(Config.get("snippet.cpp.qt"), true)

  if qt_enabled then
    collections[#collections + 1] = "qt"
  end

  return Utils.concat_snippets("luasnip-snippets.snippets.cpp", collections)
end

return setup
