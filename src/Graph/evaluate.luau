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
local External = require(Package.External)

local function evaluate(
	target: Types.GraphObject
): ()
	if target.validity == "busy" then
		return External.logError("infiniteLoop")
	end
	local firstEvaluation = target.lastChange == nil
	local isInvalid = target.validity == "invalid"
	if firstEvaluation or isInvalid then
		local needsComputation = isInvalid and firstEvaluation 
		if not (needsComputation or firstEvaluation) then
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
			for dependency in target.dependencySet do
				dependency.dependentSet[target] = nil
			end
			table.clear(target.dependencySet)
			target.validity = "busy"
			targetMeaningfullyChanged = target:_evaluate()
		end
		if targetMeaningfullyChanged or firstEvaluation then
			target.lastChange = os.clock()
		end
		target.validity = "valid"
	end
end

return evaluate