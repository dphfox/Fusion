This code shows how to deal with yielding/blocking code, such as fetching data
from a server.

Because these tasks don't complete immediately, they can't be directly run
inside of a `Computed`, so this example provides a robust framework for handling
this in a way that doesn't corrupt your code.

This example assumes the presence of a Roblox-like `task` scheduler.

-----

## Overview

```Lua linenums="1"
local Fusion = -- initialise Fusion here however you please!
local scoped = Fusion.scoped

local function fetchUserBio(
	userID: number
): string
	-- pretend this calls out to a server somewhere, causing this code to yield
	task.wait(1)
	return "This is the bio for user " .. userID .. "!"
end

-- Don't forget to pass this to `doCleanup` if you disable the script.
local scope = scoped(Fusion)

-- This doesn't have to be a `Value` - any kind of state object works too.
local currentUserID = scope:Value(1670764)

-- While the bio is loading, this is `nil` instead of a string.
local currentUserBio: Fusion.Value<string?> = scope:Value(nil)

do
	local fetchInProgress = nil
	local function performFetch()
		local userID = peek(currentUserID)
		currentUserBio:set(nil)
		if fetchInProgress ~= nil then
			task.cancel(fetchInProgress)
		end
		fetchInProgress = task.spawn(function()
			currentUserBio:set(fetchUserBio())
			fetchInProgress = nil
		end)
	end
	scope:Observer(currentUserID):onBind(performFetch)
end

scope:Observer(currentUserBio):onBind(function()
	local bio = peek(currentUserBio)
	if bio == nil then
		print("User bio is loading...")
	else
		print("Loaded user bio:", bio)
	end
end)
```

-----

## Explanation

If you yield or wait inside of a `Computed`, you can easily corrupt your entire
program.

However, this example has a function, `fetchUserBio`, that yields. 

```Lua
local function fetchUserBio(
	userID: number
): string
	-- pretend this calls out to a server somewhere, causing this code to yield
	task.wait(1)
	return "This is the bio for user " .. userID .. "!"
end
```

It also has some arbitrary state object, `currentUserID`, that it needs to
convert into a bio somehow.

```Lua
-- This doesn't have to be a `Value` - any kind of state object works too.
local currentUserID = scope:Value(1670764)
```

Because `Computed` can't yield, this code has to manually manage a
`currentUserBio` object, which will store the output of the code in a way that
can be used by other Fusion objects later.

Notice that the 'loading' state is explicitly documented. It's a good idea to
be clear and honest when you have no data to show, because it allows other code
to respond to that case flexibly.

```Lua
-- While the bio is loading, this is `nil` instead of a string.
local currentUserBio: Fusion.Value<string?> = scope:Value(nil)
```

To perform the actual fetch, a simple function can be written which calls
`fetchUserBio` in a separate task. Once it returns a bio, the `currentUserBio`
can be updated.

To avoid two fetches overwriting each other, any existing fetch task is canceled
before the new task is created.

```Lua
	local fetchInProgress = nil
	local function performFetch()
		local userID = peek(currentUserID)
		currentUserBio:set(nil)
		if fetchInProgress ~= nil then
			task.cancel(fetchInProgress)
		end
		fetchInProgress = task.spawn(function()
			currentUserBio:set(fetchUserBio())
			fetchInProgress = nil
		end)
	end
```

Finally, to run this function when the `currentUserID` changes, `performFetch`
can be added to an `Observer`.

The `onBind` method also runs `performFetch` once at the start of the program,
so the request is sent out automatically.

```Lua
scope:Observer(currentUserID):onBind(performFetch)
```

That's all you need - now, any other Fusion code can read and depend upon
`currentUserBio` as if it were any other kind of state object. Just remember to
handle the 'loading' state as well as the successful state.

```Lua
scope:Observer(currentUserBio):onBind(function()
	local bio = peek(currentUserBio)
	if bio == nil then
		print("User bio is loading...")
	else
		print("Loaded user bio:", bio)
	end
end)
```

You may wish to expand this code with error handling if `fetchUserBio()` can
throw errors.