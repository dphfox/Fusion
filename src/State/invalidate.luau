--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Invalidates a graph object, and transitively invalidates all of the graph
	objects' dependents.

	This is guaranteed to succeed, even for cyclic graphs.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local searchInNow: {Types.GraphObject} = {}
local searchInNext: {Types.GraphObject} = {}
local invalidateList: {Types.GraphObject} = {}

local function invalidate(
	target: Types.GraphObject
): ()
	if target.validity == "valid" then
		table.clear(searchInNow)
		table.clear(invalidateList)
		searchInNow[1] = target
		repeat
			table.clear(searchInNext)
			local done = true
			for _, searchTarget in searchInNow do
				for dependent in searchTarget.dependentSet do
					if dependent.validity == "valid" then
						done = false
						table.insert(invalidateList, dependent)
						table.insert(searchInNext, dependent)
					elseif dependent.validity == "busy" then
						return logError("infiniteLoop")
					end
				end
			end
			searchInNow, searchInNext = searchInNext, searchInNow
		until done
		for _, invalidateTarget in invalidateList do
			invalidateTarget.validity = "invalid"
		end
	elseif target.validity == "busy" then
		return logError("infiniteLoop")
	end
end

return invalidate