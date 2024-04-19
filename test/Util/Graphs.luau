--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion
local Types = require(Fusion.Types)

local FiniteTime = require(script.Parent.FiniteTime)

export type GraphShape = {
	name: string,
	repr: {string},
	facts: {
		wellFormed: boolean
	},
	-- Objects should be topologically ordered.
	objects: {string},
	edges: {
		{
			from: string,
			to: string
		}
	}
}
local function GraphShape(x: GraphShape)
	if x.facts.wellFormed then
		local reverseIndex = {}
		for index, object in x.objects do
			assert(reverseIndex[object] == nil, "Duplicate object definition: " .. object)
			reverseIndex[object] = index
		end
		for _, edge in x.edges do
			if reverseIndex[edge.to] < reverseIndex[edge.from] then
				error(`{edge.to} appears before {edge.from} even though it's a dependency.`)
			end
		end
	end
	return x
end

export type Graph = {
	shape: GraphShape,
	objects: {[string]: Types.GraphObject},
	allObjects: {Types.GraphObject}
}

local Graphs = {}

Graphs.STANDARD = {
	GraphShape {
		name = "Unit",
		repr = {
			"A";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A"},
		edges = {
		}
	},

	GraphShape {
		name = "Pair",
		repr = {
			"A";
			"↓";
			"B";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B"},
		edges = {
			{from = "A", to = "B"}
		}
	},

	GraphShape {
		name = "Chain",
		repr = {
			"A";
			"↓";
			"B";
			"↓";
			"C";
			"↓";
			"D";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "B"},
			{from = "B", to = "C"},
			{from = "C", to = "D"}
		}
	},

	GraphShape {
		name = "Many In",
		repr = {
			"A B C";
			" ↘↓↙ ";
			"  D  ";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "D"},
			{from = "B", to = "D"},
			{from = "C", to = "D"}
		}
	},

	GraphShape {
		name = "Many Out",
		repr = {
			"  A  ";
			" ↙↓↘ ";
			"B C D";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "B"},
			{from = "A", to = "C"},
			{from = "A", to = "D"}
		}
	},

	GraphShape {
		name = "N",
		repr = {
			"  A  ";
			" ↙ ↘ ";
			"B   C";
			"↓   ↓";
			"D   E";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D", "E"},
		edges = {
			{from = "A", to = "B"},
			{from = "A", to = "C"},
			{from = "B", to = "D"},
			{from = "C", to = "E"}
		}
	},

	GraphShape {
		name = "M",
		repr = {
			"A   B";
			"↓↘ ↙↓";
			"↓↙ ↘↓";
			"C   D";
			"↓   ↓";
			"E   F";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D", "E", "F"},
		edges = {
			{from = "A", to = "C"},
			{from = "A", to = "D"},
			{from = "B", to = "C"},
			{from = "B", to = "D"},
			{from = "C", to = "E"},
			{from = "D", to = "F"}
		}
	},

	GraphShape {
		name = "Diamond",
		repr = {
			"  A  ";
			" ↙ ↘ ";
			"B   C";
			" ↘ ↙ ";
			"  D  ";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "B"},
			{from = "A", to = "C"},
			{from = "B", to = "D"},
			{from = "C", to = "D"}
		}
	},

	GraphShape {
		name = "Pentagon",
		repr = {
			"  A  ";
			" ↙ ↘ ";
			"B   ↓";
			"↓   C";
			"D   ↓";
			" ↘ ↙ ";
			"  E  ";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D", "E"},
		edges = {
			{from = "A", to = "B"},
			{from = "A", to = "C"},
			{from = "B", to = "D"},
			{from = "C", to = "E"},
			{from = "D", to = "E"}
		}
	},

	GraphShape {
		name = "Hexagon",
		repr = {
			"  A  ";
			" ↙ ↘ ";
			"B   C";
			"↓   ↓";
			"D   E";
			" ↘ ↙ ";
			"  F  ";
		},
		facts = {
			wellFormed = true
		},
		objects = {"A", "B", "C", "D", "E", "F"},
		edges = {
			{from = "A", to = "B"},
			{from = "A", to = "C"},
			{from = "B", to = "D"},
			{from = "C", to = "E"},
			{from = "D", to = "F"},
			{from = "E", to = "F"}
		}
	},

	GraphShape {
		name = "Pair Cycle",
		repr = {
			"  A  ";
			" ↙ ↖ ";
			" ↘ ↗ ";
			"  B  ";
		},
		facts = {
			wellFormed = false
		},
		objects = {"A", "B"},
		edges = {
			{from = "A", to = "B"},
			{from = "B", to = "A"}
		}
	},

	GraphShape {
		name = "Cycle In Chain",
		repr = {
			"  A  ";
			"  ↓  ";
			"  B  ";
			" ↙ ↖ ";
			" ↘ ↗ ";
			"  C  ";
			"  ↓  ";
			"  D  ";
		},
		facts = {
			wellFormed = false
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "B"},
			{from = "B", to = "C"},
			{from = "C", to = "B"},
			{from = "C", to = "D"}
		}
	},

	GraphShape {
		name = "Circle",
		repr = {
			"  A  ";
			" ↙ ↖ ";
			"B   D";
			" ↘ ↗ ";
			"  C  ";
		},
		facts = {
			wellFormed = false
		},
		objects = {"A", "B", "C", "D"},
		edges = {
			{from = "A", to = "B"},
			{from = "B", to = "C"},
			{from = "C", to = "D"},
			{from = "D", to = "A"}
		}
	},
}

Graphs.filters = {}

function Graphs.filters.wellFormed(
	shape: GraphShape
): boolean
	return shape.facts.wellFormed
end

function Graphs.filters.malformed(
	shape: GraphShape
): boolean
	return not shape.facts.wellFormed
end

Graphs.selectors = {}

function Graphs.selectors.distance(
	selectFrom: {Types.GraphObject},
	distanceFrom: {Types.GraphObject},
	kind: "dependency" | "dependent",
	desiredDistance: number
)
	local isFindTarget: {[Types.GraphObject]: true} = {}
	for _, object in distanceFrom or {} :: any  do
		isFindTarget[object] = true
	end
	local selection = {}
	for _, object in selectFrom do
		local searchNow = {[object] = true}
		local searchNext = {}
		for distance = 0, desiredDistance do
			local found = false
			for searchTarget in searchNow do
				if isFindTarget[searchTarget] then
					found = true
					continue
				end
				local searchSet: {[Types.GraphObject]: unknown} = 
					if kind == "dependency" then 
						searchTarget.dependencySet 
					else 
						searchTarget.dependentSet
				for dependent in searchSet do
					searchNext[dependent] = true
				end
			end
			if found then
				if distance == desiredDistance then
					table.insert(selection, object)
				else
					break
				end
			end
			searchNow, searchNext = searchNext, searchNow
			table.clear(searchNext)
		end
	end
	return selection
end

function Graphs.selectors.noConnections(
	selectFrom: {Types.GraphObject},
	kind: "dependency" | "dependent"
)
	local selection = {}
	for _, object in selectFrom do
		local searchSet: {[Types.GraphObject]: unknown} = 
			if kind == "dependency" then 
				object.dependencySet 
			else 
				object.dependentSet
		if next(searchSet) == nil then
			table.insert(selection, object)
		end
	end
	return selection
end

Graphs.tests = {}

function Graphs.tests.validity(
	shouldBe: "valid" | "invalid" | "busy"
)
	return function(
		object: Types.GraphObject
	): string | false
		if object.validity ~= shouldBe then
			return `{Graphs.nameOf(object)} was "{object.validity}" instead of "{shouldBe}"`
		else
			return false
		end
	end
end

function Graphs.check(
	objects: {Types.GraphObject},
	test: (Types.GraphObject) -> string | false
): string | false
	for _, object in objects do
		local diagnosis = test(object)
		if diagnosis ~= false then
			return diagnosis :: string
		end
	end
	return false
end

function Graphs.nameOf(
	object: Types.GraphObject
): string
	return (object :: any).name or "GraphObject"
end

function Graphs.format(
	output: {string},
	graph: Graph
): ()

	local VALIDITY_SYMBOLS = {
		valid = "✓",
		invalid = "✕",
		busy = "◷"
	}

	local TIMELINESS_SYMBOLS = {
		lazy = "▽",
		eager = "▼"
	}

	local ARROWS = {"↑", "↗", "→", "↘", "↓", "↙", "←", "↖"}

	local line = 1
	local reprWidth = 0
	while true do
		local edge = graph.shape.edges[line]
		local reprLine = graph.shape.repr[line]

		if edge == nil and reprLine == nil then
			break
		end

		if reprLine ~= nil then
			reprWidth = math.max(reprWidth, #reprLine)
		else
			reprLine = string.rep(" ", reprWidth)
		end

		local reprLineNoArrows = reprLine

		for _, arrow in ARROWS do
			reprLineNoArrows = string.gsub(reprLineNoArrows, arrow, " ")
		end

		local validityLine = string.gsub(reprLineNoArrows, "%w+", function(name: string)
			local object = graph.objects[name]
			if object == nil then
				return name
			else
				local symbol = VALIDITY_SYMBOLS[object.validity] or "?"
				return string.rep(symbol, #name)
			end
		end)

		local timelinessLine = string.gsub(reprLineNoArrows, "%w+", function(name: string)
			local object = graph.objects[name]
			if object == nil then
				return name
			else
				local symbol = TIMELINESS_SYMBOLS[object.timeliness] or "?"
				return string.rep(symbol, #name)
			end
		end)

		local edgeLine = ""
		do
			if graph.shape.edges[line] ~= nil then
				edgeLine = `{edge.from} → {edge.to}`
			end
		end

		table.insert(output, `  |  {reprLine}  |  {validityLine}  |  {timelinessLine}  |  {edgeLine}`)

		line += 1
	end
end

export type ObjectTemplate = {
	scope: Types.Scope<unknown>?,
	lastChange: number?,
	timeliness: nil | "lazy" | "eager",
	validity: nil | "valid" | "invalid" | "busy",
	duringRevalidation: nil | (
		self: Types.GraphObject,
		name: string
	) -> boolean
}

function Graphs.make(
	scope: Types.Scope<unknown>,
	options: {
		shape: GraphShape,
		objects: {
			[string]: ObjectTemplate
		}
	}
): Graph
	local objects = {}
	local allObjects = {}
	for _, name in options.shape.objects do
		local myOptions = options.objects[name]
		if myOptions == nil then
			myOptions = {}
		end

		local object: Types.GraphObject = {
			scope = myOptions.scope or scope,
			name = name,
			dependencySet = {},
			dependentSet = {},
			lastChange = myOptions.lastChange or nil,
			timeliness = myOptions.timeliness :: any or "lazy",
			validity = myOptions.validity :: any or "valid",
			duringRevalidation =
				if myOptions.duringRevalidation == nil then
					function()
						return true
					end
				else
					function(self)
						return myOptions.duringRevalidation(self, name)
					end,
			destroy = function(...): ()

			end
		}

		objects[name] = object
		table.insert(allObjects, object)
	end
	for _, edge in options.shape.edges do
		local from = objects[edge.from]
		local to = objects[edge.to]
		from.dependentSet[to] = true
		to.dependencySet[from] = true
	end
	return {
		shape = options.shape,
		objects = objects,
		allObjects = allObjects
	}
end

type PropertySubTest = {
	subName: string,
	graph: Graph
}
function Graphs.propertyTest(
	test: {
		testing: string,
		it: string,
		filters: {(GraphShape) -> boolean},
		prepare: nil | (Graph) -> {Graph},
		perform: (Graph) -> string | false
	}
)
	return function(describe: any): ()
		describe(test.it, function()
			getfenv().FOCUS() --temporary
			local it = getfenv().it
			
			local didAnyTests = false
			local detectedNotImplemented = false
			for _, shape in Graphs.STANDARD do
				local filtered = false
				for _, filter in test.filters do
					if not filter(shape) then
						filtered = true
						break
					end
				end
				if filtered then
					continue
				end
		
				local plainGraph = Graphs.make({}, {
					shape = shape,
					objects = {}
				})
				local subTests: {Graph} = if test.prepare == nil then {plainGraph} else test.prepare(plainGraph)

				for index, graph in subTests do
					local testTitle = if #subTests == 1 then shape.name else `{shape.name} [{index}]`
					
					didAnyTests = true
					it(testTitle, function()
						local preStateFormatted = {}
						Graphs.format(preStateFormatted, graph)
						-- Because an incorrect algorithm is prone to hang,
						-- implement a time limit as a backup strategy to
						-- avoid hanging the entire test suite.
						local timeCheck = FiniteTime.start(1)
						for _, object in graph.objects do
							local metatable = getmetatable(object :: any)
							if metatable == nil then
								metatable = {}
								setmetatable(object, metatable)
							end
							local realValidity = object.validity
							object.validity = nil :: any
							function metatable:__index(key)
								if key == "validity" then
									timeCheck()
									return realValidity
								else
									return rawget(self, key)
								end
							end
							function metatable:__newindex(key, value)
								if key == "validity" then
									timeCheck()
									realValidity = value
								else
									return rawset(self, key, value)
								end
							end
						end
						local ok, diagnosis = pcall(test.perform, graph)
						if not ok or typeof(diagnosis) == "string" then
							if diagnosis == "not implemented" then
								if not detectedNotImplemented then
									warn(`{test.testing} - Property test not implemented: "{test.it}"`)
									detectedNotImplemented = true
								end
								return
							elseif string.find(diagnosis, "FUSION_TEST_FINITE_TIME", 1, true) ~= nil then
								diagnosis = "the test took an unreasonable amount of time."
							end
							local output = {
								"",
								"",
								`  Tested {test.testing} ...`,
								`  ... spec says it {test.it} ...`,
								`  ... but {diagnosis}`,
								"",
								"  Initial state of graph after preparation:",
								"",
								unpack(preStateFormatted)
							}
							table.insert(output, "")
							table.insert(output, "  Final state of graph after error:")
							table.insert(output, "")
							Graphs.format(output, graph)
							table.insert(output, "")

							error(table.concat(output, "\n"))
						end
					end)
				end
			end
			if not didAnyTests then
				warn(`{test.testing} - No property tests produced for: "{test.it}"`)
			end
		end)
	end
end

return Graphs