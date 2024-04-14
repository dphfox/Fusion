--!strict
--!nolint LocalShadow

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]

local function doCleanupOne(
	task: unknown
)
	local taskType = typeof(task)

	-- case 1: Instance
	if taskType == "Instance" then
		local task = task :: Instance
		task:Destroy()

	-- case 2: RBXScriptConnection
	elseif taskType == "RBXScriptConnection" then
		local task = task :: RBXScriptConnection
		task:Disconnect()

	-- case 3: callback
	elseif taskType == "function" then
		local task = task :: (...unknown) -> (...unknown)
		task()

	elseif taskType == "table" then
		local task = task :: {destroy: unknown?, Destroy: unknown?}

		-- case 4: destroy() function
		if typeof(task.destroy) == "function" then
			local task = (task :: any) :: {destroy: (...unknown) -> (...unknown)}
			task:destroy()

		-- case 5: Destroy() function
		elseif typeof(task.Destroy) == "function" then
			local task = (task :: any) :: {Destroy: (...unknown) -> (...unknown)}
			task:Destroy()

		-- case 6: array of tasks
		elseif task[1] ~= nil then
			local task = task :: {unknown}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #task, 1, -1 do
				doCleanupOne(task[index])
				task[index] = nil
			end
		end
	end
end

local function doCleanup(
	...: unknown
)
	for index = 1, select("#", ...) do
		doCleanupOne(select(index, ...))
	end
end

return doCleanup