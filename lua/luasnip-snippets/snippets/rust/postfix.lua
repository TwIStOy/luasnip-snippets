local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")

local expr_node_types = {
  "struct_expression",
  "call_expression",
  "identifier",
}

---@param trig string
---@param expand string
local function expr_tsp(trig, expand)
  local name = ("(%s) %s"):format(trig, expand)
  local dscr = ("Wrap expression with %s"):format(expand)
  local replaced = expand:gsub("?", "%%s")

  return tsp.treesitter_postfix({
    trig = trig,
    name = name,
    dscr = dscr,
    wordTrig = false,
    reparseBuffer = nil,
    matchTSNode = tsp.builtin.tsnode_matcher.find_topmost_types(
      expr_node_types,
      trig
    ),
  }, {
    f(function(_, parent)
      return Utils.replace_all(parent.snippet.env.LS_TSMATCH, replaced)
    end, {}),
  })
end

return {
  expr_tsp(".rc", "Rc::new(?)"),
  expr_tsp(".arc", "Arc::new(?)"),
  expr_tsp(".box", "Box::new(?)"),
  expr_tsp(".mu", "Mutex::new(?)"),
  expr_tsp(".rw", "RwLock::new(?)"),
  expr_tsp(".cell", "Cell::new(?)"),
  expr_tsp(".refcell", "RefCell::new(?)"),
  expr_tsp(".ref", "&?"),
  expr_tsp(".refm", "&mut ?"),
  expr_tsp(".ok", "Ok(?)"),
  expr_tsp(".err", "Err(?)"),
  expr_tsp(".some", "Some(?)"),
}
