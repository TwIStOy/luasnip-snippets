# LuaSnip Snippets

A collection of snippets for various programming language. Some snippets are
highly inspired by Jetbrain's IDEs.

## Installation

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

#### Normal Snippets

| Trig  | Desc                                 | Context Required |
| :---: | ------------------------------------ | :--------------: |
| `fn`  | Expands to function definition.      |        No        |
| `req` | Expands to `require(...)` statement. |        No        |

#### Postfix Snippets

```scheme
[
  (function_call)
  (identifier)
  (expression_list)
] @any_expr
```

|   Trig    | Desc (placehoder: `?`)                   | Expr before cursor |
| :-------: | ---------------------------------------- | :----------------: |
| `.ipairs` | Expands to `ipairs(?)` for-loop.         |     `any_expr`     |
| `.pairs`  | Expands to `pairs(?)` for-loop.          |     `any_expr`     |
| `.isnil`  | Expands to `if ? == nil then` statement. |     `any_expr`     |

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

|   Trig   | Desc                                                      |       Context Required        |
| :------: | --------------------------------------------------------- | :---------------------------: |
| `ctor!`  | Expands to default constructor.                           |           In Class            |
| `dtor!`  | Expands to default destructor.                            |           In Class            |
|  `cc!`   | Expands to default copy constructor.                      |           In Class            |
|  `mv!`   | Expands to default move constructor.                      |           In Class            |
|  `ncc!`  | Expands to delete copy constructor.                       |           In Class            |
|  `nmv!`  | Expands to delete move constructor.                       |           In Class            |
|  `ncm!`  | Expands to delete copy and move constructor.              |           In Class            |
|  `once`  | Expands to `pragma once` marker at the front of the file. | All lines before are comments |
|   `u8`   | Expands to `uint8_t`.                                     |              No               |
|  `u16`   | Expands to `uint16_t`.                                    |              No               |
|  `u32`   | Expands to `uint32_t`.                                    |              No               |
|  `u64`   | Expands to `uint64_t`.                                    |              No               |
|   `i8`   | Expands to `int8_t`.                                      |              No               |
|  `i16`   | Expands to `int16_t`.                                     |              No               |
|  `i32`   | Expands to `int32_t`.                                     |              No               |
|  `i64`   | Expands to `int64_t`.                                     |              No               |
| `t(%s)!` | Evaluates (QET) marker, and expand to typename.           |              No               |
|   `#"`   | Expands to include statement with quotes. `#include ""`.  |              No               |
|   `#<`   | Expands to include statement with `<>`. `#include <>`.    |              No               |

##### Quick Expand Type markers

| Marker | Expand Type           | Parameter |
| :----: | :-------------------- | :-------: |
|  `v`   | `std::vector`         |     1     |
|  `i`   | `int32_t`             |     0     |
|  `u`   | `uint32_t`            |     0     |
|  `s`   | `std::string`         |     0     |
|  `m`   | `absl::flat_hash_map` |     2     |
|  `t`   | `std::tuple`          |    `*`    |

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
|   `.mv`   | Wraps with `std::move(?)`.                                           |     `any_expr`     |
|  `.fwd`   | Wraps with `std::forward<decltype(?)>(?)`.                           |     `any_expr`     |
|  `.val`   | Wraps with `std::declval<?>()`.                                      |     `any_expr`     |
|   `.dt`   | Wraps with `decltype(?)`.                                            |     `any_expr`     |
|   `.uu`   | Wraps with `(void)?`.                                                |     `any_expr`     |
|   `.ts`   | Switches indent's coding style between `CamelCase` and `snake_case`. |      `indent`      |
|   `.sc`   | Wraps with `static_cast<>(?)`.                                       |     `any_expr`     |
| `.single` | Wraps with `ranges::views::single(?)`.                               |     `any_expr`     |
|   `.in`   | Expands to `if (...find)` statements.                                |     `any_expr`     |

</details>

<details>
<summary>Rust</summary>

#### Normal Snippets

| Trig | Desc                                                                                               | Context Required |
| :--: | -------------------------------------------------------------------------------------------------- | :--------------: |
| `fn` | Expands to lambda function in argument list or function body, otherwise expand to normal function. |        No        |
| `pc` | Expands to `pub(crate)`.                                                                           |        No        |
| `ps` | Expands to `pub(super)`.                                                                           |        No        |
| `ii` | Expands to `#[inline]`.                                                                            |        No        |
| `ia` | Expands to `#[inline(always)]`.                                                                    |        No        |

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
|   `.ref`   | Wraps with `&?`.                                            |       `expr`       |
|  `.refm`   | Wraps with `&mut ?`.                                        |       `expr`       |
|   `.ok`    | Wraps with `Ok(?)`.                                         |       `expr`       |
|   `.err`   | Wraps with `Err(?)`.                                        |       `expr`       |
|  `.some`   | Wraps with `Some(?)`.                                       |       `expr`       |
| `.println` | Wraps with `println!("{:?}", ?)`.                           |       `expr`       |

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
