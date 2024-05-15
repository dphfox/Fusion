--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local alreadyDestroying: {[Types.Task]: true} = {}

local function doCleanup(
	task: Types.Task
): ()
	if alreadyDestroying[task] then
		return External.logError("destroyedTwice")
	end
	alreadyDestroying[task] = true

	-- case 1: Instance
	if typeof(task) == "Instance" then
		task:Destroy()

	-- case 2: RBXScriptConnection
	elseif typeof(task) == "RBXScriptConnection" then
		task:Disconnect()

	-- case 3: callback
	elseif typeof(task) == "function" then
		task()

	elseif typeof(task) == "table" then
		local task = (task :: any) :: {Destroy: (...unknown) -> (...unknown)?, destroy: (...unknown) -> (...unknown)?}

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
			local task = task :: {Types.Task}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #task, 1, -1 do
				doCleanup(task[index])
				task[index] = nil
			end
		end
	end
	
	alreadyDestroying[task] = nil
end

return doCleanup