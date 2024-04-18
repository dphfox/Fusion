--!strict

local TestEZ = require(script.TestEZ) :: any
local TestVars = require(script.TestVars)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local External = require(Fusion.External)
local SpecExternal = require(script.SpecExternal)

-- run unit tests
if TestVars.runTests then
	print("Running unit tests...")
	-- Suppress "unknown require path" error here.
	External.unitTestSilenceNonFatal = true
	External.safetyTimerMultiplier = 1 / 20
	External.setExternalScheduler(SpecExternal)

	local data
	SpecExternal.doTaskDeferred(function()
		data = TestEZ.TestBootstrap:run({script.Spec})
	end)
	SpecExternal.step(0)

	External.unitTestSilenceNonFatal = false
	if data == nil or data.failureCount > 0 then
		return
	end
end