local Package = game:GetService("ReplicatedStorage").Fusion
local updateAll = require(Package.Dependencies.updateAll)

local function edge(from, to)
	return { from = from, to = to }
end

local function buildReactiveGraph(ancestorsToDescendants, handler)
	local objects = {}

	local function getObject(named)
		if objects[named] then
			return objects[named]
		end
		local object = {
			dependencySet = {},
			dependentSet = {},
			update = handler,
			updates = 0,
			name = named
		}

		objects[named] = object

		return object
	end

	local function relate(ancestor, descendant)
		ancestor.dependentSet[descendant] = true
		descendant.dependencySet[ancestor] = true
	end

	for _, edge in ancestorsToDescendants do
		local ancestor = getObject(edge.from)
		local descendant = getObject(edge.to)
		relate(ancestor, descendant)
	end

	return objects
end

return function()
	it("should update transitive dependencies", function()
		local objects = buildReactiveGraph({
			edge("A", "B"),
			edge("B", "C"),
			edge("C", "D"),
		}, function(self)
			self.updates += 1
			return true
		end)

		updateAll(objects.A)

		expect(objects.A.updates).to.equal(0)
		expect(objects.B.updates).to.equal(1)
		expect(objects.C.updates).to.equal(1)
		expect(objects.D.updates).to.equal(1)
	end)

	it("should only update objects once", function()
		local objects = buildReactiveGraph({
			edge("A", "B"), edge("A", "C"),
			edge("B", "D"), edge("C", "D"),
		}, function(self)
			self.updates += 1
			return true
		end)

		updateAll(objects.A)

		expect(objects.A.updates).to.equal(0)
		expect(objects.B.updates).to.equal(1)
		expect(objects.C.updates).to.equal(1)
		expect(objects.D.updates).to.equal(1)
	end)

	it("should not update unchanged subgraphs", function()
		local objects = buildReactiveGraph({
			edge("A", "B"),
			edge("B", "C"),
			edge("C", "D"),
		}, function(self)
			self.updates += 1
			return if self.name == "C" then false else true
		end)

		updateAll(objects.A)

		expect(objects.A.updates).to.equal(0)
		expect(objects.B.updates).to.equal(1)
		expect(objects.C.updates).to.equal(1)
		expect(objects.D.updates).to.equal(0)
	end)

	it("should update state objects in subgraphs of unchanged state objects", function()
		local objects = buildReactiveGraph({
			edge("A", "B"), edge("A", "D"),
			edge("B", "C"),
			edge("C", "E"),
			edge("D", "E"),
			edge("E", "F"),
		}, function(self)
			self.updates += 1
			if self.name == "B" then
				return false
			else
				return true
			end
		end)

		updateAll(objects.A)

		expect(objects.A.updates).to.equal(0)
		expect(objects.B.updates).to.equal(1)
		expect(objects.C.updates).to.equal(0)
		expect(objects.D.updates).to.equal(1)
		expect(objects.E.updates).to.equal(1)
		expect(objects.F.updates).to.equal(1)
	end)

	it("should update complicated graphs correctly", function()
		local objects = buildReactiveGraph({
			edge("A", "B"), edge("A", "F"), edge("A", "I"),
			edge("B", "C"), edge("B", "D"), edge("B", "E"),
			edge("C", "E"), edge("C", "G"),
			edge("D", "F"),
			edge("E", "H"),
			edge("F", "I"),
			edge("G", "J"),
			edge("H", "J"),
			edge("I", "J"),
		}, function(self)
			self.updates += 1
			if self.name == "C" or self.name == "D" or self.name == "E" then
				return false
			else
				return true
			end
		end)

		updateAll(objects.A)

		expect(objects.A.updates).to.equal(0)
		expect(objects.B.updates).to.equal(1)
		expect(objects.C.updates).to.equal(1)
		expect(objects.D.updates).to.equal(1)
		expect(objects.E.updates).to.equal(1)
		expect(objects.F.updates).to.equal(1)
		expect(objects.G.updates).to.equal(0)
		expect(objects.H.updates).to.equal(0)
		expect(objects.I.updates).to.equal(1)
		expect(objects.J.updates).to.equal(1)
	end)
end