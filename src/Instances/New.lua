--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local cleanupOnDestroy = require(Package.Utility.cleanupOnDestroy)
local Children = require(Package.Instances.Children)
local Scheduler = require(Package.Instances.Scheduler)
local defaultProps = require(Package.Instances.defaultProps)
local Compat = require(Package.State.Compat)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)

local WEAK_KEYS_METATABLE = {__mode = "k"}

local ENABLE_EXPERIMENTAL_GC_MODE = false

-- NOTE: this needs to be weakly held so gc isn't inhibited
local overrideParents: {[Instance]: Types.StateOrValue<Instance>} = setmetatable({}, WEAK_KEYS_METATABLE)

local function New(className: string)
	return function(propertyTable: {[string | Types.Symbol]: any})
		-- things to clean up when the instance is destroyed or gc'd
		local cleanupTasks = {}
		-- event handlers to connect
		local toConnect: {[RBXScriptSignal]: () -> ()} = {}

		--[[
			STEP 1: Create a reference to a new instance
		]]
		local refMetatable = {__mode = ""}
		local ref = setmetatable({}, refMetatable)
		local conn

		do
			local createOK, instance = pcall(Instance.new, className)
			if not createOK then
				logError("cannotCreateClass", nil, className)
			end

			local defaultClassProps = defaultProps[className]
			if defaultClassProps ~= nil then
				for property, value in pairs(defaultClassProps) do
					instance[property] = value
				end
			end

			ref.instance = instance

			conn = instance.Changed:Connect(function() end)
			instance = nil
		end

		--[[
			STEP 2: Apply properties and event handlers
		]]
		for key, value in pairs(propertyTable) do
			-- ignore some keys which will be processed later
			if key == Children or key == "Parent" then
				continue

			--[[
				STEP 2.1: Property (string) keys
			]]
			elseif typeof(key) == "string" then

				-- Properties bound to state
				if typeof(value) == "table" and value.type == "State" then
					local assignOK = pcall(function()
						ref.instance[key] = value:get(false)
					end)

					if not assignOK then
						logError("cannotAssignProperty", nil, className, key)
					end

					table.insert(cleanupTasks,
						Compat(value):onChange(function()
							if ref.instance == nil then
								if ENABLE_EXPERIMENTAL_GC_MODE then
									if conn.Connected then
										warn("ref is nil and instance is around!!!")
									else
										print("ref is nil, but instance was destroyed")
									end
								end
								return
							end
							Scheduler.enqueueProperty(ref.instance, key, value:get(false))
						end)
					)

				-- Properties with constant values
				else
					local assignOK = pcall(function()
						ref.instance[key] = value
					end)

					if not assignOK then
						logError("cannotAssignProperty", nil, className, key)
					end
				end

			--[[
				STEP 2.2: Symbol keys
			]]
			elseif typeof(key) == "table" and key.type == "Symbol" then

				-- Event handler
				if key.name == "OnEvent" then
					local event

					if
						not pcall(function()
							event = ref.instance[key.key]
						end) or
						typeof(event) ~= "RBXScriptSignal"
					then
						logError("cannotConnectEvent", nil, className, key.key)
					end

					toConnect[event] = value

				-- Property change handler
				elseif key.name == "OnChange" then
					local event

					if
						not pcall(function()
							event = ref.instance:GetPropertyChangedSignal(key.key)
						end)
					then
						logError("cannotConnectChange", nil, className, key.key)
					end

					toConnect[event] = function()
						if ref.instance == nil then
							if ENABLE_EXPERIMENTAL_GC_MODE then
								if conn.Connected then
									warn("ref is nil and instance is around!!!")
								else
									print("ref is nil, but instance was destroyed")
								end
							end
							return
						end
						value(ref.instance[key.key])
					end

				-- Unknown symbol key
				else
					logError("unrecognisedPropertyKey", nil, key.name)
				end

			-- Unknown key of arbitrary type
			else
				logError("unrecognisedPropertyKey", nil, typeof(key))
			end
		end

		--[[
			STEP 3: If provided, parent [Children] to instance
		]]
		local children = propertyTable[Children]
		if children ~= nil then
			local currentChildren = {}
			local prevChildren = {}

			local currentConnections = {}
			local prevConnections = {}

			local function updateCurrentlyParented()
				if ref.instance == nil then
					if ENABLE_EXPERIMENTAL_GC_MODE then
						if conn.Connected then
							warn("ref is nil and instance is around!!!")
						else
							print("ref is nil, but instance was destroyed")
						end
					end
					return
				end

				prevChildren, currentChildren = currentChildren, prevChildren
				prevConnections, currentConnections = currentConnections, prevConnections

				local function recursiveAddChild(child)
					local childType = typeof(child)

					if childType == "Instance" then
						-- single instance child

						currentChildren[child] = true

						-- reused or newly parented logic
						if prevChildren[child] == nil then
							if overrideParents[child] == nil then
								child.Parent = ref.instance
							end
						else
							prevChildren[child] = nil
						end

					elseif childType == "table" then
						-- could either be an array or state object

						if child.type == "State" then
							-- state object

							recursiveAddChild(child:get(false))

							-- reuse old connection change handler if possible
							local prevDisconnect = prevConnections[child]
							if prevDisconnect ~= nil then
								currentConnections[child] = prevDisconnect
								prevConnections[child] = nil
							else
								-- FUTURE: does this need to be cleaned up when
								-- the instance is destroyed at any point?
								-- If so, how?
								currentConnections[child] = Compat(child):onChange(function()
									Scheduler.enqueueCallback(updateCurrentlyParented)
								end)
							end
						else
							-- array of children
							for _, subChild in pairs(child) do
								recursiveAddChild(subChild)
							end
						end

					-- explicitly allow nils (probably inside a state object)
					elseif childType ~= "nil" then
						logWarn("unrecognisedChildType", childType)
					end
				end

				recursiveAddChild(children)

				-- clean up previous children which weren't reused
				for prevChild in pairs(prevChildren) do
					if overrideParents[prevChild] == nil then
						prevChild.Parent = nil
					end
				end

				-- clean up previous connection handlers which weren't reused
				for prevState, disconnect in pairs(prevConnections) do
					disconnect()
				end

				table.clear(prevChildren)
				table.clear(prevConnections)
			end

			updateCurrentlyParented()
		end

		--[[
			STEP 4: If provided, override the Parent of this instance
		]]
		local parent = propertyTable.Parent
		if parent ~= nil then
			overrideParents[ref.instance] = parent

			if typeof(parent) == "table" and parent.type == "State" then
				-- bind parent to state object
				local assignOK = pcall(function()
					ref.instance.Parent = parent:get(false)
				end)

				if not assignOK then
					logError("cannotAssignProperty", nil, className, "Parent")
				end

				table.insert(cleanupTasks,
					Compat(parent):onChange(function()
						if ref.instance == nil then
							if ENABLE_EXPERIMENTAL_GC_MODE then
								if conn.Connected then
									warn("ref is nil and instance is around!!!")
								else
									print("ref is nil, but instance was destroyed")
								end
							end
							return
						end
						Scheduler.enqueueProperty(ref.instance, "Parent", parent:get(false))
					end)
				)

			else
				-- constant parent assignment
				local assignOK = pcall(function()
					ref.instance.Parent = parent
				end)

				if not assignOK then
					logError("cannotAssignProperty", nil, className, "Parent")
				end
			end
		end

		--[[
			STEP 5: Connect event handlers
		]]
		for event, callback in pairs(toConnect) do
			table.insert(cleanupTasks, event:Connect(callback))
		end

		--[[
			STEP 6: Register cleanup tasks if needed
		]]
		if cleanupTasks[1] ~= nil then
			if ENABLE_EXPERIMENTAL_GC_MODE then
				-- TODO: enabling this code sometimes leads to unexpected nil references appearing
				-- it remains to be determined whether this is a bug with the instance being gc'd
				-- too early, or whether this is a by-product of cleanupOnDestroy() taking some time
				-- before detecting gc'd instances.

				-- when the instance changes ancestor, check if it's still in the
				-- data model - if not, we switch to a weak reference to allow for
				-- gc to occur, otherwise hold the reference strongly
				local function updateRefStrength()
					if game:IsAncestorOf(ref.instance) then
						setmetatable(ref, {})
					else
						setmetatable(ref, {__mode = "v"})
					end
				end

				task.defer(updateRefStrength)
				table.insert(cleanupTasks, ref.instance.AncestryChanged:Connect(updateRefStrength))
			end

			cleanupOnDestroy(ref.instance, cleanupTasks)
		end

		return ref.instance
	end
end

return New