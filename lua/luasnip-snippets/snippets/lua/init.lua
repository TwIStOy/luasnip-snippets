---@type luasnip-snippets.utils
local Utils = require("luasnip-snippets.utils")

---@type luasnip-snippets.config
local Config = require("luasnip-snippets.config")

local function setup()
  local submodules = {
    "default",
  }

  if Config.get("snippet.lua.vim_snippet") then
    submodules[#submodules + 1] = "vim"
  end

  return Utils.concat_snippets("luasnip-snippets.snippets.lua", submodules)
end

return setup
