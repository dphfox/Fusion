--[[
	The 'smarter' version of `cleanupOnDestroy` - this attempts to match the
	results from the 'dumber' polling-based version by using events to reduce
	processing.

	I'd like to improve this technique in the future - it breaks in a fair few
	edge cases right now, so in the interest of stability I don't want to adopt
	it yet.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local cleanup = require(Package.Utility.cleanup)

-- The event to use for waiting (typically Heartbeat)
local STEP_EVENT = RunService.Heartbeat

local function cleanupOnDestroy(instance: Instance?, task: cleanup.Task): (() -> ())
	-- set up manual disconnection logic
	local isDisconnected = false
	local ancestryChangedConn

	local function disconnect()
		if not isDisconnected then
			isDisconnected = true
			ancestryChangedConn:Disconnect()
		end
	end

	-- We can't keep a reference to the instance, but we need to keep track of
	-- when the instance is parented to `nil`.
	-- To get around this, we can save the parent from AncestryChanged here
	local isNilParented = instance.Parent == nil

	-- when AncestryChanged is called, run some destroy-checking logic
	-- this function can yield when called, so make sure to call in a new thread
	-- if you don't want your current thread to block
	local function onInstanceMove(_doNotUse: Instance?, newParent: Instance?)
		if isDisconnected then
			return
		end

		-- discard the first argument so we don't inhibit GC
		_doNotUse = nil

		isNilParented = newParent == nil

		-- if the instance has been moved into a nil parent, it could possibly
		-- have been destroyed if no other references exist
		if isNilParented then
			-- We don't want this function to yield, because it's called
			-- directly from the main body of `connectToDestroy`
			coroutine.wrap(function()
				-- This delay is needed because the event will always be connected
				-- when it is first run, but we need to see if it's disconnected as
				-- a result of the instance being destroyed.
				STEP_EVENT:Wait()

				if isDisconnected then
					return

				elseif not ancestryChangedConn.Connected then
					-- if our event was disconnected, the instance was destroyed
					cleanup(task)
					disconnect()

				else
					-- The instance currently still exists, however there's a
					-- nasty edge case to deal with; if an instance is destroyed
					-- while in nil, `AncestryChanged` won't fire, because its
					-- parent will have changed from nil to nil.

					-- For this reason, we set up a loop to poll
					-- for signs of the instance being destroyed, because we're
					-- out of event-based options.
					while
						isNilParented and
						ancestryChangedConn.Connected and
						not isDisconnected
					do
						-- FUTURE: is this too often?
						STEP_EVENT:Wait()
					end

					-- The instance was either destroyed, or we stopped looping
					-- for another reason (reparented or `disconnect` called)
					-- Check those other conditions before calling the callback.
					if isDisconnected or not isNilParented then
						return
					end

					cleanup(task)
					disconnect()
				end
			end)()
		end
	end

	ancestryChangedConn = instance.AncestryChanged:Connect(onInstanceMove)

	-- in case the instance is currently in nil, we should call `onInstanceMove`
	-- before any other code has the opportunity to run
	if isNilParented then
		onInstanceMove(nil, instance.Parent)
	end

	-- remove this functions' reference to the instance, so it doesn't influence
	-- any garbage collection and cause memory leaks
	instance = nil

	return disconnect
end

return cleanupOnDestroy