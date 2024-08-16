--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Evaluates the graph object if necessary, so that it is up to date.
	Returns true if it meaningfully changed.

	https://fluff.blog/2024/04/16/monotonic-painting.html
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local function evaluate(
	target: Types.GraphObject,
	forceComputation: boolean
): boolean
	if target.validity == "busy" then
		return External.logError("infiniteLoop")
	end
	local firstEvaluation = target.lastChange == nil
	local isInvalid = target.validity == "invalid"
	if firstEvaluation or isInvalid or forceComputation then
		local needsComputation = firstEvaluation or forceComputation
		if not needsComputation then
			for dependency in target.dependencySet do
				evaluate(dependency, false)
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
				target.dependencySet[dependency] = nil
			end
			target.validity = "busy"
			targetMeaningfullyChanged = target:_evaluate() or firstEvaluation
		end
		if targetMeaningfullyChanged then
			target.lastChange = os.clock()
		end
		target.validity = "valid"
		return targetMeaningfullyChanged
	else
		return false
	end
end

return evaluate