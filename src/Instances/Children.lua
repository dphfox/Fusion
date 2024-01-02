--!strict

--[[
	A special key for property tables, which parents any given descendants into
	an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local External = require(Package.External)
local logWarn = require(Package.Logging.logWarn)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)

type Set<T> = {[T]: boolean}

-- Experimental flag: name children based on the key used in the [Children] table
local EXPERIMENTAL_AUTO_NAMING = false

local function batchingSortedInsert(queue: {Instance}, instance: Instance)
	--  initialise binary search values
	local iStart, iEnd, iMid, iState = 1, #queue, 1, 0
	-- store instance info to avoid having to index the properties multiple times
	local className = instance.ClassName
	local isImage = className == "ImageLabel" or className == "ImageButton"
	local image = if isImage then (instance :: ImageLabel | ImageButton).Image else nil
	-- find insert position
	while iStart <= iEnd do
		-- calculate middle
		iMid = math.floor((iStart + iEnd) / 2)
		local midInstance = queue[iMid]
		local midClassName = midInstance.ClassName
		-- compare
		if className < midClassName then
			iEnd, iState = iMid - 1, 0
		elseif isImage and midClassName == className then
			-- when two images are compared, sort by asset id
			-- so that identical images are grouped together for batching
			local midImage = (midInstance :: ImageLabel | ImageButton).Image
			if image < midImage then
				iEnd, iState = iMid - 1, 0
			else
				iStart, iState = iMid + 1, 1
			end
		else
			iStart, iState = iMid + 1, 1
		end
	end
	-- insert
	table.insert(queue, iMid + iState, instance)
end

local Children = {}
Children.type = "SpecialKey"
Children.kind = "Children"
Children.stage = "descendants"

function Children:apply(propValue: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
	local newParented: Set<Instance> = {}
	local oldParented: Set<Instance> = {}
	local parentingQueue: {Instance} = {}

	-- save disconnection functions for state object observers
	local newDisconnects: {[PubTypes.StateObject<any>]: () -> ()} = {}
	local oldDisconnects: {[PubTypes.StateObject<any>]: () -> ()} = {}

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
		table.clear(parentingQueue)

		local function processChild(child: any, autoName: string?)
			local childType = typeof(child)

			if childType == "Instance" then
				-- case 1; single instance

				newParented[child] = true
				if oldParented[child] == nil then
					-- wasn't previously present

					-- TODO: check for ancestry conflicts here
					batchingSortedInsert(parentingQueue, child)
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

				local value = peek(child)
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

					-- note: children that are added dynamically at a later time will not
					-- be batched with these pre-existing children since that would require all
					-- children to be re-parented in batching order, which is more expensive
					-- than just sacrificing some potential batching
					oldDisconnects[child] = nil
				end

				newDisconnects[child] = disconnect

			elseif childType == "table" then
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
				logWarn("unrecognisedChildType", childType)
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

		-- parent any new children
		for _, child in parentingQueue  do
			child.Parent = applyTo
		end
	end

	queueUpdate = function()
		if not updateQueued then
			updateQueued = true
			External.doTaskDeferred(updateChildren)
		end
	end

	table.insert(cleanupTasks, function()
		propValue = nil
		updateQueued = true
		updateChildren()
	end)

	-- perform initial child parenting
	updateQueued = true
	updateChildren()
end

return Children :: PubTypes.SpecialKey
