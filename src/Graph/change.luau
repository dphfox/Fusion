--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Prompts a graph object to re-evaluate its own value. If it meaningfully
	changes, then dependents will have to re-evaluate their own values in the
	future.

	https://fluff.blog/2024/04/16/monotonic-painting.html
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local evaluate = require(Package.Graph.evaluate)

local searchInNow: {Types.GraphObject} = {}
local searchInNext: {Types.GraphObject} = {}
local invalidateList: {Types.GraphObject} = {}
local eagerList: {Types.GraphObject} = {}

-- How long should this function run before it's considered to be in an infinite
-- cycle and error out?
local TERMINATION_TIME = 1

local function change(
	target: Types.GraphObject
): ()
	if target.validity == "busy" then
		return External.logError("infiniteLoop")
	end

	local meaningfullyChanged = evaluate(target, true)
	if not meaningfullyChanged then
		return
	end

	table.clear(searchInNow)
	table.clear(invalidateList)
	searchInNow[1] = target
	local terminateBy = os.clock() + TERMINATION_TIME * External.safetyTimerMultiplier
	repeat
		if os.clock() > terminateBy then
			return External.logError("infiniteLoop")
		end
		table.clear(searchInNext)
		local done = true
		for _, searchTarget in searchInNow do
			for dependent in searchTarget.dependentSet do
				if dependent.validity == "valid" then
					done = false
					table.insert(invalidateList, dependent)
					table.insert(searchInNext, dependent)
				elseif dependent.validity == "busy" then
					return External.logError("infiniteLoop")
				end
			end
		end
		searchInNow, searchInNext = searchInNext, searchInNow
	until done
	table.clear(eagerList)
	for _, invalidateTarget in invalidateList do
		invalidateTarget.validity = "invalid"
		if invalidateTarget.timeliness == "eager" then
			table.insert(eagerList, invalidateTarget)
		end
	end
	for _, eagerTarget in eagerList do
		evaluate(eagerTarget, true)
	end
end

return change