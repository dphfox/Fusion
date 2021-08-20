local Package = game:GetService("ReplicatedStorage").Fusion
local Scheduler = require(Package.Instances.Scheduler)

local function callback()

end

return {

	{
		name = "Enqueue property change on instance",
		calls = 50000,

		preRun = function()
			return Instance.new("Folder")
		end,

		run = function(ins)
			Scheduler.enqueueProperty(ins, "Name", 5, "Foo")
		end,

		postRun = function(ins)
			Scheduler.runTasks()
			ins:Destroy()
		end
	},

	{
		name = "[1 call] Enqueue property change on instance",
		calls = 1,

		preRun = function()
			return Instance.new("Folder")
		end,

		run = function(ins)
			Scheduler.enqueueProperty(ins, "Name", 5, "Foo")
		end,

		postRun = function(ins)
			Scheduler.runTasks()
			ins:Destroy()
		end
	},

	{
		name = "Enqueue callback to be called",
		calls = 50000,

		run = function()
			Scheduler.enqueueCallback(callback)
		end,

		postRun = function()
			Scheduler.runTasks()
		end
	},

	{
		name = "[1 call] Enqueue callback to be called",
		calls = 1,

		run = function()
			Scheduler.enqueueCallback(callback)
		end,

		postRun = function()
			Scheduler.runTasks()
		end
	},

	{
		name = "Enqueue + run tasks - Single property, single instance, single priority",
		calls = 50000,

		preRun = function()
			return Instance.new("Folder")
		end,

		run = function(ins)
			Scheduler.enqueueProperty(ins, "Name", 5, "Foo")
			Scheduler.runTasks()
		end,

		postRun = function(ins)
			ins:Destroy()
		end
	},

	{
		name = "Enqueue + run tasks - Single property, many instances, single priority",
		calls = 50000,

		preRun = function()
			return {
				[1] = Instance.new("Folder"),
				[2] = Instance.new("Folder"),
				[3] = Instance.new("Folder"),
				[4] = Instance.new("Folder"),
				[5] = Instance.new("Folder")
			}
		end,

		run = function(ins)
			Scheduler.enqueueProperty(ins[1], "Name", 5, "Foo")
			Scheduler.enqueueProperty(ins[2], "Name", 5, "Foo")
			Scheduler.enqueueProperty(ins[3], "Name", 5, "Foo")
			Scheduler.enqueueProperty(ins[4], "Name", 5, "Foo")
			Scheduler.enqueueProperty(ins[5], "Name", 5, "Foo")
			Scheduler.runTasks()
		end,

		postRun = function(ins)
			for _, member in ipairs(ins) do
				member:Destroy()
			end
		end
	},

	{
		name = "Enqueue + run tasks - Single property, many instances, many priorities",
		calls = 50000,

		preRun = function()
			return {
				[1] = Instance.new("Folder"),
				[2] = Instance.new("Folder"),
				[3] = Instance.new("Folder"),
				[4] = Instance.new("Folder"),
				[5] = Instance.new("Folder")
			}
		end,

		run = function(ins)
			Scheduler.enqueueProperty(ins[1], "Name", 1, "Foo")
			Scheduler.enqueueProperty(ins[2], "Name", 2, "Foo")
			Scheduler.enqueueProperty(ins[3], "Name", 3, "Foo")
			Scheduler.enqueueProperty(ins[4], "Name", 4, "Foo")
			Scheduler.enqueueProperty(ins[5], "Name", 5, "Foo")
			Scheduler.runTasks()
		end,

		postRun = function(ins)
			for _, member in ipairs(ins) do
				member:Destroy()
			end
		end
	},

	{
		name = "Run tasks - nothing queued",
		calls = 50000,

		run = function()
			Scheduler.runTasks()
		end
	},

}