---@class luasnip-snippets.utils.treesitter
local M = {}

---Invoke the given function after the matched trigger removed and the buffer
---has been reparsed.
---@generic T
---@param ori_bufnr number
---@param match string
---@param fun fun(parser: vim.treesitter.LanguageTree, source: string):T
---@return T
function M.invoke_after_reparse_buffer(ori_bufnr, match, fun)
  local function reparse_buffer()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.api.nvim_buf_get_lines(ori_bufnr, 0, -1, false)
    local current_line = lines[row]
    local current_line_left = current_line:sub(1, col - #match)
    local current_line_right = current_line:sub(col + 1)
    lines[row] = current_line_left .. current_line_right
    local lang = vim.treesitter.language.get_lang(vim.bo[ori_bufnr].filetype)
      or vim.bo[ori_bufnr].filetype

    local source = table.concat(lines, "\n")
    ---@type vim.treesitter.LanguageTree
    local parser = vim.treesitter.get_string_parser(source, lang)
    parser:parse(true)

    return parser, source
  end

  local parser, source = reparse_buffer()

  local ret = { fun(parser, source) }

  parser:destroy()

  return unpack(ret)
end

---@param types table | string
---@return table<string, number>
function M.make_type_matcher(types)
  if type(types) == "string" then
    return { [types] = 1 }
  end

  if type(types) == "table" then
    if (vim.islist or vim.tbl_islist)(types) then
      local new_types = {}
      for _, v in ipairs(types) do
        new_types[v] = 1
      end
      return new_types
    end
  end

  return types
end

---Find the first parent node whose type in `types`.
---@param node TSNode?
---@param types table|string
---@return TSNode|nil
function M.find_first_parent(node, types)
  local matcher = M.make_type_matcher(types)

  ---@param root TSNode|nil
  ---@return TSNode|nil
  local function find_parent_impl(root)
    if root == nil then
      return nil
    end
    if matcher[root:type()] == 1 then
      return root
    end
    return find_parent_impl(root:parent())
  end

  return find_parent_impl(node)
end

---Returns the start pos of a `TSNode`
---@param node TSNode?
---@return { [1]: number, [2]: number }?
function M.start_pos(node)
  if node == nil then
    return nil
  end
  local start_row, start_col, _, _ = vim.treesitter.get_node_range(node)
  return { start_row, start_col }
end

--- Normalize the arguments passed to treesitter_postfix into a function that
--- returns treesitter-matches to the specified query+captures.
---@param opts LuaSnip.extra.MatchTSNodeOpts
---@return LuaSnip.extra.MatchTSNodeFunc
function M.generate_match_tsnode_func(opts)
  local ts = require("luasnip.extras._treesitter")
  local match_opts = {}

  if opts.query then
    match_opts.query = vim.treesitter.query.parse(opts.query_lang, opts.query)
  else
    match_opts.query =
      vim.treesitter.query.get(opts.query_lang, opts.query_name or "luasnip")
  end

  match_opts.generator = ts.captures_iter(opts.match_captures or "prefix")

  if type(opts.select) == "function" then
    match_opts.selector = opts.select
  elseif type(opts.select) == "string" then
    match_opts.selector = ts.builtin_tsnode_selectors[opts.select]
    assert(match_opts.selector, "Selector " .. opts.select .. "is not known")
  else
    match_opts.selector = ts.builtin_tsnode_selectors.any
  end

  ---@param parser LuaSnip.extra.TSParser
  ---@param pos { [1]: number, [2]: number }
  return function(parser, pos)
    return parser:match_at(
      match_opts, --[[@as LuaSnip.extra.MatchTSNodeOpts]]
      pos
    )
  end
end

---@class LSSnippets.ProcessMatchesContext
---@field ts_parser LuaSnip.extra.TSParser
---@field best_match LuaSnip.extra.NamedTSMatch
---@field prefix_node TSNode
---@field matched_trigger string
---@field captures any
---@field pos { [1]: number, [2]: number }

---@alias LSSnippets.ProcessMatchesFunc fun(context: LSSnippets.ProcessMatchesContext, previous: table): table

---@param context LSSnippets.ProcessMatchesContext
---@param previous any
function M.inject_tsmatches(context, previous)
  local start_row, start_col, _, _ = context.prefix_node:range()

  local env = {
    LS_TSMATCH = vim.split(
      context.ts_parser:get_node_text(context.prefix_node),
      "\n"
    ),
    -- filled subsequently.
    LS_TSDATA = {},
  }
  for capture_name, node in pairs(context.best_match) do
    env["LS_TSCAPTURE_" .. capture_name:upper()] =
      vim.split(context.ts_parser:get_node_text(node), "\n")

    local from_r, from_c, to_r, to_c = node:range()
    env.LS_TSDATA[capture_name] = {
      type = node:type(),
      range = { { from_r, from_c }, { to_r, to_c } },
    }
  end

  previous = vim.tbl_extend("force", previous, {
    trigger = context.matched_trigger,
    captures = context.captures,
    clear_region = {
      from = {
        start_row,
        start_col,
      },
      to = {
        context.pos[1],
        context.pos[2] + #context.matched_trigger,
      },
    },
    env_override = env,
  })

  return previous
end

---@param match_tsnode LuaSnip.extra.MatchTSNodeFunc
---@param process_funcs LSSnippets.ProcessMatchesFunc[]
function M.generate_resolve_expand_param(match_tsnode, process_funcs)
  ---@param snippet any
  ---@param line_to_cursor string
  ---@param matched_trigger string
  ---@param captures any
  ---@param parser vim.treesitter.LanguageTree
  ---@param source number|string
  ---@param bufnr number
  ---@param pos { [1]: number, [2]: number }
  return function(
    snippet,
    line_to_cursor,
    matched_trigger,
    captures,
    parser,
    source,
    bufnr,
    pos
  )
    local ts = require("luasnip.extras._treesitter")

    local ts_parser = ts.TSParser.new(bufnr, parser, source)
    if ts_parser == nil then
      return
    end

    local row, col = unpack(pos)

    local best_match, prefix_node = match_tsnode(ts_parser, { row, col })

    if best_match == nil or prefix_node == nil then
      return nil
    end

    ---@type LSSnippets.ProcessMatchesContext
    local context = {
      ts_parser = ts_parser,
      best_match = best_match,
      prefix_node = prefix_node,
      matched_trigger = matched_trigger,
      captures = captures,
      pos = pos,
    }
    local ret = {}
    for _, process_func in ipairs(process_funcs) do
      ret = process_func(context, ret)
    end

    return ret
  end
end

---Optionally parse the buffer
---@param reparse boolean|string|nil
---@param real_resolver function
---@return fun(snippet, line_to_cursor, matched_trigger, captures):table?
function M.wrap_with_reparse_context(reparse, real_resolver)
  local util = require("luasnip.util.util")
  local ts = require("luasnip.extras._treesitter")

  local function make_reparse_enter_and_leave_func(
    bufnr,
    trigger_region,
    trigger
  )
    if reparse == "live" then
      local context = ts.FixBufferContext.new(bufnr, trigger_region, trigger)
      return function()
        return context:enter()
      end, function(_)
        context:leave()
      end
    elseif reparse == "copy" then
      local parser, source =
        ts.reparse_buffer_after_removing_match(bufnr, trigger_region)
      return function()
        return parser, source
      end, function()
        parser:destroy()
      end
    else
      return function()
        return vim.treesitter.get_parser(bufnr), bufnr
      end, function(_) end
    end
  end

  return function(snippet, line_to_cursor, matched_trigger, captures)
    local bufnr = vim.api.nvim_win_get_buf(0)
    local cursor = util.get_cursor_0ind()
    local trigger_region = {
      row = cursor[1],
      col_range = {
        -- includes from, excludes to.
        cursor[2] - #matched_trigger,
        cursor[2],
      },
    }

    local enter, leave =
      make_reparse_enter_and_leave_func(bufnr, trigger_region, matched_trigger)
    local parser, source = enter()
    if parser == nil or source == nil then
      return nil
    end

    local ret = real_resolver(
      snippet,
      line_to_cursor,
      matched_trigger,
      captures,
      parser,
      source,
      bufnr,
      { cursor[1], cursor[2] - #matched_trigger }
    )

    leave()

    return ret
  end
end

function M.treesitter_postfix(context, nodes, opts)
  local node_util = require("luasnip.nodes.util")
  local snip = require("luasnip.nodes.snippet").S

  opts = opts or {}
  vim.validate {
    context = { context, { "string", "table" } },
    nodes = { nodes, "table" },
    opts = { opts, "table" },
  }

  context = node_util.wrap_context(context)
  context.wordTrig = false

  ---@type LuaSnip.extra.MatchTSNodeFunc
  local match_tsnode_func
  if type(context.matchTSNode) == "function" then
    match_tsnode_func = context.matchTSNode
  else
    match_tsnode_func = M.generate_match_tsnode_func(context.matchTSNode)
  end

  local expand_params_resolver =
    M.generate_resolve_expand_param(match_tsnode_func, {
      M.inject_tsmatches,
      context.injectMatches,
    })

  context.resolveExpandParams =
    M.wrap_with_reparse_context(context.reparseBuffer, expand_params_resolver)

  return snip(context, nodes, opts)
end

return M
