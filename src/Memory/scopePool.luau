--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local Package = script.Parent.Parent
local Types = require(Package.Types)
local poisonScope = require(Package.Memory.poisonScope)
local ExternalDebug = require(Package.ExternalDebug)

local ENABLE_POOLING = false
local MAX_POOL_SIZE = 16 -- TODO: need to test what an ideal number for this is

local pool = {}
local poolSize = 0

return {
	giveIfEmpty = function<S>(
		scope: Types.Scope<S>
	): Types.Scope<S>?
		if next(scope) == nil then
			ExternalDebug.untrackScope(scope)
			if ENABLE_POOLING and poolSize < MAX_POOL_SIZE then
				poolSize += 1
				pool[poolSize] = scope
			else
				poisonScope(scope, "previously passed to the internal scope pool, which indicates a Fusion bug.")
			end
			return nil
		else
			return scope
		end
	end,
	clearAndGive = function(
		scope: Types.Scope<unknown>
	)
		ExternalDebug.untrackScope(scope)
		table.clear(scope)
		if ENABLE_POOLING and poolSize < MAX_POOL_SIZE then
			poolSize += 1
			pool[poolSize] = scope :: any
		else
			poisonScope(scope, "previously passed to the internal scope pool, which indicates a Fusion bug.")
		end
	end,
	reuseAny = function(): Types.Scope<unknown>
		if poolSize == 0 then
			return nil :: any
		else
			local scope = pool[poolSize]
			poolSize -= 1
			return scope
		end
	end
}