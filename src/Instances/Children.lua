--!strict

--[[
	A special key for property tables, which parents any given descendants into
	an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local logWarn = require(Package.Core.Logging.logWarn)
local Observer = require(Package.State.Observer)
local xtypeof = require(Package.Core.Utility.xtypeof)

type Set<T> = {[T]: boolean}

-- Experimental flag: name children based on the key used in the [Children] table
local EXPERIMENTAL_AUTO_NAMING = false

local Children = {}
Children.type = "SpecialKey"
Children.kind = "Children"
Children.stage = "descendants"

function Children:apply(propValue: any, applyToRef: PubTypes.SemiWeakRef, cleanupTasks: {PubTypes.Task})
	local newParented: Set<Instance> = {}
	local oldParented: Set<Instance> = {}

	-- save disconnection functions for state object observers
	local newDisconnects: {[PubTypes.StateObject<any>]: () -> ()} = {}
	local oldDisconnects: {[PubTypes.StateObject<any>]: () -> ()} = {}

	local updateQueued = false
	local queueUpdate: () -> ()

	-- Rescans this key's value to find new instances to parent and state objects
	-- to observe for changes; then unparents instances no longer found and
	-- disconnects observers for state objects no longer present.
	local function updateChildren()
		updateQueued = false

		oldParented, newParented = newParented, oldParented
		oldDisconnects, newDisconnects = newDisconnects, oldDisconnects
		table.clear(newParented)
		table.clear(newDisconnects)

		local function processChild(child: any, autoName: string?)
			local kind = xtypeof(child)

			if kind == "Instance" then
				-- case 1; single instance

				newParented[child] = true
				if oldParented[child] == nil then
					-- wasn't previously present

					-- TODO: check for ancestry conflicts here
					child.Parent = applyToRef.instance
				else
					-- previously here; we want to reuse, so remove from old
					-- set so we don't encounter it during unparenting
					oldParented[child] = nil
				end

				if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
					child.Name = autoName
				end

			elseif kind == "State" then
				-- case 2; state object

				local value = child:get(false)
				-- allow nil to represent the absence of a child
				if value ~= nil then
					processChild(value, autoName)
				end

				local disconnect = oldDisconnects[child]
				if disconnect == nil then
					-- wasn't previously present
					disconnect = Observer(child):onChange(queueUpdate)
				else
					-- previously here; we want to reuse, so remove from old
					-- set so we don't encounter it during unparenting
					oldDisconnects[child] = nil
				end

				newDisconnects[child] = disconnect

			elseif kind == "table" then
				-- case 3; table of objects

				for key, subChild in pairs(child) do
					local keyType = typeof(key)
					local subAutoName: string? = nil

					if keyType == "string" then
						subAutoName = key
					elseif keyType == "number" and autoName ~= nil then
						subAutoName = autoName .. "_" .. key
					end

					processChild(subChild, subAutoName)
				end

			else
				logWarn("unrecognisedChildType", kind)
			end
		end

		if propValue ~= nil then
			-- `propValue` is set to nil on cleanup, so we don't process children
			-- in that case
			processChild(propValue)
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
			task.defer(updateChildren)
		end
	end

	table.insert(cleanupTasks, function()
		propValue = nil
		updateChildren()
	end)

	-- perform initial child parenting
	updateChildren()
end

return Children :: PubTypes.SpecialKey