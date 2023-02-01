--!strict

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]

local function cleanupOne(task: any)
	local taskType = typeof(task)

	-- case 1: Instance
	if taskType == "Instance" then
		task:Destroy()

	-- case 2: RBXScriptConnection
	elseif taskType == "RBXScriptConnection" then
		task:Disconnect()

	-- case 3: callback
	elseif taskType == "function" then
		task()

	elseif taskType == "table" then
		-- case 4: destroy() function
		if typeof(task.destroy) == "function" then
			task:destroy()

		-- case 5: Destroy() function
		elseif typeof(task.Destroy) == "function" then
			task:Destroy()

		-- case 6: array of tasks
		elseif task[1] ~= nil then
			for _, subtask in ipairs(task) do
				cleanupOne(subtask)
			end
		end
	end
end

local function cleanup(...: any)
	for index = 1, select("#", ...) do
		cleanupOne(select(index, ...))
	end
end

return cleanup