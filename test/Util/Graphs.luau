
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion
local Types = require(Fusion.Types)

export type GraphShape = {
	name: string,
	repr: {string},
	facts: {
		cyclic: boolean
	},
	objects: {string},
	edges: {
		{
			from: string,
			to: string
		}
	}
}
local function GraphShape(x: GraphShape)
	return x
end

export type Graph = {
	shape: GraphShape,
	objects: {[string]: Types.GraphObject}
}

export type PropertyTest = {
	name: string,
	init: (GraphShape) -> {
		{
			subName: string,
			graph: Graph
		}
	},
	perform: (Graph) -> boolean
}

local Graphs = {}

Graphs.STANDARD = {
	GraphShape {
		name = "Unit",
		repr = {
			"A";
		},
		facts = {
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = false
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
			cyclic = true
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
			cyclic = true
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
			cyclic = true
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

function Graphs.format(
	graph: Graph
): {string}

	local output = {`  ⁂ {graph.shape.name} : {table.concat(graph.shape.objects, ", ")}`}
	table.insert(output, " ")

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

	table.insert(output, " ")

	return output
end

function Graphs.make(
	scope: Types.Scope<unknown>,
	options: {
		shape: GraphShape,
		objects: {
			[string]: {
				scope: Types.Scope<unknown>?,
				lastChange: number?,
				timeliness: nil | "lazy" | "eager",
				validity: nil | "valid" | "invalid" | "busy",
				duringRevalidation: nil | (
					self: Types.GraphObject,
					name: string
				) -> boolean
			}
		}
	}
): Graph
	local objects = {}
	for _, name in options.shape.objects do
		local myOptions = options.objects[name]
		if myOptions == nil then
			myOptions = {}
		end

		local object: Types.GraphObject = {
			scope = myOptions.scope or scope,
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
	end
	for _, edge in options.shape.edges do
		local from = objects[edge.from]
		local to = objects[edge.to]
		from.dependentSet[to] = true
		to.dependencySet[from] = true
	end
	return {
		shape = options.shape,
		objects = objects
	}
end

function Graphs.propertyTest(
	it: any,
	expect: any,
	test: PropertyTest
): ()
	for _, shape in Graphs.STANDARD do
		local subTests = test.init(shape)

		for _, subTest in subTests do
			local testTitle =
				if #subTests == 1 then
					`{test.name} for {shape.name}`
				else
					`{test.name} ({subTest.subName}) for {shape.name}`
			
			it(testTitle, function()
				expect(function()
					test.perform(subTest.graph)
				end).never.to.throw()
			end)
		end
	end
end

return Graphs