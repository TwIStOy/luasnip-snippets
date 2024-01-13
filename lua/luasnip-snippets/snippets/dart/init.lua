---@param class_name string
---@param decls LSSnippets.snippet.dart.Declaration[]
local function _build_constructor(class_name, decls)
  local lines = {}
  local all_final = true
  for _, decl in ipairs(decls) do
    if not decl.final then
      all_final = false
      break
    end
  end

  if all_final then
    lines[#lines + 1] = ("const %s({"):format(class_name)
  else
    lines[#lines + 1] = ("%s({"):format(class_name)
  end
  for _, decl in ipairs(decls) do
    lines[#lines + 1] = ("%sthis.%s,"):format(
      decl.nullable and "  " or "  required ",
      decl.identifier
    )
  end
  lines[#lines + 1] = "});"

  return lines
end

return function()
  local snippet = require("luasnip-snippets.nodes").construct_snippet
  local i = require("luasnip-snippets.nodes").insert_node
  local ls = require("luasnip")
  local f = ls.function_node
  local dart_ts = require("luasnip-snippets.snippets.dart._treesitter")
  local sn = ls.snippet_node
  local d = ls.dynamic_node
  local t = ls.text_node
  local fmta = require("luasnip.extras.fmt").fmta
  local extras = require("luasnip.extras")
  local rep = extras.rep

  return {
    snippet {
      "ctor!",
      name = "(ctor!) constructor",
      dscr = "Expands to class constructor",
      mode = "bwA",
      resolveExpandParams = dart_ts.resolve_class_decls,
      nodes = {
        f(function(_, parent)
          local env = parent.snippet.env
          return _build_constructor(env.CLASS_NAME, env.CLASS_DECLS)
        end, {}),
      },
    },

    snippet {
      "js!",
      name = "(js!) $_xxxFromJson/ToJson() methods",
      dscr = "Expands to common json-related(FromJson/ToJson) methods",
      mode = "bwA",
      resolveExpandParams = dart_ts.resolve_maybe_class_decl,
      nodes = d(1, function(_, parent)
        local env = parent.env
        if env.IN_CLASS then
          local lines = {
            "factory %s.fromJson(Map<String, dynamic> json) =>",
            "_$%sFromJson(json);",
            "Map<String, dynamic> toJson() => _$%sToJson(this);",
          }
          local ret = {}
          for _, value in ipairs(lines) do
            ret[#ret + 1] = value:format(env.CLASS_NAME)
          end
          return sn(nil, t(ret))
        else
          return sn(
            nil,
            fmta(
              [[
              @JsonSerializable()
              class <name> {
                factory <rep_name>.fromJson(Map<<String, dynamic>> json) =>>
                    _$<rep_name>FromJson(json);
                Map<<String, dynamic>> toJson() =>> _$<rep_name>ToJson(this);
              }
              ]],
              {
                name = i(1, "ClassName"),
                rep_name = rep(1),
              }
            )
          )
        end
      end),
    },

    snippet {
      "init!",
      name = "(init!) initState",
      dscr = "Expands to initState() with override marker",
      mode = "bwA",
      nodes = fmta(
        [[
        @override
        void initState() {
          super.initState();
          <body>
        }
        ]],
        {
          body = i(0),
        }
      ),
    },

    snippet {
      "dis!",
      name = "(dis!) dispose()",
      dscr = "Expands to dispose() with override marker",
      mode = "bwA",
      nodes = fmta(
        [[
        @override
        void dispose() {
          <body>
          super.dispose();
        }
        ]],
        {
          body = i(0),
        }
      ),
    },

    snippet {
      "for!",
      name = "(for!) for (... in ...)",
      dscr = "Expands to a for loop in variable",
      mode = "bwhA",
      nodes = fmta(
        [[
        for (var item in <iterable>) {
          <body>
        }
        ]],
        {
          iterable = i(1, "Iterable"),
          body = i(0),
        }
      ),
    },

    snippet {
      "fn",
      name = "(fn) function",
      dscr = "Expands to a simple function definition",
      mode = "bw",
      nodes = fmta(
        [[
        <ret> <name>(<args>) {
          <body>
        }
        ]],
        {
          body = i(0),
          name = i(1, "FuncName", { desc = "function name" }),
          args = i(2, "", { desc = "arguments" }),
          ret = i(3, "void", { desc = "return type" }),
        }
      ),
    },

    snippet {
      "wfn",
      name = "(wfn) widget function",
      dscr = "Expands to a function definition returns a Widget",
      mode = "bw",
      nodes = fmta(
        [[
        Widget _build<name>(BuildContext context) {
          <body>
        }
        ]],
        {
          body = i(0),
          name = i(1, "FuncName", { desc = "function name" }),
        }
      ),
    },

    snippet {
      "afn",
      name = "(afn) async function",
      dscr = "Expands to an async function definition",
      mode = "bw",
      nodes = fmta(
        [[
        Future<<<ret>>> <name>(<args>) async {
          <body>
        }
        ]],
        {
          body = i(0),
          name = i(1, "FuncName", { desc = "function name" }),
          args = i(2, "", { desc = "arguments" }),
          ret = i(3, "void", { desc = "return type" }),
        }
      ),
    },

    snippet {
      "sfw!",
      name = "(sfw!) StatefulWidget",
      dscr = "Expands to a StatefulWidget class",
      mode = "bwA",
      nodes = fmta(
        [[
        class <name> extends StatefulWidget {
          const <rep_name>({super.key});

          @override
          State<<<rep_name>>> createState() =>> _<rep_name>State();
        }

        class _<rep_name>State extends State<<<rep_name>>> {
          @override
          void initState() {
            super.initState();
            // TODO(hawtian): Implement initState
          }

          @override
          Widget build(BuildContext context) {
            // TODO(hawtian): Implement build
            throw UnimplementedError();
          }
        }
        ]],
        {
          name = i(1, "ClassName"),
          rep_name = rep(1),
        }
      ),
    },

    snippet {
      "slw!",
      name = "(slw!) StatelessWidget class",
      dscr = "Expands to a StatelessWidget class",
      mode = "bwA",
      nodes = fmta(
        [[
        class <name> extends StatelessWidget {
          <rep_name>({super.key});

          @override
          Widget build(BuildContext context) {
            // TODO(hawtian): Implement build
            throw UnimplementedError();
          }
        }
        ]],
        {
          name = i(1, "ClassName"),
          rep_name = rep(1),
        }
      ),
    },
  }
end
