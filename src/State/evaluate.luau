--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Revalidates a graph object using monotonic painting.
	https://fluff.blog/2024/04/16/monotonic-painting.html
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local function evaluate(
	target: Types.GraphObject
): ()
	if target.validity == "invalid" then
		target.validity = "busy"
		local needsComputation = true
		local targetComputedBefore = target.lastChange ~= nil
		if targetComputedBefore then
			needsComputation = false
			for dependency in target.dependencySet do
				evaluate(dependency)
				if dependency.lastChange > target.lastChange then
					needsComputation = true
					break
				end
			end
		end
		local targetMeaningfullyChanged = false
		if needsComputation then
			table.clear(target.dependencySet)
			targetMeaningfullyChanged = target:duringEvaluation() or not targetComputedBefore
		end
		if targetMeaningfullyChanged then
			target.lastChange = os.clock()
		end
		target.validity = "valid"
	elseif target.validity == "busy" then
		return logError("infiniteLoop")
	end
end

return evaluate