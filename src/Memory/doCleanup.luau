--!strict
--!nolint LocalUnused
--!nolint LocalShadow
<<<<<<< HEAD
local chore = nil -- Disable usage of Roblox's chore scheduler

--[[
	Cleans up the chores passed in as the arguments.
	A chore can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a thread - will be canceled
=======
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
>>>>>>> upstream/main
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]
<<<<<<< HEAD

local function doCleanupOne(
	chore: unknown
)
	local choreType = typeof(chore)

	-- case 1: Instance
	if choreType == "Instance" then
		local chore = chore :: Instance
		chore:Destroy()

	-- case 2: RBXScriptConnection
	elseif choreType == "RBXScriptConnection" then
		local chore = chore :: RBXScriptConnection
		chore:Disconnect()

	-- case 3: thread
	elseif choreType == "thread" then
		local chore = chore :: thread
		local cancelled; if coroutine.running() ~= chore then
			cancelled = pcall(function() task.cancel(chore) end)
		end; if not cancelled then local toCancel = chore
			task.defer(function()
				task.cancel(toCancel)
			end)
		end

	-- case 4: callback
	elseif choreType == "function" then
		local chore = chore :: (...unknown) -> (...unknown)
		chore()

	elseif choreType == "table" then
		local chore = chore :: {destroy: unknown?, Destroy: unknown?}

		-- case 5: destroy() function
		if typeof(chore.destroy) == "function" then
			local chore = (chore :: any) :: {destroy: (...unknown) -> (...unknown)}
			chore:destroy()

		-- case 6: Destroy() function
		elseif typeof(chore.Destroy) == "function" then
			local chore = (chore :: any) :: {Destroy: (...unknown) -> (...unknown)}
			chore:Destroy()

		-- case 7: array of chores
		elseif chore[1] ~= nil then
			local chore = chore :: {unknown}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #chore, 1, -1 do
				doCleanupOne(chore[index])
				chore[index] = nil
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
=======
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
>>>>>>> upstream/main
end

return doCleanup