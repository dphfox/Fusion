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
	External.safetyTimerMultiplier = 1 / 20
	External.setExternalProvider(SpecExternal)

	local data
	SpecExternal.doTaskDeferred(function()
		data = (TestEZ.TestBootstrap :: any):run({script.Spec})
	end)
	SpecExternal.step(0)

	if data == nil or data.failureCount > 0 then
		return
	end
end