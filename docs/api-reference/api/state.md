<span class="fusion-typeset-api-path">Fusion.state</span>

!!! todo
	Link to the state tutorial in the Basics section when it's done

```Lua
function state(initialValue: any) : State
```
Constructs and returns a reactive state object, with a value that can be set and got.

If an `initialValue` is specified, the state object will be initialised storing that value.

-----

## Overview

State objects are the fundamental building block of Fusion's state management system.
They hold a single value - much like a variable - and this value can be set or got at any time.

```Lua
-- creating a state object
-- you can give it an initial value here - in this case, 2
local number = state(2)

-- get the value and print it
print(number:get()) --> 2

-- set the value to 5
number:set(5)

-- short syntax for getting the value
-- this is the preferred way of getting the value
print(number()) --> 5
```

The key feature of state objects is that they're *observable*; when a script sets the value of
a state object, other scripts can be notified and respond to the change immediately.

Fusion lets you tap into that feature in your own scripts using [computeds](/api-reference/computed)
and [effects](/api-reference/effect). While inside the callback of a computed or effect, Fusion
will keep track of which state objects you get the value of. Then, it'll listen for changes in
any of those state objects. If any of them change, the callback will be run again.

```Lua
-- this counter will increase over time
-- it's important to keep any non-constant values in state objects
local counter = state(0)

-- Fusion will run this calculation every time `counter` changes
local counterPlusOne = computed(function()
	return counter() + 1
end)

-- Fusion will run this function every time `counterPlusOne` changes
effect(function()
	print(counterPlusOne())
end)
```

For a more comprehensive overview of state management within Fusion,
visit the state management tutorial.

-----

## Object Methods

### get()

```Lua
function State:get() : any
```

Returns the value currently stored in this state object.
If used in a reactive context (e.g. in an computed's callback), this state object is added
as a dependency.

!!! tip
	While this method can be called directly, it's conventionally preferred to call the state object
	itself to get the value instead:

	```Lua
	local counter = state(5)

	-- normal syntax
	print(state:get()) --> 5

	-- short syntax (preferred)
	print(state()) --> 5
	```

	Using this shorter syntax often leads to much cleaner and easier to read code.

	This method is mainly exposed as a fallback for when the shorter syntax may not be suitable
	(for example, if the shorter syntax causes trouble with strict typed Luau). 

### set()

```Lua
function State:set(newValue: any)
```

Stores the given value in this state object.

If the new value is different from the old value, and other reactive objects depend on this
state object, then they will be notified of the change in topological order.

-----

## See Also

- [computed()](/api-reference/computed)
- [effect()](/api-reference/effect)