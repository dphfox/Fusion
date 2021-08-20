-- it("should fire its onChange event when it is updated", function()
-- 	local currentNumber = State(2)
-- 	local doubled = Computed(function()
-- 		return currentNumber:get() * 2
-- 	end)

-- 	local fires = 0

-- 	doubled.onChange:Connect(function()
-- 		fires += 1
-- 	end)

-- 	expect(fires).to.equal(0)

-- 	currentNumber:set(4)
-- 	expect(fires).to.equal(1)

-- 	currentNumber:set(0)
-- 	expect(fires).to.equal(2)
-- end)

-- it("should fire change handlers, even when out of scope", function()
-- 	local state = State(1)

-- 	local counter = 0

-- 	do
-- 		local computed = Computed(function()
-- 			return state:get()
-- 		end)

-- 		computed.onChange:Connect(function()
-- 			counter += 1
-- 		end)
-- 	end

-- 	state:set(2)
-- 	waitForGC()
-- 	state:set(3)

-- 	expect(counter).to.equal(2)
-- end)

return function()
	return {}
end