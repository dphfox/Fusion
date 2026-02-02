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
local ExternalDebug = require(Package.ExternalDebug)

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
		local task = (
			task :: any
		) :: {
			Destroy: (...unknown) -> ...unknown?,
			destroy: (...unknown) -> ...unknown?,
			Disconnect: (...unknown) -> ...unknown?,
			disconnect: (...unknown) -> ...unknown?,
		}

		-- case 4: destroy() function
		if typeof(task.destroy) == "function" then
			local task = (task :: any) :: {destroy: (...unknown) -> (...unknown)}
			task:destroy()

		-- case 5: Destroy() function
		elseif typeof(task.Destroy) == "function" then
			local task = (task :: any) :: {Destroy: (...unknown) -> (...unknown)}
			task:Destroy()

		-- case 6: table of tasks with an array part
		elseif task[1] ~= nil then
			local task = task :: {Types.Task}

			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #task, 1, -1 do
				doCleanup(task[index])
				task[index] = nil
			end

			ExternalDebug.untrackScope(task)

		-- case 7: Disconnect() function
		elseif typeof(task.Disconnect) == "function" then
			local task = (task :: any) :: { Disconnect: (...unknown) -> ...unknown }
			task:Disconnect()

		-- case 8: disconnect() function
		elseif typeof(task.disconnect) == "function" then
			local task = (task :: any) :: { disconnect: (...unknown) -> ...unknown }
			task:disconnect()
		end
	end
	
	alreadyDestroying[task] = nil
end

return doCleanup