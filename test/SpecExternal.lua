--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local External = require(Fusion.External)

local SpecExternal = {}

local queue = {} :: {thread}

--[[
   Sends an immediate task to the external scheduler. Throws if none is set.
]]
function SpecExternal.doTaskImmediate(
	resume: () -> ()
)
	print("Scheduling task to run now...", debug.traceback())
	table.insert(queue, 1, coroutine.running())
	table.insert(queue, 1, coroutine.create(resume))
	coroutine.yield()
end

--[[
	Sends a deferred task to the external scheduler. Throws if none is set.
]]
function SpecExternal.doTaskDeferred(
	resume: () -> ()
)
	print("Scheduling task to run later...")
	table.insert(queue, coroutine.create(resume))
end

local doUpdateSteps = false

--[[
	Binds Fusion's update step to RunService step events.
]]
function SpecExternal.startScheduler()
	doUpdateSteps = true
end

--[[
	Unbinds Fusion's update step from RunService step events.
]]
function SpecExternal.stopScheduler()
	doUpdateSteps = false
end

--[[
	Unbinds Fusion's update step from RunService step events.
]]
function SpecExternal.step(
	currentTime: number
)
	print("Doing step")
	if doUpdateSteps then
		print("Update with time", currentTime)
		External.performUpdateStep(currentTime)
	end

	print("Draining queue...")
	while true do
		local nextTask = table.remove(queue, 1)
		if nextTask == nil then
			print("Ran out of tasks.")
			break
		end
		print("Resuming a task...")
		local ok, result: string = coroutine.resume(nextTask)
		if not ok then
			warn("Error in spec scheduler: " .. result)
		end
	end
end

return SpecExternal