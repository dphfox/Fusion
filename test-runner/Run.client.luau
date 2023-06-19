local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local TestEZ = require(StarterPlayerScripts.TestEZ)

local RUN_TESTS = true
local RUN_BENCHMARKS = false

-- run unit tests
if RUN_TESTS then
	print("Running unit tests...")
	local data = TestEZ.TestBootstrap:run({
		ReplicatedStorage.FusionTest
	})

	if data.failureCount > 0 then
		return
	end
end

-- run benchmarks
if RUN_BENCHMARKS then
	print("Running benchmarks...")

	-- wait for a bit to allow initial load to pass - this means the lag from a ton
	-- of things starting up shouldn't impact the benchmarks (as much)
	wait(5)

	local results = {}
	local maxNameLength = 0

	for _, instance in pairs(ReplicatedStorage.FusionBench:GetDescendants()) do
		if instance:IsA("ModuleScript") and instance.Name:match("%.bench$") then
			-- yield between benchmarks so we don't freeze Studio
			wait()
			local benchmarks = require(instance)

			local fileName = instance.Name:gsub("%.bench$", "")
			local fileResults = {}

			for index, benchmarkInfo in ipairs(benchmarks) do
				local name = benchmarkInfo.name
				local calls = benchmarkInfo.calls

				local preRun = benchmarkInfo.preRun
				local run = benchmarkInfo.run
				local postRun = benchmarkInfo.postRun

				maxNameLength = math.max(maxNameLength, #name)

				local state

				if preRun ~= nil then
					state = preRun()
				end

				local start = os.clock()
				for n=1, calls do
					run(state)
				end
				local fin = os.clock()

				if postRun ~= nil then
					postRun(state)
				end

				local timeMicros = (fin - start) * 1000000 / calls

				fileResults[index] = {name = name, time = timeMicros}
			end

			table.sort(fileResults, function(a, b)
				return a.name < b.name
			end)

			table.insert(results, {fileName = fileName, results = fileResults})
		end
	end

	table.sort(results, function(a, b)
		return a.fileName < b.fileName
	end)

	local resultsString = "Benchmark results:"

	for _, fileInfo in ipairs(results) do
		resultsString ..= "\n[+] " .. fileInfo.fileName

		for _, testInfo in ipairs(fileInfo.results) do
			resultsString ..= "\n   [+] "
			resultsString ..= testInfo.name .. " "
			resultsString ..= ("."):rep(maxNameLength - #testInfo.name + 4) .. " "
			resultsString ..= ("%.2f μs"):format(testInfo.time)
		end
	end

	print(resultsString)
end

-- run test main script
if StarterPlayerScripts:FindFirstChild("TestMain") then
	print("Running test main script...")
	require(StarterPlayerScripts.TestMain)
end