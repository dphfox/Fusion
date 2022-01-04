--!nonstrict

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
local Types = require(Package.Types)
local logWarn = require(Package.Logging.logWarn)
local isAccessible = require(Package.Instances.isAccessible)

-- FIXME: whenever they fix generic type packs in Roblox LSP:
--- onDestroy<A...>(instanceRef: Types.SemiWeakRef, callback: (A...) -> (), ...: A...)

local function onDestroy(instanceRef: Types.SemiWeakRef, callback: (...any) -> (), ...: any): () -> ()
	if instanceRef.instance == nil then
		-- if we get a nil reference initially, then there's probably an issue
		-- somewhere else - usually the instance isn't destroyed until later!
		logWarn("onDestroyNilRef")
		callback(...)
		return
	end

	local ancestryConn: RBXScriptConnection
	local disconnected = false

	local function disconnect()
		if not disconnected then
			disconnect = true
			ancestryConn:Disconnect()
		end
	end

	local args = table.pack(...)
	local accessible: boolean

	local function onAncestryChange()
		if disconnected then
			return

		elseif instanceRef.instance == nil then
			-- this would be weird, because AncestryChanged gives us a fresh
			-- instance reference, but who knows maybe it might happen
			if ancestryConn.Connected then
				-- this implies the instance is around but the reference is lost,
				-- which is 100% a bug and pretty dangerous
				logWarn("onDestroyLostRef")
			end
			callback(table.unpack(args, 1, args.n))
			disconnect()
			return
		end

		accessible = isAccessible(instanceRef.instance)

		if accessible then
			-- don't need to monitor the instance if it's safely in the game
			return
		end

		-- start monitoring the instance for destruction
		task.defer(function()
			while not accessible and not disconnected do
				if instanceRef.instance == nil then
					if ancestryConn.Connected then
						-- this implies the instance is around but the reference is lost,
						-- which is 100% a bug and pretty dangerous
						logWarn("onDestroyLostRef")
					end
					callback(table.unpack(args, 1, args.n))
					disconnect()
					return
				end
				task.wait()
			end
		end)
	end

	ancestryConn = instanceRef.instance.AncestryChanged:Connect(onAncestryChange)
	onAncestryChange()

	return disconnect
end

return onDestroy