```Lua linenums="1"
-- [Fusion imports omitted for clarity]

-- This code assumes that there is a RemoteFunction at this location, which
-- accepts a user ID and will return a string with that user's bio text.
-- The server implementation is not shown here.
local FetchUserBio = game:GetService("ReplicatedStorage").FetchUserBio

-- Creating a Value object to store the user ID we're currently looking at
local currentUserID = Value(1670764)

-- If we could instantly calculate the user's bio text, we could use a Computed
-- here. However, fetching data from the server takes time, which means we can't
-- use Computed without introducing serious consistency errors into our program.

-- Instead, we fall back to using an observer to manually manage our own value:
local currentUserBio = Value(nil)
-- Using a scope to hide our management code from the rest of the script:
do
	local lastFetchTime = nil
	local function fetch()
		local fetchTime = os.clock()
		lastFetchTime = fetchTime
		currentUserBio:set(nil) -- set to a default value to indicate loading
		task.spawn(function()
			local bio = FetchUserBio:InvokeServer(currentUserID:get(false))
			-- If these two are not equal, then that means another fetch was
			-- started while we were waiting for the server to return a value.
			-- In that case, the more recent call will be more up-to-date, so we
			-- shouldn't overwrite it. This adds a nice layer of reassurance,
			-- but if your value doesn't change often, this might be optional.
			if lastFetchTime == fetchTime then
				currentUserBio:set(bio)
			end
		end)
	end

	fetch() -- get the bio for the initial user ID
	-- when the user ID changes, reload the bio
	local disconnect = Observer(currentUserID):onChange(fetch)

	-- Don't forget to call `disconnect` when you're done with `currentUserBio`.
	-- That's not included in this code snippet, but it's important if you want
	-- to avoid leaking memory.
end

-- Now, you can use `currentUserBio` just like any other state object! Note that
-- `nil` is used to represent a bio that hasn't loaded yet, so you'll want to
-- handle that case before passing it into any code that expects a solid value.

local bioLabel = New "TextLabel" {
	Text = Computed(function()
		return currentUserBio:get() or "Loading user bio..."
	end)
}
```