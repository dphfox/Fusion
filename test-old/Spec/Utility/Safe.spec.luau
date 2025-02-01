--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Safe = require(Fusion.Utility.Safe)

return function()
	local it = getfenv().it

	it("returns values from try() on success", function()
		local expect = getfenv().expect

		expect(
			Safe {
				try = function()
					return "foo"
				end,
				fallback = function()
					return "bar"
				end
			}
		).to.equal("foo")
	end)

	it("returns values from fallback() on error", function()
		local expect = getfenv().expect

		expect(
			Safe {
				try = function()
					error("garb", 0)
					return "foo"
				end,
				fallback = function()
					return "bar"
				end
			}
		).to.equal("bar")
	end)

	it("passes the error on to fallback()", function()
		local expect = getfenv().expect

		expect(
			Safe {
				try = function()
					error("garb", 0)
					return "foo"
				end,
				fallback = function(err)
					return "bar" .. tostring(err)
				end
			}
		).to.equal("bargarb")
	end)
end