local Utils = require("luasnip-snippets.utils")

local function setup()
  return Utils.concat_snippets("luasnip-snippets.snippets.rust", {
    "default",
    "postfix",
    "lambda_fn",
  })
end

return setup
