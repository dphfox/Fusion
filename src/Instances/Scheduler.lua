--[[
	Defers and orders UI data binding updates.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local None = require(Package.Utility.None)

local Scheduler = {}

local willUpdate = false
local propertyChanges: {[Instance]: {[string]: any}} = {}
local callbacks: Types.Set<() -> ()> = {}

--[[
	Enqueues an instance property to be updated next render step.
]]
function Scheduler.enqueueProperty(instance: Instance, propertyName: string, newValue: any)
	willUpdate = true

	-- we can't iterate over nil values of tables, so use a symbol instead
	if newValue == nil then
		newValue = None
	end

	local propertyTable = propertyChanges[instance]
	if propertyTable == nil then
		propertyChanges[instance] = {
			[propertyName] = newValue
		}
	else
		propertyTable[propertyName] = newValue
	end
end

--[[
	Enqueues a callback to be run next render step.
]]
function Scheduler.enqueueCallback(callback: TaskCallback)
	willUpdate = true
	callbacks[callback] = true
end

--[[
	Executes all enqueued tasks, and clears out the task lists ready for new
	tasks.
]]
function Scheduler.runTasks()
	-- if no tasks were enqueued, exit early
	if not willUpdate then
		return
	end

	-- execute property changes
	for instance, propertyTable in pairs(propertyChanges) do
		for property, value in pairs(propertyTable) do
			if value == None then
				value = nil
			end
			instance[property] = value
		end
	end

	-- run deferred callbacks
	for callback in pairs(callbacks) do
		callback()
	end

	willUpdate = false
	table.clear(propertyChanges)
	table.clear(callbacks)
end

RunService:BindToRenderStep(
	"__FusionUIScheduler",
	Enum.RenderPriority.Last.Value,
	Scheduler.runTasks
)

return Scheduler