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

local function expr_or_type_tsp(trig, typename, expr_callback, type_callback)
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
        return expr_callback(env.LS_TSMATCH)
      else
        -- is type
        return type_callback(env.LS_TSMATCH)
      end
    end),
  })
end

local function simple_expr_or_type_tsp(trig, typename)
  local expr_callback = function(match)
    return Utils.replace_all(match, typename .. "::new(%s)")
  end
  local type_callback = function(match)
    return Utils.replace_all(match, typename .. "<%s>")
  end
  return expr_or_type_tsp(trig, typename, expr_callback, type_callback)
end

local function result_type_callback(match)
  return Utils.replace_all(match, "Result<%s, _>")
end

local function build_simple_replace_callback(replaced)
  return function(match)
    return Utils.replace_all(match, replaced)
  end
end

return {
  simple_expr_or_type_tsp(".rc", "Rc"),
  simple_expr_or_type_tsp(".arc", "Arc"),
  simple_expr_or_type_tsp(".box", "Box"),
  simple_expr_or_type_tsp(".mu", "Mutex"),
  simple_expr_or_type_tsp(".rw", "RwLock"),
  simple_expr_or_type_tsp(".cell", "Cell"),
  simple_expr_or_type_tsp(".refcell", "RefCell"),
  simple_expr_or_type_tsp(".ref", "&?"),
  simple_expr_or_type_tsp(".refm", "&mut ?"),
  expr_or_type_tsp(
    ".ok",
    "Ok(?)",
    build_simple_replace_callback("Ok(%s)"),
    result_type_callback
  ),
  expr_or_type_tsp(
    ".err",
    "Err(?)",
    build_simple_replace_callback("Err(%s)"),
    result_type_callback
  ),
  expr_or_type_tsp(
    ".some",
    "Some(?)",
    build_simple_replace_callback("Some(%s)"),
    build_simple_replace_callback("Option<%s>")
  ),

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

  tsp.treesitter_postfix({
    trig = ".match",
    name = [[(.match) match ?]],
    dscr = [[Wrap expression with match ? block]],
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
        [[match %s {
        }]]
      )
    end, {}),
  }),
}
