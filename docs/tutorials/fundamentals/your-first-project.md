To start, let's quickly take a look at a vertical slice of Fusion code. You'll
see how everything looks together, but you aren't expected to understand
everything right away.

-----

## Overview

Open a new script file and ensure you have Fusion imported correctly.

```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
```

### Your first group

Fusion is a library where you will be creating a lot of objects. Fusion groups
these objects together so they can be managed in bulk.

If you've used other Luau libraries before, this idea goes by many names, like
"maids" or "janitors". However, in Fusion, we simply call them *groups*.

Let's start by creating a group for ourselves.

```Lua linenums="1" hl_lines="4"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local g = Fusion:Group()
```

### Your first value

Now, we will create our first Fusion object - the *value*. As the name suggests,
values are very simple objects; they store a single value, much like a variable.

Call the `:Value()` function on the group to create a value, and give it 
something to be stored.

```Lua linenums="4" hl_lines="3"
local g = Fusion:Group()

local numCoins = g:Value(50)
```

### Peeking

Fusion gives you a global utility that can peek inside of these objects and see
what they're currently storing at this moment in time. It's useful for debugging
your code, or otherwise checking something's contents without causing anything
else to happen.

By using `Fusion.peek`, we can read and print out the contents of `numCoins`.

```Lua linenums="4" hl_lines="5"
local g = Fusion:Group()

local numCoins = g:Value(50)

print(Fusion.peek(numCoins)) --> 50
```

### Running a computation

Let's try running a computation instead. To do this, we will create a
second Fusion object - the *computed*.

Call the `:Computed()` function on the group to create a computed, and give it
a function to run as a calculation. For now, it'll just be hardcoded.

```Lua linenums="4" hl_lines="5-7"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function()
	return "I am a message"
end)

print(Fusion.peek(numCoins)) --> 50
```

As with values, computeds can be peeked at, to see their contents without doing
anything else.

Let's change the print statement to show the message instead.

```Lua linenums="4" hl_lines="9"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function()
	return "I am a message"
end)

print(Fusion.peek(message)) --> I am a message
```

### Adding other objects to the computation

Let's change the message to show how many coins we have. To use another object
in your calculation, computeds will give you a `use` parameter.

Add this `use` parameter to your computed callback.

```Lua linenums="4" hl_lines="5"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "I am a message"
end)

print(Fusion.peek(message)) --> I am a message
```

`use` is a function that you can pass a Fusion object to, and it will give you
the value, similarly to `peek`. However, unlike `peek`, it will also link your
computation to that other Fusion object under the hood.

Let's change our message to tell us the number of coins:

```Lua linenums="4" hl_lines="6"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "The number of coins is " .. use(numCoins)
end)

print(Fusion.peek(message)) --> The number of coins is 50
```

### Updating your data

Suppose we want to give the user more coins. 

Values specifically have a `:set()` method that can be used to change the data
they are storing. 

Let's use this at the end and re-print the message.

```Lua linenums="4" hl_lines="11-13"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "The number of coins is " .. use(numCoins)
end)

print(Fusion.peek(message)) --> The number of coins is 50

numCoins:set(75)

print(Fusion.peek(message)) --> The number of coins is 75

```

### Detecting changes

Right now, we intend to print the message whenever the message changes. It would
be nice to do that automatically.

To do that, Fusion has a third kind of object - the *observer*.

Call the `:Observer()` function on the group to create an observer, and pass the
object you want the observer to watch and detect changes to.

```Lua linenums="4" hl_lines="9"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "The number of coins is " .. use(numCoins)
end)

g:Observer(message)

print(Fusion.peek(message)) --> The number of coins is 50

numCoins:set(75)

print(Fusion.peek(message)) --> The number of coins is 75
```

To add a callback that runs when a change is detected, call `:onChange()` on the
observer with the callback you want - we'll print the message inside ours, and
get rid of the old prints.

```Lua linenums="4" hl_lines="9-11"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "The number of coins is " .. use(numCoins)
end)

g:Observer(message):onChange(function()
	print(Fusion.peek(message))
end)

numCoins:set(75)

--> The number of coins is 75
```

The message gets printed after we change the number of coins!

If you want to print the message immediately, too, use `:onBind()` instead:

```Lua linenums="4" hl_lines="9"
local g = Fusion:Group()

local numCoins = g:Value(50)

local message = g:Computed(function(use)
	return "The number of coins is " .. use(numCoins)
end)

g:Observer(message):onBind(function()
	print(Fusion.peek(message))
end)

--> The number of coins is 50

numCoins:set(75)

--> The number of coins is 75
```

With that, you've written your first file of Fusion code, touching on all of the
major Fusion concepts!

Over the next few tutorials, we'll dig deeper into what exactly all of this code
is doing, but for now, feel free to review these code snippets as many times as
you need.