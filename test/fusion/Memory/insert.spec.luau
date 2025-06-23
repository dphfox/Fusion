--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local insert = require("../../../src/Memory/insert")

return function(tiniest: tiniest.Configured): ()
	local test = tiniest.test
	local expect = tiniest.expect

	test("nothing", function()
		local list: any = {1, 2, 3}
		insert(list)
		expect(list[3]).is(3)
		expect(list[4]).never_exists()
	end)

	test("single", function()
		local list: any = {1, 2, 3}
		local a = insert(list, 4)
		expect(a).is(4)
		expect(list[3]).is(3)
		expect(list[4]).is(4)
		expect(list[5]).never_exists()
	end)

	test("bulk", function()
		local list: any = {1, 2, 3}
		local a, b, c = insert(list, 4, 5, 6)
		expect(a).is(4)
		expect(b).is(5)
		expect(c).is(6)
		expect(list[3]).is(3)
		expect(list[4]).is(4)
		expect(list[5]).is(5)
		expect(list[6]).is(6)
		expect(list[7]).never_exists()
	end)
end