local Utils = require("luasnip-snippets.utils")

local function setup()
  return Utils.concat_snippets("luasnip-snippets.snippets.cpp", {
    "statements",
    "lambda_fn",
    "postfix",
    "default",
  })
end

return setup
