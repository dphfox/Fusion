--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local isSimilar = require(Fusion.Utility.isSimilar)

return function()
	local it = getfenv().it

    it("should return similar for identical values", function()
		local expect = getfenv().expect
		
        local value = 123

        expect(isSimilar(value, value)).to.equal(true)
    end)

    it("should return non-similar for different values", function()
		local expect = getfenv().expect
		
        local value1 = 123
        local value2 = 321

        expect(isSimilar(value1, value2)).to.equal(false)
    end)

    it("should return similar for any NaN values", function()
		local expect = getfenv().expect
		
        local nan1 = 0 / 0
        local nan2 = math.huge / math.huge

        expect(isSimilar(nan1, nan1)).to.equal(true)
        expect(isSimilar(nan1, nan2)).to.equal(true)
    end)

    it("should return non-similar for mutable tables", function()
		local expect = getfenv().expect
		
        local initialTable = { foo = 123, bar = "hello" }
        local similarTable = { foo = 123, bar = "hello" }
        local differentTable = { foo = 321, bar = "world" }

        expect(isSimilar(initialTable, initialTable)).to.equal(false)
        expect(isSimilar(initialTable, similarTable)).to.equal(false)
        expect(isSimilar(initialTable, differentTable)).to.equal(false)
    end)

	it("should return similar for equal frozen tables", function()
		local expect = getfenv().expect
		
        local initialTable = table.freeze { foo = 123, bar = "hello" }
        local similarTable = table.freeze { foo = 123, bar = "hello" }
        local differentTable = table.freeze { foo = 321, bar = "world" }

        expect(isSimilar(initialTable, initialTable)).to.equal(true)
        expect(isSimilar(initialTable, similarTable)).to.equal(false)
        expect(isSimilar(initialTable, differentTable)).to.equal(false)
    end)
end