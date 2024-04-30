--!strict
--!nolint LocalUnused
--!nolint LocalShadow
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

	it("should return similar for normal userdatas", function()
		local expect = getfenv().expect
		
        local userdata1 = newproxy(false)
		local userdata2 = newproxy(false)
		local userdata3 = newproxy(true)
		local userdata4 = newproxy(true)

        expect(isSimilar(userdata1, userdata1)).to.equal(true)
        expect(isSimilar(userdata1, userdata2)).to.equal(false)
        expect(isSimilar(userdata1, userdata3)).to.equal(false)
        expect(isSimilar(userdata1, userdata4)).to.equal(false)

		expect(isSimilar(userdata2, userdata1)).to.equal(false)
        expect(isSimilar(userdata2, userdata2)).to.equal(true)
        expect(isSimilar(userdata2, userdata3)).to.equal(false)
        expect(isSimilar(userdata2, userdata4)).to.equal(false)

		expect(isSimilar(userdata3, userdata1)).to.equal(false)
        expect(isSimilar(userdata3, userdata2)).to.equal(false)
        expect(isSimilar(userdata3, userdata3)).to.equal(true)
        expect(isSimilar(userdata3, userdata4)).to.equal(false)

		expect(isSimilar(userdata4, userdata1)).to.equal(false)
        expect(isSimilar(userdata4, userdata2)).to.equal(false)
        expect(isSimilar(userdata4, userdata3)).to.equal(false)
        expect(isSimilar(userdata4, userdata4)).to.equal(true)
    end)

	it("should respect __eq for userdatas", function()
		local expect = getfenv().expect
		
		local expectedOutput = true
        local original = newproxy(true)
		getmetatable(original).__eq = function()
			return expectedOutput
		end
		local sameEq = newproxy(true)
		getmetatable(sameEq).__eq = getmetatable(original).__eq
		local diffEq = newproxy(true)
		getmetatable(diffEq).__eq = function()
			return expectedOutput
		end

		expect(isSimilar(original, diffEq)).to.equal(false)
		expect(isSimilar(sameEq, diffEq)).to.equal(false)
        expect(isSimilar(diffEq, original)).to.equal(false)
        expect(isSimilar(diffEq, sameEq)).to.equal(false)
		expectedOutput = true
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
		expectedOutput = false
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
    end)

	it("should respect __eq for mutable tables", function()
		local expect = getfenv().expect

		local expectedOutput
		local original = setmetatable({}, {
			__eq = function(a, b)
				return expectedOutput
			end
		})
		local sameEq = setmetatable({}, {
			__eq = getmetatable(original).__eq
		})
		local diffEq = setmetatable({}, {
			__eq = function(a, b)
				return expectedOutput
			end
		})

        expect(isSimilar(original, diffEq)).to.equal(false)
		expect(isSimilar(sameEq, diffEq)).to.equal(false)
        expect(isSimilar(diffEq, original)).to.equal(false)
        expect(isSimilar(diffEq, sameEq)).to.equal(false)
		expectedOutput = true
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
		expectedOutput = false
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
    end)

	it("should respect __eq even when the metatable is locked opaquely", function()
		local expect = getfenv().expect

		local expectedOutput
		local function eq()
			return expectedOutput
		end
		local original: any = setmetatable({}, {
			__eq = eq,
			__metatable = "This metatable is locked"
		})
		local sameEq: any = setmetatable({}, {
			__eq = eq,
			__metatable = "This metatable is locked"
		})
		local diffEq: any = setmetatable({}, {
			__eq = function()
				return expectedOutput
			end,
			__metatable = "This metatable is locked"
		})

        expect(isSimilar(original, diffEq)).to.equal(false)
		expect(isSimilar(sameEq, diffEq)).to.equal(false)
        expect(isSimilar(diffEq, original)).to.equal(false)
        expect(isSimilar(diffEq, sameEq)).to.equal(false)
		expectedOutput = true
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
		expectedOutput = false
		expect(isSimilar(original, original)).to.equal(expectedOutput)
		expect(isSimilar(original, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, original)).to.equal(expectedOutput)
		expect(isSimilar(sameEq, sameEq)).to.equal(expectedOutput)
		expect(isSimilar(diffEq, diffEq)).to.equal(expectedOutput)
    end)

	it("should respect __eq for frozen tables", function()
		local expect = getfenv().expect

		local expectedOutput = true
		local immutable1 = table.freeze(setmetatable({}, {
			__eq = function(a, b)
				return expectedOutput
			end
		}))
		local immutable1b = table.freeze(setmetatable({}, getmetatable(immutable1)))
		local immutable2 = table.freeze(setmetatable({}, {
			__eq = function(a, b)
				return expectedOutput
			end
		}))

        expect(isSimilar(immutable1, immutable2)).to.equal(false)
		expect(isSimilar(immutable1b, immutable2)).to.equal(false)
        expect(isSimilar(immutable2, immutable1)).to.equal(false)
        expect(isSimilar(immutable2, immutable1b)).to.equal(false)
		expect(isSimilar(immutable1, immutable1)).to.equal(expectedOutput)
		expect(isSimilar(immutable1, immutable1b)).to.equal(expectedOutput)
		expect(isSimilar(immutable1b, immutable1)).to.equal(expectedOutput)
		expect(isSimilar(immutable1b, immutable1b)).to.equal(expectedOutput)
		expect(isSimilar(immutable2, immutable2)).to.equal(expectedOutput)
		expectedOutput = not expectedOutput
		expect(isSimilar(immutable1, immutable1)).to.equal(expectedOutput)
		expect(isSimilar(immutable1, immutable1b)).to.equal(expectedOutput)
		expect(isSimilar(immutable1b, immutable1)).to.equal(expectedOutput)
		expect(isSimilar(immutable1b, immutable1b)).to.equal(expectedOutput)
		expect(isSimilar(immutable2, immutable2)).to.equal(expectedOutput)
    end)

	it("should use equality for Roblox data types", function()
		local expect = getfenv().expect

		local a, b = Vector2.new(10, 10), Vector2.new(10, 10)
        expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)

		local a, b = Vector3.new(10, 10, 10), Vector3.new(10, 10, 10)
		expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)

		local a, b = CFrame.new(10, 10, 10), CFrame.new(10, 10, 10)
		expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)
    end)

	it("should correctly handle NaN for Roblox data types", function()
		local expect = getfenv().expect

        local a, b = Vector2.new(0/0, 0/0), Vector2.new(0/0, 0/0)
        expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)

		local a, b = Vector3.new(0/0, 0/0, 0/0), Vector3.new(0/0, 0/0, 0/0)
		expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)

		local a, b = CFrame.new(0/0, 0/0, 0/0), CFrame.new(0/0, 0/0, 0/0)
		expect(isSimilar(a, a)).to.equal(true)
		expect(isSimilar(a, b)).to.equal(true)
		expect(isSimilar(b, a)).to.equal(true)
		expect(isSimilar(b, b)).to.equal(true)
    end)
end