local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local Observer = require(Package.State.Observer)
local Value = require(Package.Core.Value)

return function()
	it("should fire connections on change", function()
		local state = Value(false)
		local observer = Observer(state)

		local changed = false
		observer:onChange(function()
			changed = true
		end)

		state:set(true)

		-- Wait twice in case it gets deferred
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()

		expect(changed).to.equal(true)
	end)

	it("should fire connections only after the value changes", function()
		local state = Value(false)
		local observer = Observer(state)

		local changedValue
		local completed = false
		observer:onChange(function(value)
			changedValue = state:get()
			completed = true
		end)

		state:set(true)

		-- Wait twice in case it gets deferred
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()

		expect(changedValue).to.equal(true)
	end)

	it("should fire connections only once after the value changes", function()
		local state = Value(false)
		local observer = Observer(state)

		local timesFired = 0
		local completed = false
		observer:onChange(function(value)
			timesFired += 1
			completed = true
		end)

		state:set(true)

		-- Wait twice in case it gets deferred
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()

		expect(timesFired).to.equal(1)
	end)
end