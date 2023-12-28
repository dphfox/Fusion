--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which parents any given descendants into
	an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local logWarn = require(Package.Logging.logWarn)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)

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
	
		-- save disconnection functions for state object observers
		local newDisconnects: {[Types.StateObject<unknown>]: () -> ()} = {}
		local oldDisconnects: {[Types.StateObject<unknown>]: () -> ()} = {}
	
		local updateQueued = false
		local queueUpdate: () -> ()
	
		-- Rescans this key's value to find new instances to parent and state objects
		-- to observe for changes; then unparents instances no longer found and
		-- disconnects observers for state objects no longer present.
		local function updateChildren()
			if not updateQueued then
				return -- this update may have been canceled by destruction, etc.
			end
			updateQueued = false
	
			oldParented, newParented = newParented, oldParented
			oldDisconnects, newDisconnects = newDisconnects, oldDisconnects
			table.clear(newParented)
			table.clear(newDisconnects)
	
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
	
				elseif isState(child) then
					-- case 2; state object
					local child = child :: Types.StateObject<unknown>
	
					local value = peek(child)
					-- allow nil to represent the absence of a child
					if value ~= nil then
						processChild(value, autoName)
					end
	
					local disconnect = oldDisconnects[child]
					if disconnect == nil then
						-- wasn't previously present
						disconnect = Observer(scope, child):onChange(queueUpdate)
					else
						-- previously here; we want to reuse, so remove from old
						-- set so we don't encounter it during unparenting
						oldDisconnects[child] = nil
					end
	
					newDisconnects[child] = disconnect
	
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
					logWarn("unrecognisedChildType", childType)
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
	
			-- disconnect observers which weren't reused
			for oldState, disconnect in pairs(oldDisconnects) do
				disconnect()
			end
		end
	
		queueUpdate = function()
			if not updateQueued then
				updateQueued = true
				External.doTaskDeferred(updateChildren)
			end
		end
	
		table.insert(scope, function()
			value = nil
			updateQueued = true
			updateChildren()
		end)
	
		-- perform initial child parenting
		updateQueued = true
		updateChildren()
	end
} :: Types.SpecialKey