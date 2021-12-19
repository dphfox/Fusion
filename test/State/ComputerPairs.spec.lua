local Package = game:GetService("ReplicatedStorage").Fusion
local ComputedPairs = require(Package.State.ComputedPairs)
local Value = require(Package.State.Value)
local New = require(Package.Instances.New)

return function()
    it("should not allow the processor function to yield", function()
		local state = Value({"foo", "bar"})

		expect(function()
			ComputedPairs(state, function(key, value)
				task.wait()
				return New "TextLabel" {
                    Text = value
                }
			end)
		end).to.throw("computedPairsCannotYield")

		local counter = 0
		local computedDelayed = ComputedPairs(state, function(key, value)
            if counter > 1 then
				task.wait()
			end

            counter += 1

            return New "TextLabel" {
                Text = value
            }
        end)

		expect(function()
			state:set({"foo", "bar", "baz"})
		end).to.throw("computedPairsCannotYield")
	end)
end