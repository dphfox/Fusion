local Package = game:GetService("ReplicatedStorage").Fusion
local scoped = require(Package.Memory.scoped)

return function()
	-- it("should accept zero arguments", function()
	-- 	local merged = merge()

	-- 	expect(merged).to.be.a("table")
	-- 	expect(#merged).to.equal(0)
	-- end)

	-- it("should clone single arguments", function()
	-- 	local original = {foo = "FOO", bar = "BAR", baz = "BAZ"}
	-- 	local merged = merge(original)

	-- 	expect(merged).to.be.a("table")
	-- 	expect(merged).to.never.equal(original)
	-- 	for key, value in original do
	-- 		expect(merged[key]).to.equal(value)
	-- 	end
	-- end)

	-- it("should merge two arguments", function()
	-- 	local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
	-- 	local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
	-- 	local merged = merge(originalA, originalB)

	-- 	expect(merged).to.be.a("table")
	-- 	for _, original in {originalA, originalB} do
	-- 		expect(merged).to.never.equal(original)
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 	end
	-- end)

	-- it("should merge three arguments", function()
	-- 	local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
	-- 	local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
	-- 	local originalC = {grep = "GREP", bork = "BORK", grum = "GRUM"}
	-- 	local merged = merge(originalA, originalB, originalC)

	-- 	expect(merged).to.be.a("table")
	-- 	for _, original in {originalA, originalB, originalC} do
	-- 		expect(merged).to.never.equal(original)
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 		for key, value in original do
	-- 			expect(merged[key]).to.equal(value)
	-- 		end
	-- 	end
	-- end)

	-- it("should error on collision", function()
	-- 	expect(function()
	-- 		local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
	-- 		local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
	-- 		local originalC = {grep = "GREP", grok = "GROK", grum = "GRUM"}
	-- 		merge(originalA, originalB, originalC)
	-- 	end).to.throw("mergeConflict")
	-- end)
end