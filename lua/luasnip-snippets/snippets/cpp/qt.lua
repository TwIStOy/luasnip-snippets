local ls = require("luasnip")
local UtilsTS = require("luasnip-snippets.utils.treesitter")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local snippet = require("luasnip-snippets.nodes").construct_snippet
local i = require("luasnip-snippets.nodes").insert_node
local rep = require("luasnip.extras").rep

return {
  snippet {
    "qcls",
    name = "Q_OBJECT class",
    dscr = "Declare a class with Q_OBJECT macro",
    mode = "bw",
    nodes = fmta(
      [[
      class <> : public QObject {
          Q_OBJECT

      public:
          ~<>() = default;
      };
      ]],
      {
        i(1, "Class Name"),
        rep(1),
      }
    ),
  },
  snippet {
    "#q",
    name = "include qt MOC",
    dscr = "#include qt generated MOC file",
    mode = "bA",
    lang = "cpp",
    nodes = fmta('#include "moc_<filename>"', {
      filename = f(function()
        local filename = vim.fn.expand("%:t")
        return ("%s"):format(filename)
      end),
    }),
  },
}
