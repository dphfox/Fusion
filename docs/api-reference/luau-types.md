Fusion exposes some public Luau types for developers working with strictly typed
codebases. These types are exported from the Fusion module directly.

!!! bug "In Development"
	These Luau types are still experimental - they're not done yet.

-----

## `Symbol`

Represents a named symbol. Symbols are named constants which carry special
meaning.

In Fusion, symbols are commonly used for special keys, such as
[Children](/api-reference/children) or [OnEvent](/api-reference/onevent).

```Lua
local example: Symbol = Fusion.Children
```