local ls = require("luasnip")
local t = ls.text_node
local snippet = require("luasnip-snippets.nodes").construct_snippet

return {
  snippet {
    "pc",
    name = "(pc) pub(crate) ...",
    dscr = "Expands to pub(crate) visibility",
    mode = "bw",
    nodes = {
      t("pub(crate) "),
    },
  },
  snippet {
    "ps",
    name = "(ps) pub(super) ...",
    dscr = "Expands to pub(super) visibility",
    mode = "bw",
    nodes = {
      t("pub(super) "),
    },
  },
  snippet {
    "ii",
    name = "(ii) #[inline] ...",
    dscr = "Expands to #[inline] attribute",
    mode = "bw",
    nodes = {
      t("#[inline]"),
    },
  },
  snippet {
    "ia",
    name = "(ia) #[inline(always)] ...",
    dscr = "Expands to #[inline(always)] attribute",
    mode = "bw",
    nodes = {
      t("#[inline(always)]"),
    },
  },
}
