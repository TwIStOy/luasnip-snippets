local Utils = require("luasnip-snippets.utils")

local function setup()
  return Utils.concat_snippets("luasnip-snippets.snippets.rust", {
    "postfix",
  })
end

return setup
