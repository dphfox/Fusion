Fusion tries to handle your code in the smartest way it can. To help achieve the
best performance, you can give Fusion more information about what you're trying
to do, or avoid a few problematic scenarios that slow Fusion down.

-----

## Update Skipping

Fusion tries to skip updates when they result in 'meaningless changes'.

!!! summary "TL;DR"
	When your computations return values that aren't meaningfully different,
	Fusion doesn't bother to perform further updates.

	However, Fusion can't automatically do this for tables. So, you should 
	freeze every table you create, unless you need to change what's inside the 
	table later (for example, if it's a list that changes over time).
	
	This allows Fusion to apply more aggressive optimisations for free.

### Example

Imagine you have a number, and you're using a computed to calculate whether it's
even or odd.

An observer is used to see how often this results in other code being run.

=== "Luau code"

	```Lua
	local number = scope:Value(1)
	local isEven = scope:Computed(function(use)
		return use(number) % 2 == 0
	end)
	scope:Observer(isEven):onChange(function()
		print("-> isEven has changed to " .. peek(isEven))
	end)

	print("Number becomes 2")
	number:set(2)
	print("Number becomes 3")
	number:set(3)
	print("Number becomes 13")
	number:set(13)
	print("Number becomes 14")
	number:set(14)
	print("Number becomes 24")
	number:set(24)
	```

=== "Output"

	```
	Number becomes 2
	-> isEven has changed to true
	Number becomes 3
	-> isEven has changed to false
	Number becomes 13
	Number becomes 14
	-> isEven has changed to true
	Number becomes 24
	```

Notice that the observer only runs when `isEven` returns a meaningfully
different value:

- When the number changed from 2 to 3, `isEven` returned `false`. This is
meaningfully different from the previous value of `isEven`, which was `true`.
As a result, the observer is run and the printed message is seen.

- When the number changed from 3 to 13, `isEven` returned `false`. This is *not*
meaningfully different from the previous value of `isEven`, which was `false`.
As a result, the observer does not run, and no printed message is seen.

### Similarity

When trying to determine if a change is 'meaningless', Fusion compares the old
and new values, using what's called the *similarity test*.

The similarity test is a fast, approximate test that Fusion uses to guess which
updates it can safely discard. If two values pass the similarity test, then you
should be able to use them interchangeably without affecting most Luau code.

In Fusion's case, if the values before and after a change are similar, then
Fusion won't continue updating other code beyond that change, because those
updates aren't likely to have an effect on the outcome of computations.

Here's what the similarity test looks for:

- Different types:
	- Two values of different types are never similar to each other.
- Tables:
    - Frozen tables are similar to other values when they're `==` to each other.
	- Tables with a metatable are similar to other values when when they're `==`
	to each other.
	- Other kinds of table are never similar to anything.
- Userdatas:
    - Userdatas are similar to other values when they're `==` to each other.
- NaN:
	- If each value does not `==` itself, then the two values are similar to 
	each other.
	- *This doesn't apply to tables or userdatas.*
- Any other values:
	- Two values are similar to each other when they're `==` to each other.

!!! note "Roblox data types"
	Roblox data types are not considered to be userdatas. Instead, the 
	similarity test follows `typeof()` rules when determining type.


### Optimising For Similarity

With this knowledge about the similarity test, you can experiment with how 
Fusion optimises different changes, and what breaks that optimisation.

#### Tables

Imagine you're setting a value object to a table of theme colours. You attach
an observer object to see when Fusion thinks the theme meaningfully changed.

=== "Luau code"

	```Lua
	local LIGHT_THEME = {
		name = "light",
		-- imagine theme colours in here
	}
	local DARK_THEME = {
		name = "dark",
		-- imagine theme colours in here
	}
	local currentTheme = scope:Value(LIGHT_THEME)
	scope:Observer(currentTheme):onChange(function()
		print("-> currentTheme changed to " .. peek(currentTheme).name)
	end)

	print("Set to DARK_THEME")
	currentTheme:set(DARK_THEME)
	print("Set to DARK_THEME")
	currentTheme:set(DARK_THEME)
	print("Set to LIGHT_THEME")
	currentTheme:set(LIGHT_THEME)
	print("Set to LIGHT_THEME")
	currentTheme:set(LIGHT_THEME)
	```

=== "Output"

	```
	Set to DARK_THEME
	-> currentTheme changed to dark
	Set to DARK_THEME
	-> currentTheme changed to dark
	Set to LIGHT_THEME
	-> currentTheme changed to light
	Set to LIGHT_THEME
	-> currentTheme changed to light
	```

Because the `LIGHT_THEME` and `DARK_THEME` tables aren't frozen, and they don't
have any metatables, Fusion will never skip over updates that change to or from
those values.

??? question "Why won't Fusion skip those updates?"
	In Fusion, it's common to update arrays without creating a new array. This
	is known as *mutating* the array.

	```Lua
	local drinks = scope:Value({"beer", "pepsi"})

	do -- add tea
		local array = peek(drinks)
		table.insert(array, "tea") -- mutation occurs here
		drinks:set(array) -- still the same array, so it's ==
	end
	```

	If Fusion skipped updates when the old and new values were `==`, then these
	mutating changes wouldn't cause an update.

	For that reason, Fusion doesn't skip updates for tables unless you do one
	of two things:

	- You disable the ability to mutate the table (via `table.freeze`).
	- You indicate to Fusion that this isn't plain data by adding a metatable.
		- Metatables are almost always used for OOP, where `==` is a sensible
		way of determining if two objects are similar.
		- You can also use metatables to define how equality should work, which
		Fusion will respect - though Fusion expects it to be symmetric.

According to the similarity test (and the question section above), one way to
skip these updates is by freezing the original tables.

=== "Luau code"

	```Lua hl_lines="1 5"
	local LIGHT_THEME = table.freeze {
		name = "light",
		-- imagine theme colours in here
	}
	local DARK_THEME = table.freeze {
		name = "dark",
		-- imagine theme colours in here
	}
	local currentTheme = scope:Value(LIGHT_THEME)
	scope:Observer(currentTheme):onChange(function()
		print("-> currentTheme changed to " .. peek(currentTheme).name)
	end)

	print("Set to DARK_THEME")
	currentTheme:set(DARK_THEME)
	print("Set to DARK_THEME")
	currentTheme:set(DARK_THEME)
	print("Set to LIGHT_THEME")
	currentTheme:set(LIGHT_THEME)
	print("Set to LIGHT_THEME")
	currentTheme:set(LIGHT_THEME)
	```

=== "Output"

	```
	Set to DARK_THEME
	-> currentTheme changed to dark
	Set to DARK_THEME
	Set to LIGHT_THEME
	-> currentTheme changed to light
	Set to LIGHT_THEME
	```

Now, Fusion is confident enough to skip over the updates.

In general, you should freeze all of your tables when working with Fusion,
unless you have a reason for modifying them later on. There's almost zero cost
to freezing a table, making this modification essentially free. Plus, this lets
Fusion optimise your updates more aggressively, which means you spend less time
running computations on average.