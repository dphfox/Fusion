Now that you understand how Fusion works with objects, you can create Fusion's
simplest object.

Values are objects which store single values. You can write to them with
their `:set()` method, and read from them with the `peek()` function.

```Lua
local health = scope:Value(100)

print(peek(health)) --> 100
health:set(25)
print(peek(health)) --> 25
```

-----

## Usage

To create a new value object, call `scope:Value()` and give it a value you want
to store.

```Lua linenums="2" hl_lines="5"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped

local scope = scoped(Fusion)
local health = scope:Value(5)
```

Fusion provides a global `peek()` function. It will read the value of whatever
you give it. You'll use `peek()` to read the value of lots of things; for now,
it's useful for printing `health` back out.

```Lua linenums="2" hl_lines="3 7"
local Fusion = require(ReplicatedStorage.Fusion)
local doCleanup, scoped = Fusion.doCleanup, Fusion.scoped
local peek = Fusion.peek

local scope = scoped(Fusion)
local health = scope:Value(5)
print(peek(health)) --> 5
```

You can change the value using the `:set()` method. Unlike `peek()`, this is
specific to value objects, so it's done on the object itself.

```Lua linenums="6" hl_lines="5-6"
local scope = scoped(Fusion)
local health = scope:Value(5)
print(peek(health)) --> 5

health:set(25)
print(peek(health)) --> 25
```

??? tip "`:set()` returns the value you give it"
	You can use `:set()` in the middle of calculations:

	```Lua
	local myNumber = scope:Value(0)
	local computation = 10 + myNumber:set(2 + 2)
	print(computation) --> 14
	print(peek(myNumber)) --> 4
	```

	This is useful when building complex expressions. On a later page, you'll
	see one such use case.

	Generally though, it's better to keep your expressions simple.

Value objects are Fusion's simplest 'state object'. State objects contain a
single value - their *state*, you might say - and that single value can be read
out at any time using `peek()`.

Later on, you'll discover more advanced state objects that can calculate their
value in more interesting ways.