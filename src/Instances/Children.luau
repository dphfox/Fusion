--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which parents any given descendants into
	an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local Observer = require(Package.Graph.Observer)
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
local doCleanup = require(Package.Memory.doCleanup)

type Set<T> = {[T]: unknown}

-- Experimental flag: name children based on the key used in the [Children] table
local EXPERIMENTAL_AUTO_NAMING = false

return {
	type = "SpecialKey",
	kind = "Children",
	stage = "descendants",
	apply = function(
		self: Types.SpecialKey,
		scope: Types.Scope<unknown>,
		value: unknown,
		applyTo: Instance
	)
		local newParented: Set<Instance> = {}
		local oldParented: Set<Instance> = {}
	
		-- save scopes for state object observers
		local newScopes: {[Types.StateObject<unknown>]: Types.Scope<unknown>} = {}
		local oldScopes: {[Types.StateObject<unknown>]: Types.Scope<unknown>} = {}
	
		-- Rescans this key's value to find new instances to parent and state objects
		-- to observe for changes; then unparents instances no longer found and
		-- disconnects observers for state objects no longer present.
		local function updateChildren()
			oldParented, newParented = newParented, oldParented
			oldScopes, newScopes = newScopes, oldScopes
	
			local function processChild(
				child: unknown,
				autoName: string?
			)
				local childType = typeof(child)
	
				if childType == "Instance" then
					-- case 1; single instance
					local child = child :: Instance
	
					newParented[child] = true
					if oldParented[child] == nil then
						-- wasn't previously present
	
						-- TODO: check for ancestry conflicts here
						child.Parent = applyTo
					else
						-- previously here; we want to reuse, so remove from old
						-- set so we don't encounter it during unparenting
						oldParented[child] = nil
					end
	
					if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
						child.Name = autoName
					end
	
				elseif castToState(child) then
					-- case 2; state object
					local child = child :: Types.StateObject<unknown>
	
					local value = peek(child)
					-- allow nil to represent the absence of a child
					if value ~= nil then
						processChild(value, autoName)
					end
	
					local childScope = oldScopes[child]
					if childScope == nil then
						-- wasn't previously present
						childScope = {}
						Observer(childScope, child):onChange(updateChildren)
					else
						-- previously here; we want to reuse, so remove from old
						-- set so we don't encounter it during unparenting
						oldScopes[child] = nil
					end
	
					newScopes[child] = childScope
	
				elseif childType == "table" then
					-- case 3; table of objects
					local child = child :: {[unknown]: unknown}
	
					for key, subChild in pairs(child) do
						local keyType = typeof(key)
						local subAutoName: string? = nil
	
						if keyType == "string" then
							local key = key :: string
							subAutoName = key
						elseif keyType == "number" and autoName ~= nil then
							local key = key :: number
							subAutoName = autoName .. "_" .. key
						end
	
						processChild(subChild, subAutoName)
					end
	
				else
					External.logWarn("unrecognisedChildType", childType)
				end
			end
	
			if value ~= nil then
				-- `propValue` is set to nil on cleanup, so we don't process children
				-- in that case
				processChild(value)
			end
	
			-- unparent any children that are no longer present
			for oldInstance in pairs(oldParented) do
				oldInstance.Parent = nil
			end
			table.clear(oldParented)
	
			-- disconnect observers which weren't reused
			for oldState, childScope in pairs(oldScopes) do
				doCleanup(childScope)
			end
			table.clear(oldScopes)
		end
	
		table.insert(scope, function()
			value = nil
			updateChildren()
		end)
	
		-- perform initial child parenting
		updateChildren()
	end
} :: Types.SpecialKey