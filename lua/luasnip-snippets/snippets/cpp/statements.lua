local ls = require("luasnip")
local UtilsTS = require("luasnip-snippets.utils.treesitter")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta
local snippet = require("luasnip-snippets.nodes").construct_snippet
local i = require("luasnip-snippets.nodes").insert_node
local c = require("luasnip-snippets.nodes").choice_node
local rep = require("luasnip.extras").rep

local function inject_class_name(_, line_to_cursor, match, captures)
  -- check if at the line begin
  if not line_to_cursor:sub(1, -(#match + 1)):match("^%s*$") then
    return nil
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()

  return UtilsTS.invoke_after_reparse_buffer(
    buf,
    match,
    function(parser, source)
      local pos = {
        row - 1,
        col - #match, -- match has been removed from source
      }
      local node = parser:named_node_for_range {
        pos[1],
        pos[2],
        pos[1],
        pos[2],
      }
      if node == nil then
        return nil
      end

      local class_node = UtilsTS.find_first_parent(node, {
        "struct_specifier",
        "class_specifier",
      })
      if class_node == nil then
        return nil
      end
      local name_nodes = class_node:field("name")
      if name_nodes == nil or #name_nodes == 0 then
        return nil
      end
      local name_node = name_nodes[1]
      local ret = {
        trigger = match,
        captures = captures,
        env_override = {
          CLASS_NAME = vim.treesitter.get_node_text(name_node, source),
        },
      }
      return ret
    end
  )
end

---Construct class constructors
---@param trig string
---@param template string
local function constructor_snip(trig, name, template)
  return ls.s(
    {
      trig = trig,
      name = ("(%s) %s"):format(trig, name),
      wordTrig = true,
      trigEngine = "plain",
      hidden = true,
      snippetType = "autosnippet",
      -- condition = cond and cond.condition,
      -- show_condition = cond and cond.show_condition,
      resolveExpandParams = inject_class_name,
    },
    d(1, function(_, parent)
      local env = parent.env
      return sn(
        nil,
        fmta(template, {
          cls = t(env.CLASS_NAME),
        })
      )
    end)
  )
end

return {
  constructor_snip(
    "ctor!",
    "Default constructor",
    [[
    <cls>() = default;
    ]]
  ),
  constructor_snip(
    "dtor!",
    "Default destructor",
    [[
    ~<cls>() = default;
    ]]
  ),
  constructor_snip(
    "cc!",
    "Copy constructor",
    [[
    <cls>(const <cls>& rhs) = default;
    ]]
  ),
  constructor_snip(
    "mv!",
    "Move constructor",
    [[
    <cls>(<cls>&& rhs) = default;
    ]]
  ),
  constructor_snip(
    "ncc!",
    "No copy constructor",
    [[
    <cls>(const <cls>&) = delete;
    ]]
  ),
  constructor_snip(
    "nmv!",
    "No move constructor",
    [[
    <cls>(<cls>&&) = delete;
    ]]
  ),
  constructor_snip(
    "ncm!",
    "No copy and move constructor",
    [[
    <cls>(const <cls>&) = delete;
    <cls>(<cls>&&) = delete;
    ]]
  ),
  snippet {
    "itf",
    name = "Interface",
    dscr = "Declare interface",
    mode = "bw",
    nodes = fmta(
      [[
        struct <> {
          virtual ~<>() = default;

          <>
        };
        ]],
      {
        i(1, "Interface"),
        rep(1),
        i(0),
      }
    ),
  },
  snippet {
    "pvf",
    name = "Pure virtual function",
    dscr = "Declare pure virtual function",
    mode = "bw",
    nodes = fmta("virtual <ret_t> <name>(<args>) <specifier> = 0;", {
      name = i(1, "func", { dscr = "Function name" }),
      args = i(2, "args", { dscr = "Function arguments" }),
      specifier = i(3, "const", { dscr = "Function specifier" }),
      ret_t = i(4, "void", { dscr = "Return type" }),
    }),
  },
}
