local Utils = require("luasnip-snippets.utils")

local function setup()
  local collections = {
    "statements",
  }

  return Utils.concat_snippets("luasnip-snippets.snippets.go", collections)
end

return setup

