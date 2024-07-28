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

	local searchInNow: {Types.GraphObject} = {}
	local searchInNext: {Types.GraphObject} = {}
	local invalidateList: {Types.GraphObject} = {}

	searchInNow[1] = target
	local terminateBy = os.clock() + TERMINATION_TIME * External.safetyTimerMultiplier
	repeat
		if os.clock() > terminateBy then
			return External.logError("infiniteLoop")
		end
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
		table.clear(searchInNext)
	until done

	local eagerList: {Types.GraphObject} = {}

	for _, invalidateTarget in invalidateList do
		invalidateTarget.validity = "invalid"
		if invalidateTarget.timeliness == "eager" then
			table.insert(eagerList, invalidateTarget)
		end
	end
	-- If objects are not executed in order of creations, then dynamic graphs
	-- may experience 'glitches' where nested graph objects see intermediate
	-- values before being destroyed.
	-- https://fluff.blog/2024/07/14/glitches-in-dynamic-reactive-graphs.html
	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)
	for _, eagerTarget in eagerList do
		evaluate(eagerTarget, false)
	end
end

return change