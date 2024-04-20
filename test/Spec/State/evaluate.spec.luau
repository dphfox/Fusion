--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local evaluate = require(Fusion.State.evaluate)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)

return function()
	local describe = getfenv().describe

	Graphs.propertyTest {
		testing = "evaluate",
		it = "always ensures the target is valid",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object.validity = if index % 2 == 0 then "valid" else "invalid"
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return index // 2 % 2 == 0
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			for _, object in graph.allObjects do
				evaluate(object)
				if object.validity ~= "valid" then
					return `{Graphs.nameOf(object)} was not valid`
				end
			end
			return Graphs.check(
				graph.allObjects,
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "always ensures the last change time is non-nil, even after meaningless changes",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object.validity = if index % 2 == 0 then "valid" else "invalid"
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return index // 2 % 2 == 0
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			for _, object in graph.allObjects do
				local beforeTime = object.lastChange
				evaluate(object)
				if object.lastChange == nil then
					return `{Graphs.nameOf(object)} had a nil change time`
				end
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* evaluate prior dependencies",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return true
					end
				end
				local targets = Graphs.selectors.noConnections(graph.allObjects, "dependent")
				for _, object in 
					Graphs.selectors.distance(graph.allObjects, targets, "dependency", 1)
				do
					object.validity = "invalid"
				end
				return {graph}
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependent")
			for _, target in targets do
				evaluate(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependency", 1),
				Graphs.tests.validity("valid")
			) or Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependency", 2),
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "allows further evaluating/depending on objects during evaluation",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return true
					end
					object.validity = "invalid"
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependent")
			local diagnosis: string | false = false
			for _, target in targets do
				local dependencies = Graphs.selectors.distance(graph.allObjects, {target}, "dependency", 1)
				evaluate(target)
				diagnosis = diagnosis or Graphs.check(
					dependencies,
					Graphs.tests.validity("valid")
				)
			end
			return diagnosis
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* preserve dependency connections for objects that compute",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					object.validity = "invalid"
					object._evaluate = function()
						(object :: any).TEST_MARKER = true
						return false
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local foundTestMarker = false
			for _, object in graph.allObjects do
				evaluate(object)
				if not (object :: any).TEST_MARKER then
					continue
				end
				foundTestMarker = true
				if next(object.dependencySet) ~= nil then
					return `{Graphs.nameOf(object)} had dependencies after revalidation`
				end
			end
			if not foundTestMarker then
				return "no test marker was found - this is a spec bug"
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "preserves dependent connections",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return true
					end
					object.validity = "invalid"
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			for _, object in graph.allObjects do
				if next(object.dependentSet) == nil then
					continue
				end
				evaluate(object)
				if next(object.dependentSet) == nil then
					return `{Graphs.nameOf(object)} did not have dependents after revalidation`
				end
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* evaluate dependents",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return true
					end
					object.validity = "invalid"
				end
				local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
				local dependents = Graphs.selectors.distance(graph.allObjects, targets, "dependent", 1)
				for _, dependent in dependents do
					dependent._evaluate = function()
						error(`{Graphs.nameOf(dependent)} was evaluated`, 0)
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			for _, target in targets do
				evaluate(target)
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* run computations for already-valid objects with a last change",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for index, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						error(`{Graphs.nameOf(object)} was evaluated`, 0)
					end
					object.validity = "valid"
					object.lastChange = math.huge
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			for _, target in graph.allObjects do
				evaluate(target)
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "runs computations for invalid objects with no change time",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					object.validity = "invalid"
					object._evaluate = function()
						(object :: any).TEST_MARKER = true
						return false
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local didAnyTests = false
			for _, object in graph.allObjects do
				if object.validity ~= "invalid"  or object.lastChange ~= nil then
					continue
				end
				didAnyTests = true
				evaluate(object)
				if not (object :: any).TEST_MARKER then
					return `{Graphs.nameOf(object)} did not compute despite being invalid`
				end
			end
			if not didAnyTests then
				return "no tests were done - this is a spec bug"
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "runs computations for invalid objects with non-nil change time",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					object._evaluate = function()
						(object :: any).TEST_MARKER = true
						return false
					end
				end
				local searchNow = Graphs.selectors.noConnections(graph.allObjects, "dependency")
				for depth = 0, math.huge do
					local searchNext = {}
					local seen = {}
					for _, searchTarget in searchNow do
						searchTarget.lastChange = -depth
						searchTarget.validity = if depth == 0 then "valid" else "invalid"
						for dependent in searchTarget.dependentSet do
							if seen[dependent] then
								continue
							end
							seen[dependent] = true
							table.insert(searchNext, dependent)
						end
					end
					if #searchNext == 0 then
						break
					end
					searchNow = searchNext
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local didAnyTests = false
			for _, object in graph.allObjects do
				if object.validity ~= "invalid" or object.lastChange == nil then
					continue
				end
				didAnyTests = true
				evaluate(object)
				if not (object :: any).TEST_MARKER then
					return `{Graphs.nameOf(object)} did not compute despite being invalid`
				end
			end
			if not didAnyTests and #graph.allObjects > 1 then
				return "no tests were done - this is a spec bug"
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "updates the last change time for meaningful changes in direct dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = "not implemented"
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "updates the last change time for meaningful changes in transitive dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = "not implemented"
	} (describe)
		
	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* update the last change time for meaningless changes in direct dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = "not implemented"
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* update the last change time for meaningless changes in transitive dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = "not implemented"
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "throws an error for malformed graphs in finite time",
		filters = {Graphs.filters.malformed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					local dependencySet = table.clone(object.dependencySet)
					object._evaluate = function()
						object.dependencySet = table.clone(dependencySet)
						for dependency in object.dependencySet do
							evaluate(dependency)
						end
						return true
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local ok, err = pcall(function()
				for _, object in graph.objects do
					for _, object in graph.objects do
						object.validity = "invalid"
						object.lastChange = nil
					end
					evaluate(object)
				end
			end)
			if ok then
				return "Should not have completed without errors"
			elseif string.find(err, "infiniteLoop", 1, true) ~= nil then
				return false
			else
				return err
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "throws when encountering a busy object",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					object.validity = "busy"
				end
			end
		},
		perform = "not implemented"
	} (describe)
end