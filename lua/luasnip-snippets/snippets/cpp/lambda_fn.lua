local ls = require("luasnip")
local UtilsTS = require("luasnip-snippets.utils.treesitter")
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local CppCommons = require("luasnip-snippets.snippets.cpp.commons")
local i = ls.insert_node
local c = ls.choice_node

---@class LSSnippets.Cpp.Fn.Env
---@field CPP_ARGUMENT_START { [1]: number, [2]: number }?
---@field CPP_FUNCTION_BODY_START { [1]: number, [2]: number }?
---@field CPP_CLASS_BODY_START { [1]: number, [2]: number }?
---@field CPP_IN_HEADER_FILE boolean
---@field CPP_IN_QUALIFIED_FUNCTION boolean

---Returns the start pos of a `TSNode`
---@param node TSNode?
---@return { [1]: number, [2]: number }?
local function start_pos(node)
  if node == nil then
    return nil
  end
  local start_row, start_col, _, _ = vim.treesitter.get_node_range(node)
  return { start_row, start_col }
end

---Returns if the node's declarator is qualified or not.
---@param node TSNode? `function_definition` node
---@return boolean
local function is_qualified_function(node)
  if node == nil then
    return false
  end
  print(node:type())
  assert(node:type() == "function_definition")
  local declarators = node:field("declarator")
  if declarators == nil or #declarators == 0 then
    return false
  end
  local declarator = declarators[1]
  print(declarator:type())
  assert(declarator:type() == "function_declarator")
  declarators = declarator:field("declarator")
  if declarators == nil or #declarators == 0 then
    return false
  end
  declarator = declarators[1]
  print(declarator:type())
  if declarator:type() == "qualified_identifier" then
    return true
  end
  return false
end

local function inject_expanding_environment(_, line_to_cursor, match, captures)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()

  return UtilsTS.invoke_after_reparse_buffer(buf, match, function(parser, _)
    local pos = {
      row - 1,
      col - #match,
    }
    local node = parser:named_node_for_range {
      pos[1],
      pos[2],
      pos[1],
      pos[2],
    }

    local ret = {
      trigger = match,
      capture = captures,
      env_override = {
        CPP_ARGUMENT_START = start_pos(UtilsTS.find_first_parent(node, {
          "argument_list",
          "parameter_list",
        })),
        CPP_FUNCTION_BODY_START = start_pos(UtilsTS.find_first_parent(node, {
          "function_definition",
          "lambda_expression",
          "field_declaration",
        })),
        CPP_CLASS_BODY_START = start_pos(UtilsTS.find_first_parent(node, {
          "struct_specifier",
          "class_specifier",
        })),
        CPP_IN_HEADER_FILE = CppCommons.in_header_file(),
        CPP_IN_QUALIFIED_FUNCTION = is_qualified_function(
          UtilsTS.find_first_parent(node, {
            "function_definition",
          })
        ),
      },
    }

    vim.api.nvim_win_set_cursor(0, { row, col })
    return ret
  end)
end

---@param env LSSnippets.Cpp.Fn.Env
local function make_lambda_snippet_node(env)
  local captures = t("&")
  if env.CPP_CLASS_BODY_START or env.CPP_IN_QUALIFIED_FUNCTION then
    -- inside a member function
    captures = c(3, {
      t("this, &"),
      t("this"),
      t("&"),
    })
  end

  local fmt_args = {
    captures = captures,
    body = i(0),
    specifier = c(1, {
      t(""),
      t(" mutable"),
    }),
    args = i(2),
  }

  return sn(
    nil,
    fmta(
      [[
      [<captures>](<args>)<specifier> {
        <body>
      }
      ]],
      fmt_args
    )
  )
end

---@param env LSSnippets.Cpp.Fn.Env
local function make_function_snippet_node(env)
  local fmt_args = {
    body = i(0),
    inline_inline = t(""),
  }
  local storage_specifiers = {
    t(""),
    t("static "),
  }
  if not env.CPP_IN_HEADER_FILE then
    storage_specifiers[#storage_specifiers + 1] = t("inline ")
    storage_specifiers[#storage_specifiers + 1] = t("static inline ")
  else
    fmt_args.inline_inline = t("inline ")
  end

  local specifiers = {
    t(""),
    t(" noexcept"),
  }
  if env.CPP_CLASS_BODY_START then
    specifiers[#specifiers + 1] = t(" const")
    specifiers[#specifiers + 1] = t(" const noexcept")
  end
  fmt_args.storage_specifier =
    c(1, storage_specifiers, { desc = "storage specifier" })
  fmt_args.ret = i(2, "auto", { desc = "return type" })
  fmt_args.name = i(3, "name", { desc = "function name" })
  fmt_args.args = i(4, "args", { desc = "function arguments" })
  fmt_args.specifier = c(5, specifiers, { desc = "specifier" })
  return sn(
    nil,
    fmta(
      [[
      <storage_specifier><inline_inline>auto <name>(<args>)<specifier> ->> <ret> {
        <body>
      }
      ]],
      fmt_args
    )
  )
end

return {
  ls.s(
    {
      trig = "fn",
      wordTrig = true,
      name = "(fn) Function-Definition/Lambda",
      resolveExpandParams = inject_expanding_environment,
    },
    d(1, function(_, parent)
      local env = parent.env
      local last_type, last_type_row, last_type_col
      local keys = {
        "CPP_ARGUMENT_START",
        "CPP_FUNCTION_BODY_START",
        "CPP_CLASS_BODY_START",
      }
      for _, key in ipairs(keys) do
        if env[key] ~= nil then
          if last_type == nil then
            last_type = key
            last_type_row = env[key][1]
            last_type_col = env[key][2]
          else
            if
              last_type_row < env[key][1]
              or (last_type_row == env[key][1] and last_type_col < env[key][2])
            then
              last_type = key
              last_type_row = env[key][1]
              last_type_col = env[key][2]
            end
          end
        end
      end

      if
        last_type == "CPP_ARGUMENT_START"
        or last_type == "CPP_FUNCTION_BODY_START"
      then
        return make_lambda_snippet_node(env)
      else
        return make_function_snippet_node(env)
      end
    end, {})
  ),
}
