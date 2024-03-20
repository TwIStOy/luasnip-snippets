local ls = require("luasnip")
local f = ls.function_node
local tsp = require("luasnip.extras.treesitter_postfix")
local Utils = require("luasnip-snippets.utils")

local expr_query = [[
[
  (struct_expression)
  (call_expression)
  (identifier)
  (field_expression)
  (integer_literal)
  (string_literal)
] @prefix
]]

local expr_or_type_query = [[
[
  (struct_expression)
  (call_expression)
  (identifier)
  (field_expression)
  (integer_literal)
  (string_literal)
  
  (type_identifier)
  (generic_type)
  (scoped_type_identifier)
  (reference_type)
] @prefix
]]

local expr_node_types = {
  ["struct_expression"] = true,
  ["call_expression"] = true,
  ["identifier"] = true,
  ["field_expression"] = true,
  ["integer_literal"] = true,
  ["string_literal"] = true,
}

---@param trig string
---@param expand string
local function expr_tsp(trig, expand)
  local name = ("(%s) %s"):format(trig, expand)
  local dscr = ("Wraps an expression with %s"):format(expand)
  local replaced = expand:gsub("?", "%%s")

  return tsp.treesitter_postfix({
    trig = trig,
    name = name,
    dscr = dscr,
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = expr_query,
      query_lang = "rust",
    },
  }, {
    f(function(_, parent)
      return Utils.replace_all(parent.snippet.env.LS_TSMATCH, replaced)
    end, {}),
  })
end

local function expr_or_type_tsp(trig, typename)
  local name = ("(%s) %s"):format(trig, typename)
  local dscr = ("Wrap expression/type with %s"):format(typename)
  return tsp.treesitter_postfix({
    trig = trig,
    name = name,
    dscr = dscr,
    wordTrig = false,
    reparseBuffer = "live",
    matchTSNode = {
      query = expr_or_type_query,
      query_lang = "rust",
    },
  }, {
    f(function(_, parent)
      local env = parent.snippet.env
      local data = env.LS_TSDATA
      if expr_node_types[data.prefix.type] then
        -- is expr
        return Utils.replace_all(env.LS_TSMATCH, typename .. "::new(%s)")
      else
        -- is type
        return Utils.replace_all(env.LS_TSMATCH, typename .. "<%s>")
      end
    end),
  })
end

return {
  expr_or_type_tsp(".rc", "Rc"),
  expr_or_type_tsp(".arc", "Arc"),
  expr_or_type_tsp(".box", "Box"),
  expr_or_type_tsp(".mu", "Mutex"),
  expr_or_type_tsp(".rw", "RwLock"),
  expr_or_type_tsp(".cell", "Cell"),
  expr_or_type_tsp(".refcell", "RefCell"),
  expr_tsp(".ref", "&?"),
  expr_tsp(".refm", "&mut ?"),
  expr_tsp(".ok", "Ok(?)"),
  expr_tsp(".err", "Err(?)"),
  expr_tsp(".some", "Some(?)"),

  tsp.treesitter_postfix({
    trig = ".println",
    name = [[(.println) println!("{:?}", ?)]],
    dscr = [[Wrap expression with println!("{:?}", ?)]],
    wordTrig = false,
    reparseBuffer = nil,
    matchTSNode = {
      query = expr_query,
      query_lang = "rust",
    },
  }, {
    f(function(_, parent)
      return Utils.replace_all(
        parent.snippet.env.LS_TSMATCH,
        [[println!("{:?}", %s)]]
      )
    end, {}),
  }),
}
