<h1 align="center">LuaSnip Snippets</h1>

<p align="center">
    <a href="https://github.com/TwIStOy/luasnip-snippets/pulse">
      <img src="https://img.shields.io/github/last-commit/TwIStOy/luasnip-snippets?style=for-the-badge&logo=github&color=7dc4e4&logoColor=D9E0EE&labelColor=302D41"/></a>
    <a href="https://github.com/TwIStOy/luasnip-snippets/stargazers">
      <img src="https://img.shields.io/github/stars/TwIStOy/luasnip-snippets?style=for-the-badge&logo=apachespark&color=eed49f&logoColor=D9E0EE&labelColor=302D41"/></a>
    <a href="https://github.com/TwIStOy/luasnip-snippets">
      <img alt="Repo Size" src="https://img.shields.io/github/repo-size/TwIStOy/luasnip-snippets?color=%23DDB6F2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41" /></a>
</p>

A collection of snippets for various programming language. Some snippets are
highly inspired by Jetbrain's IDEs.

## 📦 Installation

```lua
{
  "TwIStOy/luasnip-snippets",
  dependencies = { "L3MON4D3/LuaSnip" },
  event = { "InsertEnter" },
  config = function()
    -- register all snippets into LuaSnip
    require("luasnip-snippets").setup()
  end
}
```

`autosnippet` feature should be enabled in `LuaSnip`.

```lua
local ls = require('luasnip')
ls.setup({
  enable_autosnippets = true,
})
```

# ⚙️ Configuration

Config Example:

```lua
---@type LSSnippets.Config
{
  user = {
    -- user's name, used in todo-related snippets now
    name = nil,
  },
  snippet = {
    lua = {
      -- enable neovim related snippets in lua
      vim_snippet = false,
    },
    cpp = {
      quick_type = {
        -- use `std::unordered_map` instead of `absl::flat_hash_map`
        extra_trig = {
          { trig = 'm', params = 2, template = 'std::unordered_map<%s, %s>' }
        }
      },
    },
    rust = {
      -- add `#[rstest]` to test function's attribute choices, if the test mod has already use `rstest` directly
      rstest_support = false,
    },
  },
  disable_auto_expansion = {
    -- disable these snippets' auto expansion
    cpp = { "i32", "i64" },
  },
  disable_langs = {
    -- disable these language's snippets
    -- "dart"
  }
}
```

## Snippets

<details>
<summary>All</summary>

#### Normal Snippets

|  Trig   | Desc                               |
| :-----: | ---------------------------------- |
| `todo`  | Expand to linewise `TODO` comment  |
| `fixme` | Expand to linewise `FIXME` comment |
| `note`  | Expand to linewise `NOTE` comment  |

</details>

<details>
<summary>Lua</summary>

Snippets with `*` are available only when `vim_snippet` is enabled.

#### Normal Snippets

|  Trig   | Desc                                       | Context Required |
| :-----: | ------------------------------------------ | :--------------: |
|  `fn`   | Expands to function definition.            |        No        |
|  `req`  | Expands to `require(...)` statement.       |        No        |
| `ifn`\* | Expand to `vim.F.if_nil(...)` expresstion. |        No        |

#### Postfix Snippets

```scheme
[
  (function_call)
  (identifier)
  (expression_list)
  (dot_index_expression)
  (bracket_index_expression)
] @any_expr
[
  (dot_index_expression)
  (bracket_index_expression)
] @index_expr
```

|   Trig    | Desc (placehoder: `?`)                    | Expr before cursor |
| :-------: | ----------------------------------------- | :----------------: |
| `.ipairs` | Expands to `ipairs(?)` for-loop.          |     `any_expr`     |
| `.pairs`  | Expands to `pairs(?)` for-loop.           |     `any_expr`     |
| `.isnil`  | Expands to `if ? == nil then` statement.  |     `any_expr`     |
| `.tget`\* | Expands to `vim.tbl_get(...)` expression. |    `index_expr`    |

#### Auto-snippets

| Trig | Desc                                                   | Context Required | Could Disable AutoExpansion |
| :--: | ------------------------------------------------------ | :--------------: | :-------------------------: |
| `#i` | Expands to `require(...)` statement with type hinting. |        No        |             No              |

</details>

<details>
<summary>Cpp</summary>

#### Normal Snippets

|    Trig     | Desc                                                                                               | Context Required |
| :---------: | -------------------------------------------------------------------------------------------------- | :--------------: |
|    `fn`     | Expands to lambda function in argument list or function body, otherwise expand to normal function. |        No        |
|  `\|trans`  | Expands to ranges::views::transform pipe.                                                          |        No        |
| `\|filter`  | Expands to ranges::views::filter pipe.                                                             |        No        |
|    `cpo`    | Expands to customize point object.                                                                 |        No        |
| `ns%s(%S+)` | Expands to namespace block (including comments).                                                   |        No        |
|    `itf`    | Expands to a struct with default virtual destruction.                                              |        No        |
|    `pvf`    | Expands to a pure virtual function declaration.                                                    |        No        |

#### Auto-snippets

|   Trig   | Desc                                                      |       Context Required        | Could Disable AutoExpansion |
| :------: | --------------------------------------------------------- | :---------------------------: | :-------------------------: |
| `ctor!`  | Expands to default constructor.                           |           In Class            |             No              |
| `dtor!`  | Expands to default destructor.                            |           In Class            |             No              |
|  `cc!`   | Expands to default copy constructor.                      |           In Class            |             No              |
|  `mv!`   | Expands to default move constructor.                      |           In Class            |             No              |
|  `ncc!`  | Expands to delete copy constructor.                       |           In Class            |             No              |
|  `nmv!`  | Expands to delete move constructor.                       |           In Class            |             No              |
|  `ncm!`  | Expands to delete copy and move constructor.              |           In Class            |             No              |
|  `once`  | Expands to `pragma once` marker at the front of the file. | All lines before are comments |             Yes             |
|   `u8`   | Expands to `uint8_t`.                                     |              No               |             Yes             |
|  `u16`   | Expands to `uint16_t`.                                    |              No               |             Yes             |
|  `u32`   | Expands to `uint32_t`.                                    |              No               |             Yes             |
|  `u64`   | Expands to `uint64_t`.                                    |              No               |             Yes             |
|   `i8`   | Expands to `int8_t`.                                      |              No               |             Yes             |
|  `i16`   | Expands to `int16_t`.                                     |              No               |             Yes             |
|  `i32`   | Expands to `int32_t`.                                     |              No               |             Yes             |
|  `i64`   | Expands to `int64_t`.                                     |              No               |             Yes             |
| `t(%s)!` | Evaluates (QET) marker, and expand to typename.           |              No               |             No              |
|   `#"`   | Expands to include statement with quotes. `#include ""`.  |              No               |             Yes             |
|   `#<`   | Expands to include statement with `<>`. `#include <>`.    |              No               |             Yes             |

##### Quick Expand Type markers

| Marker | Expand Type           | Parameter |
| :----: | :-------------------- | :-------: |
|  `v`   | `std::vector`         |     1     |
|  `i`   | `int32_t`             |     0     |
|  `u`   | `uint32_t`            |     0     |
|  `s`   | `std::string`         |     0     |
|  `m`   | `absl::flat_hash_map` |     2     |
|  `t`   | `std::tuple`          |    `*`    |

Example:

```
tvi! -> std::vector<int32_t>
tmss! -> absl::flat_hash_map<std::string, std::string>
```

#### Postfix Snippets

```scheme
[
  (identifier)
  (field_identifier)
] @indent

[
  (call_expression)
  (identifier)
  (template_function)
  (subscript_expression)
  (field_expression)
  (user_defined_literal)
] @any_expr
```

|   Trig    | Desc (placehoder: `?`)                                               | Expr before cursor |
| :-------: | -------------------------------------------------------------------- | :----------------: |
|   `.be`   | Expands to begin and end exprs.                                      |     `any_expr`     |
|  `.cbe`   | Expands to cbegin and cend exprs.                                    |     `any_expr`     |
|   `.mv`   | Wraps with `std::move(?)`.                                           |     `any_expr`     |
|  `.fwd`   | Wraps with `std::forward<decltype(?)>(?)`.                           |     `any_expr`     |
|  `.val`   | Wraps with `std::declval<?>()`.                                      |     `any_expr`     |
|   `.dt`   | Wraps with `decltype(?)`.                                            |     `any_expr`     |
|   `.uu`   | Wraps with `(void)?`.                                                |     `any_expr`     |
|   `.ts`   | Switches indent's coding style between `CamelCase` and `snake_case`. |      `indent`      |
|   `.sc`   | Wraps with `static_cast<>(?)`.                                       |     `any_expr`     |
| `.single` | Wraps with `ranges::views::single(?)`.                               |     `any_expr`     |
| `.await`  | Expands to `co_await ?`.                                             |     `any_expr`     |
|   `.in`   | Expands to `if (...find)` statements.                                |     `any_expr`     |

</details>

<details>
<summary>Rust</summary>

#### Normal Snippets

| Trig  | Desc                                                                                                                                         | Context Required |
| :---: | -------------------------------------------------------------------------------------------------------------------------------------------- | :--------------: |
| `fn`  | Expands to lambda function in argument list or function body, otherwise expand to normal function.                                           |        No        |
| `pc`  | Expands to `pub(crate)`.                                                                                                                     |        No        |
| `ps`  | Expands to `pub(super)`.                                                                                                                     |        No        |
| `ii`  | Expands to `#[inline]`.                                                                                                                      |        No        |
| `ia`  | Expands to `#[inline(always)]`.                                                                                                              |        No        |
| `tfn` | Expands to a test function. `#[test]` or `#[tokio::test]` supported. With `snippet.rust.rstest_support` enabled, `#[rstest]` also supported. |        No        |
| `pm`  | Expands to a public method definition.                                                                                                       |  In impl block   |

#### Postfix Snippets

```scheme
[
  (struct_expression)
  (call_expression)
  (identifier)
  (field_expression)
] @expr

[
  (struct_expression)
  (call_expression)
  (identifier)
  (field_expression)

  (generic_type)
  (scoped_type_identifier)
  (reference_type)
] @expr_or_type
```

|    Trig    | Desc (placehoder: `?`)                                      | Expr before cursor |
| :--------: | ----------------------------------------------------------- | :----------------: |
|   `.rc`    | Wraps with `Rc::new(?)` if expr, `Rc<?>` if type.           |   `expr_or_type`   |
|   `.arc`   | Wraps with `Arc::new(?)` if expr, `Arc<?>` if type.         |   `expr_or_type`   |
|   `.box`   | Wraps with `Box::new(?)` if expr, `Box<?>` if type.         |   `expr_or_type`   |
|   `.mu`    | Wraps with `Mutex::new(?)` if expr, `Mutex<?>` if type.     |   `expr_or_type`   |
|   `.rw`    | Wraps with `RwLock::new(?)` if expr, `RwLock<?>` if type.   |   `expr_or_type`   |
|  `.cell`   | Wraps with `Cell::new(?)` if expr, `Cell<?>` if type.       |   `expr_or_type`   |
| `.refcell` | Wraps with `RefCell::new(?)` if expr, `RefCell<?>` if type. |   `expr_or_type`   |
|   `.ref`   | Wraps with `&?`.                                            |   `expr_or_type`   |
|  `.refm`   | Wraps with `&mut ?`.                                        |   `expr_or_type`   |
|   `.ok`    | Wraps with `Ok(?)`.                                         |       `expr`       |
|   `.err`   | Wraps with `Err(?)`.                                        |       `expr`       |
|  `.some`   | Wraps with `Some(?)`.                                       |       `expr`       |
| `.println` | Wraps with `println!("{:?}", ?)`.                           |       `expr`       |
|  `.match`  | Wraps with `match ? {}`.                                    |       `expr`       |

</details>

<details>
<summary>Dart</summary>

#### Normal Snippets

| Trig  | Desc                                             | Context Required |
| :---: | ------------------------------------------------ | :--------------: |
| `fn`  | Expands to function definition.                  |        No        |
| `wfn` | Expands to function definition returns a widget. |        No        |
| `afn` | Expands to an async function definition.         |        No        |

#### Auto-snippets

|  Trig   | Desc                                      | Context Required |
| :-----: | ----------------------------------------- | :--------------: |
| `ctor!` | Expands to class constructor function.    |     In Class     |
|  `js!`  | Expands to json-related methods.          |     In Class     |
| `init!` | Expands to `initState` override function. |        No        |
| `dis!`  | Expands to `dispose` override function.   |        No        |
| `for!`  | Expands to for-loop.                      |        No        |
| `sfw!`  | Expands to `StatefulWidget` class.        |        No        |
| `slw!`  | Expands to `StatelessWidget` class.       |        No        |

</details>

<details>
<summary>Nix</summary>

#### Normal Snippets

|   Trig    | Desc                             | Context Required |
| :-------: | -------------------------------- | :--------------: |
| `@module` | Expands to a nix module declare. |        No        |

#### Postfix Snippets

```scheme
[
  (identifier)
] @identifier
[
((binding
  expression: (_) @expr
))
] @binding
```

|   Trig   | Desc (placehoder: `?`)                  | Expr before cursor |
| :------: | --------------------------------------- | :----------------: |
|  `.on`   | Expands to enable option statement.     |    `identifier`    |
| `.split` | Expands bindings to full attrset style. |     `binding`      |

</details>
