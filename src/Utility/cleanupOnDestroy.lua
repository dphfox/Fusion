--[[
	Functions like a hypothetical 'Instance.Destroyed' event - when the instance
	is destroyed, cleans up the given task using the default `cleanup` function.
	Returns a function which can be called to stop listening for destruction.

	Relying on this function is dangerous - this should only ever be used when
	no more suitable solution exists. In particular, it's almost certainly the
	wrong solution if you're not dealing with instances passed in by the user.

	NOTE: yes, this uses polling. I've been working on making this function
	work better with events for months, and even then I can't avoid polling. I
	just want something that works in all edge cases, even it if might not be
	the theoretically best solution. This is the best choice for the short term.

	You can find the 'better' version with less polling in the
	`cleanupOnDestroy_smart` file if you're interested in helping out :)
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local cleanup = require(Package.Utility.cleanup)

type TaskData = {
	connection: RBXScriptConnection,
	task: cleanup.Task,
	cleaned: boolean
}

local function noOp()
	-- intentionally blank - no operation!
end

local tasks: {TaskData} = {}
local numTasks = 0
local currentIndex = 1

-- called to check for dead connections and run their cleanup tasks
local function runCleanupTasks()
	if numTasks == 0 then
		return
	end

	-- we want to clean as much stuff up as possible, but we don't want to hang
	-- the client, so we forcibly terminate after a short while
	local startTime = os.clock()
	local endTime = startTime + 1/1000

	-- run at most `numTask` times
	for _=1, numTasks do
		local taskData = tasks[currentIndex]

		if taskData.connection.Connected then
			-- instance is still alive, so move on to the next task
			currentIndex += 1
		else
			-- instance destroyed, so run cleanup and remove the task
			taskData.cleaned = true
			-- print("cleaning up", taskData.debugName)
			cleanup(taskData.task)

			table.remove(tasks, currentIndex)
			numTasks -= 1
		end

		-- wrap around if we passed the end of the task list
		if currentIndex > numTasks then
			currentIndex = 1
		end

		-- if this took too long, exit early to avoid hanging
		if os.clock() > endTime then
			break
		end
	end
end

RunService.Heartbeat:Connect(runCleanupTasks)

local function cleanupOnDestroy(instance: Instance, task: cleanup.Task): (() -> ())
	-- set up connection so we can check if the instance is alive
	-- we don't care about the event we're connecting to, just that we can see
	-- when it's disconnected by the garbage collector
	local connection = instance:GetPropertyChangedSignal("ClassName"):Connect(noOp)

	-- store data about the task for later
	local taskData = {
		debugName = instance.Name,
		connection = connection,
		task = task,
		cleaned = false
	}

	-- remove instance reference so we don't accidentally inhibit gc
	instance = nil

	-- add task to list
	numTasks += 1
	tasks[numTasks] = taskData

	-- return disconnect function to stop listening for destroy
	return function()
		if taskData.cleaned then
			return
		end

		taskData.cleaned = true
		connection:Disconnect()

		local index = table.find(tasks, taskData)
		if index ~= nil then
			table.remove(tasks, index)
			numTasks -= 1
		end
	end
end

return cleanupOnDestroy