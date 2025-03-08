local ls = require("luasnip")
---@type luasnip-snippets.nodes
local Nodes = require("luasnip-snippets.nodes")
local snippet = Nodes.construct_snippet
local i = Nodes.insert_node
local c = Nodes.choice_node
local fmta = require("luasnip.extras.fmt").fmta
local f = ls.function_node
local t = ls.text_node
local rep = require("luasnip.extras").rep
local CommonCond = require("luasnip-snippets.utils.common_cond")
---@type luasnip-snippets.utils.cond
local Cond = require("luasnip-snippets.utils.cond")
---@type luasnip-snippets.config
local Config = require("luasnip-snippets.config")
---@type luasnip-snippets.utils
local Utils = require("luasnip-snippets.utils")
local CppCommons = require("luasnip-snippets.snippets.cpp.commons")

local has_select_raw = CommonCond.has_select_raw

return {
  snippet {
    "#if",
    name = "(#if) #if ... #endif",
    dscr = "Wrap selected code in #if ... #endif block",
    mode = "bw",
    lang = "cpp",
    cond = has_select_raw,
    nodes = fmta(
      [[
      #if <condition>
      <selected><cursor>
      #endif  // <condition_r>
      ]],
      {
        condition = i(1, "condition"),
        cursor = i(0),
        selected = f(function(_, snip)
          local _, env = {}, snip.env
          return env.LS_SELECT_RAW
        end),
        condition_r = rep(1),
      }
    ),
  },

  snippet {
    "if",
    name = "(if) if (...) { ... }",
    dscr = "Wrap selected code in if (...) { ... } block",
    mode = "bw",
    lang = "cpp",
    cond = has_select_raw,
    nodes = fmta(
      [[
      if (<condition>) {
        <selected><cursor>
      }
      ]],
      {
        condition = i(1, "condition"),
        cursor = i(0),
        selected = f(function(_, snip)
          local _, env = {}, snip.env
          return CppCommons.fix_leading_whitespace(env.LS_SELECT_RAW)
        end),
      }
    ),
  },

  snippet {
    "do",
    name = "(do) do { ... } while (0)",
    dscr = "Wrap selected code in do { ... } while (0) block",
    mode = "bw",
    lang = "cpp",
    cond = has_select_raw,
    nodes = fmta(
      [[
      do {
        <selected><cursor>
      } while (0);
      ]],
      {
        cursor = i(0),
        selected = f(function(_, snip)
          local _, env = {}, snip.env
          return CppCommons.fix_leading_whitespace(env.LS_SELECT_RAW)
        end),
      }
    ),
  },

  snippet {
    "while",
    name = "(while) while (...) { ... }",
    dscr = "Wrap selected code in while (...) { ... } block",
    mode = "bw",
    lang = "cpp",
    cond = has_select_raw,
    nodes = fmta(
      [[
      while (<condition>) {
        <selected><cursor>
      }
      ]],
      {
        condition = i(1, "condition"),
        cursor = i(0),
        selected = f(function(_, snip)
          local _, env = {}, snip.env
          return CppCommons.fix_leading_whitespace(env.LS_SELECT_RAW)
        end),
      }
    ),
  },

  snippet {
    "#de",
    name = "(#de) #define ...",
    dscr = "Wrap selected code in #define block",
    mode = "bw",
    lang = "cpp",
    cond = has_select_raw,
    nodes = fmta(
      [[
      #define <name>() \
        <selected><cursor>
      ]],
      {
        name = i(1, "condition"),
        cursor = i(0),
        selected = f(function(_, snip)
          local _, env = {}, snip.env
          return CppCommons.fix_leading_whitespace(
            CppCommons.add_trailing_slash(env.LS_SELECT_RAW)
          )
        end),
      }
    ),
  },
}
