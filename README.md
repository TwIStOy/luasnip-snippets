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
<summary>Cpp</summary>

#### Normal Snippets

|    Trig     | Desc                                                                                             | Context Required |
| :---------: | ------------------------------------------------------------------------------------------------ | :--------------: |
|    `fn`     | Expand to lambda function in argument list or function body, otherwise expand to normal function |        No        |
|  `\|trans`  | Expand to ranges::views::transform pipe.                                                         |        No        |
| `\|filter`  | Expand to ranges::views::filter pipe.                                                            |        No        |
|    `cpo`    | Expand to customize point object.                                                                |        No        |
| `ns%s(%S+)` | Expand to namespace block (including comments).                                                  |        No        |
|    `itf`    | Expand to a struct with default virtual destruction.                                             |        No        |
|    `pvf`    | Expand to a pure virtual function declaration.                                                   |        No        |

#### Auto-snippets

|   Trig   | Desc                                                     |       Context Required        |
| :------: | -------------------------------------------------------- | :---------------------------: |
| `ctor!`  | Expand to default constructor                            |           In Class            |
| `dtor!`  | Expand to default destructor                             |           In Class            |
|  `cc!`   | Expand to default copy constructor                       |           In Class            |
|  `mv!`   | Expand to default move constructor                       |           In Class            |
|  `ncc!`  | Expand to delete copy constructor                        |           In Class            |
|  `nmv!`  | Expand to delete move constructor                        |           In Class            |
|  `ncm!`  | Expand to delete copy and move constructor               |           In Class            |
|  `once`  | Expand to `pragma once` marker at the front of the file. | All lines before are comments |
|   `u8`   | Expand to `uint8_t`.                                     |              No               |
|  `u16`   | Expand to `uint16_t`.                                    |              No               |
|  `u32`   | Expand to `uint32_t`.                                    |              No               |
|  `u64`   | Expand to `uint64_t`.                                    |              No               |
|   `i8`   | Expand to `int8_t`.                                      |              No               |
|  `i16`   | Expand to `int16_t`.                                     |              No               |
|  `i32`   | Expand to `int32_t`.                                     |              No               |
|  `i64`   | Expand to `int64_t`.                                     |              No               |
| `t(%s)!` | Evaluate (QET) marker, and expand to typename.           |              No               |
|   `#"`   | Expand to include statement with quotes. `#include ""`.  |              No               |
|   `#<`   | Expand to include statement with `<>`. `#include <>`.    |              No               |

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

|   Trig    | Desc (placehoder: `?`)                                             | Expr before cursor |
| :-------: | ------------------------------------------------------------------ | :----------------: |
|   `.be`   | Expand to begin and end exprs                                      |     `any_expr`     |
|   `.mv`   | Wraps with `std::move(?)`                                          |     `any_expr`     |
|  `.fwd`   | Wraps with `std::forward<decltype(?)>(?)`                          |     `any_expr`     |
|  `.val`   | Wraps with `std::declval<?>()`                                     |     `any_expr`     |
|   `.dt`   | Wraps with `decltype(?)`                                           |     `any_expr`     |
|   `.uu`   | Wraps with `(void)?`                                               |     `any_expr`     |
|   `.ts`   | Switch indent's coding style between `CamelCase` and `snake_case`. |      `indent`      |
|   `.sc`   | Wraps with `static_cast<>(?)`                                      |     `any_expr`     |
| `.single` | Wraps with `ranges::views::single(?)`                              |     `any_expr`     |
|   `.in`   | Expands to `if (...find)` statements.                              |     `any_expr`     |

</details>

<details>
<summary>Rust</summary>

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

|    Trig    | Desc (placehoder: `?`)                                     | Expr before cursor |
| :--------: | ---------------------------------------------------------- | :----------------: |
|   `.rc`    | Wraps with `Rc::new(?)` if expr, `Rc<?>` if type           |   `expr_or_type`   |
|   `.arc`   | Wraps with `Arc::new(?)` if expr, `Arc<?>` if type         |   `expr_or_type`   |
|   `.box`   | Wraps with `Box::new(?)` if expr, `Box<?>` if type         |   `expr_or_type`   |
|   `.mu`    | Wraps with `Mutex::new(?)` if expr, `Mutex<?>` if type     |   `expr_or_type`   |
|   `.rw`    | Wraps with `RwLock::new(?)` if expr, `RwLock<?>` if type   |   `expr_or_type`   |
|  `.cell`   | Wraps with `Cell::new(?)` if expr, `Cell<?>` if type       |   `expr_or_type`   |
| `.refcell` | Wraps with `RefCell::new(?)` if expr, `RefCell<?>` if type |   `expr_or_type`   |
|   `.ref`   | Wraps with `&?`                                            |       `expr`       |
|  `.refm`   | Wraps with `&mut ?`                                        |       `expr`       |
|   `.ok`    | Wraps with `Ok(?)`                                         |       `expr`       |
|   `.err`   | Wraps with `Err(?)`                                        |       `expr`       |
|  `.some`   | Wraps with `Some(?)`                                       |       `expr`       |
| `.println` | Wraps with `println!("{:?}", ?)`                           |       `expr`       |

</details>
