# Fusion Style Guide

These guidelines should be followed for all Lua code inside of Fusion.

The rules and guidelines set out here are derived from Roblox's style guide,
which can be found here: https://roblox.github.io/lua-style-guide/

## Guiding Principles

- The purpose of this style guide is to avoid arguments.
	- There's no one right answer to how to format code, but consistency is
	important. We agree to accept this one, somewhat arbitrary standard so we
	can spend more time writing code and less time arguing about formatting
	details.

- Optimise code for reading, not writing.
	- You will write your code once. However, it will be read many times by many
	people, likely including yourself long after you've forgotten how it works.
	- For this reason, it's important to streamline figuring out how the code
	works, since you will have to do this many times.
	- All else being equal, consider what the diffs might look like. It's much
	easier to read a diff that doesn't involve moving things between lines.
	Clean diffs make it much easier to review code.

- Avoid magic, such as surprising or dangerous Lua features.
	- Magical code is really nice to use, until something goes wrong. Then
	nobody knows why it's broken or how to fix it.
	- Metatables and `getfenv`/`setfenv` are examples of powerful features that
	should be used with care.

- Be consistent with idiomatic Lua when appropriate.

## Folder Structure
- Scripts should be grouped into folders, to make it easier to navigate the
codebase.

## Script Structure

All scripts should consist of these things (if present) in order:

1) A block comment talking about why this file exists, or documenting it's
functionality.
	- Don't add the file name, author or date - those are things that our
	version control can tell us.
2) Services used by the file, using `GetService`.
	- This includes services such as `Workspace` or `Lighting` - consistency is
	important!
3) Imported modules, using `require`.
	- Modules from the same folder or location should stay next to each other.
4) Script-level constants.
5) Script-level variables and functions.
6) (for ModuleScripts) The object returned by the module.
7) (for ModuleScripts) The return statement.

## Requires

- `require` calls should be at the top of the file, making dependencies static.
	- If there's an issue with two modules requiring each other cyclically, the
	structure of that code needs to be reconsidered.
- When requiring a module inside Fusion's source code, use relative paths. To
keep these paths clean, use a variable called `Package` to store where the root
of the library is.
	- This makes it clear where to find the source of the module within the
	source code.
	```Lua
	local Package = script.Parent.Parent
	local Foo = require(Package.Utils.Foo)
	local Bar = require(Package.Reactive.Bar)
	```
- Elsewhere, prefer absolute paths when requiring modules:
	```Lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Foo = require(ReplicatedStorage.Foo)
	```

## Metatables

Metatables are an incredibly powerful Lua feature that can be ued to overload
operators, implement prototypical inheritance, and tinker with limited object
lifecycle. However, they can also cause unexpected or surprising behaviour, and
so they should be used very sparingly, and only if you know what you're doing.

When using metatables, they should be sufficiently documented, normally by
adding comments explaining the purpose and intended function of a metatable.

Some common uses of metatables are described below. Keep in mind that Fusion
often has ready-to-go implementations of many of these; those should always be
preferred over manual implementations.

### OOP classes

Metatables are commonly used to implement prototype-based classes in Lua. Fusion
implements classes in a way which is designed to avoid cyclic metatables, by
separating the constructor from class methods.

Start by creating a blank table, conventionally called `class`:

```Lua
local class = {}
```

We can then define a constructor function for creating new objects of the
class. To create a new object of the class, create a new table, and apply a
metatable with `__index` set to `class`. That way, when indexing the
object, it'll fall back to the `class` table if no member was found.

Since this constructor is normally used as the return value of the module it's
in, it should adopt the module's name, as dictated by the naming conventions:

```Lua
local function MyClass()
	-- create a table to serve as our object, and use a metatable to fall back
	-- to `class` for missing fields.
	local self = setmetatable({}, {__index = class})

	-- define some members here
	self.phrase = "bark"

	-- return the object
	return self
end
```

We can define methods that operate on objects, using a colon (`:`) to take
advantage of Lua's syntactic sugar for objects:

```Lua
-- equivalent to: `function class.bark(self)`
function class:bark()
	print("My phrase is", self.phrase)
end
```

At this point, our class is ready to use! We can construct new objects and
start tinkering with it:

```Lua
local myObject = MyClass()

-- object members are visible, since it's just a table:
print(myObject.phrase) --> bark

-- methods are pulled from `object` because of our metatable:
myObject:bark() --> My phrase is bark

```

Some further additions you can make to your class as needed:

- Introduce a `__tostring` metamethod to make debugging easier
- Add a `type` string to objects of your class - this is used to differentiate
objects of different class types

### Guarding against typos

Indexing into a table in Lua gives you `nil` if the key isn't present, which can
cause errors that are difficult to trace!

Another major use case for metatables is to prevent certain forms of this
problem. For types that act like enums, we can carefully apply an `__index`
metamethod that throws an error when an invalid member is accessed:

```Lua
local MyEnum = {
	A = "A",
	B = "B",
	C = "C"
}

setmetatable(myEnum, {
	__index = function(self, key)
		error(string.format("%s is not a valid member of MyEnum",
			tostring(key)), 2)
	end
})
```

Since `__index` is only called when a key is missing in the table, `MyEnum.A`
and `MyEnum.B` will still give you back the expected values, but `MyEnum.FROB`
will throw, hopefully helping contributors track down bugs more easily.

### Limiting writes

As a safety measure, it's often desirable to 'lock' tables, so they can't be
written to. This is usually done with enums or public API members.

To prevent scripts from writing to new indexes, we can apply the `__newindex`
metamethod to the table:

```Lua
local myTable = {
	foo = "2",
	bar = true
}

setmetatable(myTable, {
	__newindex = function(self, key, value)
		error("myTable is not writable", 2)
	end
})
```

Note that, because `__newindex` only fires when writing to a `nil` index, this
won't prevent writes to indexes with non-`nil` values. Also, keep in mind that
assigning `nil` to an index after adding the metamethod makes that index
read-only.

## General Punctuation

- Don't use semicolons (`;`). They are generally only useful to separate
multiple statements on a single line, but you shouldn't be putting multiple
statements on a single line anyway.
	- This includes using semicolons in tables; prefer to use commas (`,`) to
	delimit values in tables.
- In comments and other documentation, use backticks when referencing code,
and indentation when embedding longer blocks of code
	```Lua
	-- `foo` will be set to `5 + os.clock()`
	local foo = 5 + os.clock()

	--[[
		An example implementation of a function using `os.clock()`:

			local function getMinutes()
				local now = os.clock()

				return math.floor(now / 60)
			end

		The above code returns the integer number of minutes since the epoch.
	]]
	```

## General Whitespace

- Indent with tabs, not spaces.
	- Tabs use less characters than spaces do, and allows contributors to change
	the tab size to their preference in their editor of choice.
- Keep lines under 120 columns wide, assuming 4-wide tabs.
- Wrap comments to 80 columns wide, assuming 4-wide tabs.
	- This is different from normal code; the hope is that short lines help to
	improve readability of comment prose, but is too restrictive for code.
- Don't leave whitespace at the end of lines.
	- If your editor has an auto-trimming function, turn it on!
- Add a newline at the end of the file.
- Don't align code vertically; it makes code more difficult to edit and often
gets messed up by subsequent editors.
	```Lua
	-- Good:
	local frobulator = 12345
	local grog = 17

	-- Bad:
	local frobulator = 12345
	local grog       =    17
	```
- Use a single empty line to express groups when useful. Don't start blocks with
a blank line. Excess empty lines harm the readability of the whole file.
	```Lua
	local Foo = require(Package.Utils.Foo)

	local function gargle()
		-- gargle gargle
	end

	Foo.frobulate()
	Foo.frobulate()

	Foo.munge()
	```
- Use one statement per line. Put function bodies on new lines.
	- This is especially true for functions that return multiple values. It's
	much easier to spot mistakes (and harder to make the mistake in the first
	place) if the function isn't on one line.
	- This is also true for `if` blocks, even if their body is just a return
	statement.
	- This also helps code diff better.
	```Lua
	-- Good:
	table.sort(stuff, function(a, b)
		local sum = a + b
		return math.abs(sum) > 2
	end)

	-- Bad:
	table.sort(stuff, function(a, b) local sum = a + b return math.abs(sum) > 2 end)
	```
- Put a space between operators, except when clarifying precedence.
	```Lua
	-- Good:
	print(5 + 5 * 6^2)

	-- Bad:
	print(5+5* 6 ^2)
	```
- Put a space after commas in tables and function calls.
	```Lua
	-- Good:
	local friends = {"bob", "amy", "joe"}
	foo(5, 6, 7)

	-- Bad:
	local friends = {"bob","amy" ,"joe"}
	foo(5,6 ,7)
	```
- When creating blocks, inline any opening syntax elements.
	```Lua
	-- Good:
	local foo = {
		bar = 2,
	}

	if foo then
		-- do something
	end

	-- Bad:
	local foo =
	{
		bar = 2,
	}

	if foo
	then
		-- do something
	end
	```
- Avoid putting curly braces for tables on their own line. Doing so harms
readability, since it forces the reader to move to another line in an awkward
spot in the statement.
	```Lua
	-- Good:
	local foo = {
		bar = {
			baz = "baz",
		},
	}

	frob({
		x = 1,
	})

	-- Bad:
	local foo =
	{
		bar =

		{
			baz = "baz",
		},
	}

	frob(
	{
		x = 1,
	})

	-- Exception:
	-- In function calls with large inline tables or functions, sometimes it's
	-- more clear to put braces and functions on new lines:
	foo(
		{
			type = "foo",
		},
		function(something)
			print("Hello," something)
		end
	)

	-- As opposed to:
	foo({
		type = "foo",
	}, function(something) -- How do we indent this line?
		print("Hello,", something)
	end)
	```
### Newlines in Long Expressions
- First, try and break up the expression so that no one part is long enough to
need newlines. This isn't always the right answer, as keeping an expression
together is sometimes more readable than trying to parse how several small
expressions relate, but it's worth pausing to consider which case you're in.

- It is often worth breaking up tables and arrays with more than two or three
keys, or with nested sub-tables, even if it doesn't exceed the line length
limit. Shorter, simpler tables can stay on one line though.

- Prefer adding the extra trailing comma to the elements within a multiline
table or array. This makes it easier to add new items or rearrange existing
items.

- Break dictionary-like tables with more than a couple keys onto multiple lines.
	```Lua
	-- Good:
	local foo = {type = "foo"}

	local bar = {
		type = "bar",
		phrase = "hooray",
	}

	-- It's also okay to use multiple lines for a single field
	local baz = {
		type = "baz",
	}

	-- Bad:
	local stuff = {hello = "world", hola = "mundo", howdy = "y'all", sup = "homies"}
	```
- Break list-like tables onto multiple lines however it makes sense.
	- Make sure to follow the line length limit!
	```Lua
	local libs = {"fusion", "luau", "class", "maid", "event"}

	-- You can break these onto multiple lines, which makes diffs cleaner:
	local libs = {
		"fusion",
		"luau",
		"class",
		"maid",
		"event",
	}

	-- We can also group them, if grouping has useful information:
	local libs = {
		"fusion", "luau",

		"class", "maid", "event"
	}
	```
- For long argument lists or longer, nested tables, prefer to expand all the
subtables. This makes for the cleanest diffs as further changes are made.
	```Lua
	local aTable = {
		{
			aLongKey = aLongValue,
			anotherLongKey = anotherLongValue,
		},
		{
			aLongKey = anotherLongValue,
			anotherLongKey = aLongValue,
		},
	}

	doSomething(
		{
			aLongKey = aLongValue,
			anotherLongKey = anotherLongValue,
		},
		{
			aLongKey = anotherLongValue,
			anotherLongKey = aLongValue,
		}
	)
	```
- For long expressions try and add newlines between logical subunits. If you're
adding up lots of terms, place each term on its own line. If you have
parenthesized subexpressions, put each subexpression on a newline.

	- Place the operator at the beginning of the new line. This makes it clearer
	at a glance that this is a continuation of the previous line.

	- If you have to need to add newlines within a parenthesized subexpression,
	reconsider if you can't use temporary variables. If you still can't, add a
	new level of indentation for the parts of the statement inside the open
	parentheses much like you would with nested tables.

	- Don't put extra parentheses around the whole expression. This is necessary
	in Python, but Lua doesn't need anything special to indicate multiline
	expressions.

- For long conditions in `if` statements, put the condition in its own indented
section and place the `then` on its own line to separate the condition from the
body of the `if` block. Break up the condition as any other long expression.
	```Lua
	-- Good:
	if
		someReallyLongCondition
		and someOtherReallyLongCondition
		and somethingElse
	then
		doSomething()
		doSomethingElse()
	end

	-- Bad:
	if someReallyLongCondition and someOtherReallyLongCondition
		and somethingElse then
		doSomething()
		doSomethingElse()
	end

	if someReallyLongCondition and someOtherReallyLongCondition
			and somethingElse then
		doSomething()
		doSomethingElse()
	end

	if someReallyLongCondition and someOtherReallyLongCondition
		and somethingElse then
			doSomething()
			doSomethingElse()
	end
	```

## Blocks

- Don't use parentheses around the conditions in `if`, `while`, or `repeat`
blocks. They're not necessary in Lua!
	```Lua
	if condition then
		-- ...
	end

	while condition do
		-- ...
	end

	repeat
		-- ...
	until condition
	```
- Use `do` blocks if limiting the scope of a variable is useful.
	```Lua
	local getId
	do
		local lastId = 0
		getId = function()
			lastId += 1
			return lastId
		end
	end
	```

## Literals

- Use double quotes when declaring single-line string literals.
	- Using single quotes means we have to escape apostrophes, which are often
	useful in English words.
	- Empty strings are easier to identify with double quotes, because in some
	fonts two single quotes might look like a single double quote.
- Use brackets (`[[` and `]]`) when declaring multi-line string literals.
	- Don't indent multi-line string literals, as the tab characters will be
	interpreted as part of the string!
	```Lua
	print("Here's a message")

	print([[
	This is a longer message, which is designed to span multiple lines to
	demonstrate how multi-line strings work.
	]])
	```

## Tables

- Avoid tables with bost list-like and dictionary-like keys.
	- Iterating over these mixed tables is troublesome.
	- If you do end up using mixed tables, make sure to 'unmix' the array part
	from the dictionary part as soon as possible to minimise possible bugs.
- Iterate over list-like tables with `ipairs` and dictionary-like tables with
`pairs`.
	- This helps clarify what kind of table we're expecting in a given block of
	code!

## Functions

- Keep the number of arguments to a given function small, preferably 1 or 2.
- Similarly, keep the number or returned values from a function small.
- When calling a function, you may only omit parentheses when passing in a
dictionary-like table.
	- Omitting parentheses when passing in an array-like table can cause some
	confusion, as the curly braces may look like parentheses at a glance, hiding
	that a table is being passed.
	- This isn't a problem with dictionary-like tables. In fact, this is a
	common pattern in Fusion, where constructors for primitives are often
	called this way.
	```Lua
	-- Good:
	local x = doSomething("home")
	local y = doSomething({1, 2, 3, 4, 5})
	local z = doSomething({foo = 2, bar = "frob"})

	-- omitting parentheses is only OK for dictionary-like tables
	local w = doSomething {
		foo = 2,
		bar = "frob"
	}

	-- Bad:
	local x = doSomething "home"
	local y = doSomething {1, 2, 3, 4, 5}
	```
- Declare named functions using function-prefix syntax. Non-member functions
should always be local.
	- An exception can be made for late-initializing functions, for example in
	conditionals.
	```Lua
	-- Good:
	local function add(a, b)
		return a + b
	end

	-- Bad:
	function add(a, b)
		return a + b
	end

	local add = function(a, b)
		return a + b
	end

	-- Exception:
	local doSomething

	if CONDITION then
		function doSomething()
			-- Version of doSomething with CONDITION enabled
		end
	else
		function doSomething()
			-- Version of doSomething with CONDITION disabled
		end
	end
	```
- When declaring a function inside a table, use function-prefix syntax. Use
a dot (`.`) or colon (`:`) to denote intended calling convention.
	```Lua
	-- Good:
	-- This function should be called as Frobulator.new()
	function Frobulator.new()
		return {}
	end

	-- This function should be called as Frobulator:frob()
	function Frobulator:frob()
		print("Frobbing", self)
	end

	-- Bad:
	function Frobulator.garb(self)
		print("Frobbing", self)
	end

	Frobulator.jarp = function()
		return {}
	end
	```

## Comments

- Wrap comments to 80 columns wide.
	- It's easier to read comments with shorter lines, but fitting code into 80
	columns can be challenging.
- Use single line comments for inline notes.
	- If the comment spans multiple lines, use multiple single line comments.
	```Lua
	-- This condition is really important because the world would blow up if it
	-- were missing.
	if not foo then
		stopWorldFromBlowingUp()
	end
	```
- Use block comments for documenting items:
	- Use a block comment at the top of files to describe their purpose.
	- Use a block comment before functions or objects to describe their intent.
	```Lua
	--[[
		Shuts off the cosmic moon ray immediately.

		Should only be called within 15 minutes of midnight Mountain Standard
		Time, or the cosmic moon ray may be damaged.
	]]
	local function stopCosmicMoonRay()
	end
	```
- Comments should focus on *why* code is written a certain way, instead of
*what* the code is doing.
	```Lua
	-- Good:
	-- Without this condition, the aircraft hangar would fill up with water.
	if waterLevelTooHigh() then
		drainHangar()
	end

	-- Bad:
	-- Check if the water level is too high.
	if waterLevelTooHigh() then
		-- Drain the hangar
		drainHangar()
	end
	```
- No section comments.
	- Comments that only exist to break up a large file are a code smell; you
	probably need to find some way to make your file smaller instead of working
	around that problem with section comments.
	- Comments that only exist to demark already obvious groupings of code
	(e.g. `--- VARIABLES ---`) and overly stylized comments can actually make
	the code harder to read, not easier.
	- Additionally, when writing section headers, you (and anyone else editing
	the file later) have to be thorough to avoid confusing the reader with
	questions of where sections end.
	- Some examples of other ways of breaking up files:
		- Move inner classes and static functions into their own files, which
		aren't included in the public API. This also makes testing those classes
		and functions easier.
		- Check if there are any existing libraries that can simplify your code.
		If you're writing something and think that you could make part of this
		into a library, there's a good chance someone already has.
	- If you can't break the file up, and still feel like you need section
	headings, consider these alternatives:
		- If you want to put a section header on a group of functions, put that
		information in a block comment attached to the first function in that
		section. You should still make sure the comment is about the function
		its attached to, but it can also include information about the section
		as a whole. Try and write the comment in a way that makes it clear
		what's included in the section.
			```Lua
			--[[
				All of the readX functions return the next token from the string
				passed in to the Reader or returns nil if the next token doesn't
				match the type the function is trying to read.

				local test = "123 ABC"
				i = reader:readInt()
				print(i, ",", test.remaining) -- 123 , ABC

				readInt reads an integer, positive or negative.
			]]
			function Reader:readInt() -- ...

			-- readFloat reads a floating point number, but does not accept
			-- scientific notation
			function Reader:readFloat() -- ...
			```
		- The same can be done for a group of variables in some cases. All the
		same caveats apply though, and you have to consider whether one block
		comment or a normal comment on each variable (or even using just
		whitespace to separate groups) would be more readable.
		- General organization of your code can aid readibility while making
		logical sections more obvious as well. Module level variables and
		functions can appear in any order, so you can sometimes put a group of
		variables above a group of functions to make a section.

## Naming

- Spell out words fully! Abbreviations generally make code easier to write, but
harder to read.
	- Make sure that names don't get too long, however! Extremely long names can
	also be detrimental to code readability.
- Avoid single-letter names; names should be adequately descriptive.
	- An exceptions to this rule are coordinates, e.g. `x`, `y` and `z`
		- In code working with multiple coordinate spaces (e.g. object and world
		space), or a combination of Offset and Scale (for UDims), this is less
		acceptable. Prefer prefixed names in those cases, for example `objectX`
		and `worldY`.
	- Another exception is generics in typed Luau, e.g. `type Foo<T> = () -> T`
	```Lua
	-- Good:
	local function isFrob(value)
		return tostring(value) == "frob"
	end

	for index, value in pairs(garb) do
		print(index, "=", value)
	end

	-- Bad:
	local function isFrob(x)
		return tostring(x) == "frob"
	end

	for i, v in pairs(garb) do
		print(i, "=", v)
	end
	```
- Use `PascalCase` for all Roblox APIs.
	- `camelCase` APIs are mostly deprecated, but still work for now.
- Use `PascalCase` for enum-like objects.
- Use `PascalCase` for named Luau type definitions.
- Use `PascalCase` for functions that construct class objects - this is in line
with how classes are conventionally named:
	```Lua
	-- Good:
	local foo = State(5)
	local bar = Maid()

	-- Bad:
	local foo = state(5)
	local bar = maid()
	```
- Use `camelCase` for variables, member values and functions.
- Use `LOUD_SNAKE_CASE` for constants.
- For acronyms within names, don't capitalise the whole thing. For example,
`aJsonVariable` or `MakeHttpCall`.
	- The exception to this is when the abbreviation represents a set. For
	example, in `myRGBValue` or `GetXYZ`. In those cases, `RGB` should be
	treated as an abbreviation of 'Red Green Blue' and not as an acronym.
- If a member of a class is private, prefix it with one underscore, for example
`_foob`.
	- Lua does not have visibility rules, but using underscores helps make
	private access stand out.
- A file's name should match the name of whatever it exports.
	- If your module exports a single function named `doSomething`, the file
	should be named `doSomething.lua`.

## Yielding

Don't call yielding functions on the main thread. Wrap them in `coroutine.wrap`
or `delay`, and consider exposing a Promise or Promise-like async interface for
your own functions.

Unintended yielding can cause hard-to-track data races. Simple code
involving callbacks can cause confusing bugs if the input callback yields:
```Lua
local value = 0

local function doSomething(callback)
	local newValue = value + 1
	callback(newValue)
	value = newValue
end
```

Similarly, if a callback is not allowed to yield, your code should check that it
doesn't yield, so the error can be caught early on. Fusion provides utility
functions to assert a callback doesn't yield while it's running.

## Error Handling

When writing functions that are expected to fail sometimes, return
`success, result`, use a `Result` type, or use an async primitive that encodes
failure, like `Promise`.

Avoid throwing errors unless your code encounters something that might be a bug -
errors are not encoded into a function's contract explicitly, so your caller
isn't forced to consider whether an error will happen, and how any errors
should be dealt with.
```Lua
-- Good:
-- type checking should throw an error, since incorrect types is likely a bug
assert(typeof(number) == "number", "Must pass number to function")
if foo < 0 then
	error("foo must not be negative")
end

-- Bad:
-- a player running out of money is not typically a bug, so this would be better
-- implemented using `success, result` or similar
if numCoins < itemPrice then
	error("Player doesn't have enough coins for transaction")
end
```

When calling functions that communicate failure by throwing, wrap calls in
`pcall` and make it clear via comment what kinds of errors you're expecting to
handle.

## Logging

Except for debugging, any code in Fusion that throws an error, emits a warning
or prints a message should do so using Fusion's logging utilities. These logging
utilities add extra information to the message, so the user of the library can
easily find more information about where they're coming from.

These logging utilities work with message IDs rather than plain text; if you
need to log a new kind of message, add it to the list of messages under a new
message ID.

Generally, you should avoid reusing message IDs that are used in other areas of
the library. Message IDs should be limited to a small area, so the documentation
for them can provide more specific details about what's going on, which helps
debugging efforts.

When adding a new message to the list of messages, make sure to document the new
message in Fusion's 'Errors & Messages' section of the API Reference.

## General Roblox Best Practices
- All services should be referenced using `GetService` at the top of the file.
- When importing a module, use the name of the module for its variable name.