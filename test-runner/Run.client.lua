local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local TestEZ = require(StarterPlayerScripts.TestEZ)

local RUN_TESTS = true

-- run unit tests
if RUN_TESTS then
	print("Running unit tests...")
	local External = require(ReplicatedStorage.Fusion.External)
	External.unitTestSilenceNonFatal = true
	local data = TestEZ.TestBootstrap:run({
		ReplicatedStorage.FusionTest
	})
	External.unitTestSilenceNonFatal = false

	if data.failureCount > 0 then
		return
	end
end