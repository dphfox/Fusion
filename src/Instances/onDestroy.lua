--!strict

--[[
	Runs a callback with arguments when the referenced instance is destroyed.
	Returns a function to disconnect from this event later.

	This is more comprehensive than `instance.Destroyed` as it covers instances
	not explicitly destroyed with `:Destroy()`.

	NOTE: use of this function should be a last resort - if you have another way
	of more concretely tracking the lifetime of the instance, please use that
	instead. This function is intended for use with user-provided instances for
	which the lifetime is not known.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local logWarn = require(Package.Core.Logging.logWarn)
local isAccessible = require(Package.Instances.isAccessible)

-- FIXME: whenever they fix generic type packs in Roblox LSP:
--- onDestroy<A...>(instanceRef: Types.SemiWeakRef, callback: (A...) -> (), ...: A...)

local function onDestroy(instanceRef: PubTypes.SemiWeakRef, callback: (...any) -> (), ...: any): () -> ()
	if instanceRef.instance == nil then
		-- if we get a nil reference initially, then there's probably an issue
		-- somewhere else - usually the instance isn't destroyed until later!
		logWarn("onDestroyNilRef")
		callback(...)
		return function() end
	end

	local ancestryConn: RBXScriptConnection
	local disconnected = false

	local function disconnect()
		if not disconnected then
			disconnected = true
			ancestryConn:Disconnect()
		end
	end

	local args = table.pack(...)
	local accessible: boolean

	local function onAncestryChange()
		if disconnected then
			return
		end

		accessible = if instanceRef.instance == nil then false else isAccessible(instanceRef.instance :: Instance)

		if accessible then
			-- don't need to monitor the instance if it's safely in the game
			return
		end

		-- start monitoring the instance for destruction
		task.defer(function()
			while not accessible and not disconnected do
				if not ancestryConn.Connected then
					callback(table.unpack(args, 1, args.n))
					disconnect()
					return
				end
				task.wait()
			end
		end)
	end

	ancestryConn = (instanceRef.instance :: Instance).AncestryChanged:Connect(onAncestryChange)
	onAncestryChange()

	return disconnect
end

return onDestroy