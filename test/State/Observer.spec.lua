local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local Observer = require(Package.State.Observer)
local Value = require(Package.State.Value)

local function waitForDefer()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end

return function()
    it("should fire connections on change", function()
        local state = Value(false)
        local observer = Observer(state)

        local changed = false
        observer:onChange(function()
            changed = true
        end)

        local start = os.clock()
        local timeout = 2
        
        state:set(true)

        repeat
            RunService.RenderStepped:Wait()
            if os.clock() - start > timeout then
                error("Observer did not fire connections on change")
            end
        until changed
        
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

        local start = os.clock()
        local timeout = 2
        
        state:set(true)
        
        repeat
            RunService.RenderStepped:Wait()
            if os.clock() - start > timeout then
                error("Observer did not fire connections on change")
            end
        until completed

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

        local start = os.clock()
        local timeout = 2
        
        state:set(true)
        
        repeat
            RunService.RenderStepped:Wait()
            if os.clock() - start > timeout then
                error("Observer did not fire connections on change")
            end
        until completed

        waitForDefer()

        expect(timesFired).to.equal(1)
    end)
end