This example shows a full drag-and-drop implementation for mouse input only,
using Fusion's Roblox API.

To ensure best accessibility, any interactions you implement shouldn't force you
to hold the mouse button down. Either allow drag-and-drop with single clicks, or
provide a non-dragging alternative. This ensures people with reduced motor
ability aren't locked out of UI functions.

```Lua linenums="1"
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Fusion = -- initialise Fusion here however you please!
local scoped = Fusion.scoped
local Children, OnEvent = Fusion.Children, Fusion.OnEvent

type DragInfo = {
	id: string,
	mouseOffset: Vector2 -- relative to the dragged item
}

local function Draggable(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		ID: string,
		Name: Fusion.CanBeState<string>?,
		Parent: Fusion.StateObject<Instance?>, -- StateObject so it's observable
		Layout: {
			LayoutOrder: Fusion.CanBeState<number>?,
			Position: Fusion.CanBeState<UDim2>?,
			AnchorPoint: Fusion.CanBeState<Vector2>?,
			ZIndex: Fusion.CanBeState<number>?,
			Size: Fusion.CanBeState<UDim2>?,
			OutAbsolutePosition: Fusion.Value<Vector2>?,
		},
		Dragging: {
			SelfDragInfo: Fusion.CanBeState<DragInfo?>,
			OverlayFrame: Fusion.CanBeState<Instance?>
		}
		[typeof(Children)]: Fusion.Child
	}
): Fusion.Child
	-- When `nil`, the parent can't be measured for some reason.
	local parentSize = scope:Value(nil)
	do
		local function measureParentNow()
			local parent = peek(props.Parent)
			parentSize:set(
				if parent ~= nil and parent:IsA("GuiObject")
				then parent.AbsoluteSize
				else nil
			)
		end
		local resizeConn = nil
		local function stopMeasuring()
			if resizeConn ~= nil then
				resizeConn:Disconnect()
				resizeConn = nil
			end
		end
		scope:Observer(props.Parent):onBind(function()
			stopMeasuring()
			measureParentNow()
			if peek(parentSize) ~= nil then
				resizeConn = parent:GetPropertyChangedSignal("AbsoluteSize")
					:Connect(measureParentNow)
			end
		end)
		table.insert(scope, stopMeasuring)
	end

	return New "Frame" {
		Name = props.Name or "Draggable",
		Parent = scope:Computed(function(use)
			return
				if use(props.Dragging.SelfDragInfo) ~= nil
				then use(props.Dragging.OverlayFrame)
				else use(props.Parent)
		end),
		
		LayoutOrder = props.Layout.LayoutOrder,
		AnchorPoint = props.Layout.AnchorPoint,
		ZIndex = props.Layout.ZIndex,
		AutomaticSize = props.Layout.AutomaticSize,

		BackgroundTransparency = 1,

		Position = Computed(function(use)
			local dragInfo = use(props.Dragging.SelfDragInfo)
			if dragInfo == nil then
				return use(props.Layout.Position) or UDim2.fromOffset(0, 0)
			else
				local topLeftCorner = use(mousePos) - dragInfo.mouseOffset
				return UDim2.fromOffset(topLeftCorner.X, topLeftCorner.Y)
			end
		end),
		-- Calculated manually so the Scale can be set relative to
		-- `props.Parent` at all times, rather than the `Parent` of this Frame.
		Size = scope:Computed(function(use)
			local udim2 = use(props.Layout.Size) or UDim2.fromOffset(0, 0)
			local parentSize = use(parentSize) or Vector2.zero
			return UDim2.fromOffset(
				udim2.X.Scale * parentSize.X + udim2.X.Offset,
				udim2.Y.Scale * parentSize.Y + udim2.Y.Offset
			)
		end),

		[Out "AbsolutePosition"] = props.OutAbsolutePosition,
		[Children] = props[Children]
	}
end

local COLOUR_COMPLETED = Color3.new(0, 1, 0)
local COLOUR_NOT_COMPLETED = Color3.new(1, 1, 1)

local TODO_ITEM_SIZE = UDim2.new(1, 0, 0, 50)

local function newUniqueID()
	-- You can replace this with a better method for generating unique IDs.
	return game:GetService("HttpService"):GenerateGUID()
end

type TodoItem = {
	id: string,
	text: string,
	completed: Fusion.Value<boolean>
}
local todoItems: Fusion.Value<TodoItem> = {
	{
		id = newUniqueID(),
		text = "Wake up today",
		completed = Value(true)
	},
	{
		id = newUniqueID(),
		text = "Read the Fusion docs",
		completed = Value(true)
	},
	{
		id = newUniqueID(),
		text = "Take over the universe",
		completed = Value(false)
	}
}
local function getTodoItemForID(
	id: string
): TodoItem?
	for _, item in todoItems do
		if item.id == id then
			return item
		end
	end
	return nil
end

local function TodoEntry(
	outerScope: Fusion.Scope<{}>,
	props: {
		Item: TodoItem,
		Parent: Fusion.StateObject<Instance?>,
		Layout: {
			LayoutOrder: Fusion.CanBeState<number>?,
			Position: Fusion.CanBeState<UDim2>?,
			AnchorPoint: Fusion.CanBeState<Vector2>?,
			ZIndex: Fusion.CanBeState<number>?,
			Size: Fusion.CanBeState<UDim2>?,
			OutAbsolutePosition: Fusion.Value<Vector2>?,
		},
		Dragging: {
			SelfDragInfo: Fusion.CanBeState<CurrentlyDragging?>,
			OverlayFrame: Fusion.CanBeState<Instance>?
		},
		OnMouseDown: () -> ()?
	}
): Child
	local scope = scoped(Fusion, {
		Draggable = Draggable
	})
	table.insert(outerScope, scope)

	local itemPosition = scope:Value(nil)
	local itemIsDragging = scope:Computed(function(use)
		local dragInfo = use(props.CurrentlyDragging)
		return dragInfo ~= nil and dragInfo.id == props.Item.id
	end)

	return scope:Draggable {
		ID = props.Item.id,
		Name = props.Item.text,
		Parent = props.Parent,
		Layout = props.Layout,
		Dragging = props.Dragging,

		[Children] = scope:New "TextButton" {
			Name = "TodoEntry",

			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = scope:Computed(function(use)
				return
					if use(props.Item.completed)
					then COLOUR_COMPLETED
					else COLOUR_NOT_COMPLETED
				end
			end),
			Text = props.Item.text,
			TextSize = 28,
	
			[OnEvent "MouseButton1Down"] = props.OnMouseDown

			-- Don't detect mouse up here, because in some rare cases, the event
			-- could be missed due to lag between the item's position and the
			-- cursor position.
		}
	}
end

-- Don't forget to pass this to `doCleanup` if you disable the script.
local scope = scoped(Fusion)

local currentlyDragging: Fusion.Value<CurrentlyDragging?> = scope:Value(nil)
local mousePos = scope:Value(UserInputService:GetMouseLocation())
table.insert(scope, 
	UserInputService.InputChanged:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			-- If this code did not read coordinates from the same method, it
			-- might inconsistently handle UI insets. So, keep it simple!
			mousePos:set(UserInputService:GetMouseLocation())
		end
	end)
)
local dropAction = scope:Value(nil)

local taskLists = scope:ForPairs(
	{
		incomplete = "mark-as-incomplete",
		completed = "mark-as-completed"	
	},
	function(use, scope, listName, listDropAction)
		return 
			listName, 
			scope:New "ScrollingFrame" {
				Name = `TaskList ({listName})`,
				Position = UDim2.fromScale(0.1, 0.1),
				Size = UDim2.fromScale(0.35, 0.9),

				BackgroundTransparency = 0.75,
				BackgroundColor3 = Color3.new(1, 0, 0),

				[OnEvent "MouseEnter"] = function()
					dropAction:set(listDropAction)
				end,

				[OnEvent "MouseLeave"] = function()
					-- A different item might have overwritten this already.
					if peek(dropAction) == listDropAction then
						dropAction:set(nil)
					end
				end,

				[Children] = {
					New "UIListLayout" {
						SortOrder = "Name",
						Padding = UDim.new(0, 5)
					}
				}
			}
	end
)

local overlayFrame = scope:New "Frame" {
	Size = UDim2.fromScale(1, 1),
	ZIndex = 10,
	BackgroundTransparency = 1
}

local allEntries = scope:ForValues(
	todoItems, 
	function(use, scope, item)
		local itemPosition = scope:Value(nil)
		return scope:TodoEntry {
			Item = item,
			Parent = Computed(function(use)
				return
					if use(item.completed)
					then use(taskLists).completed
					else use(taskLists).incomplete
			end),
			Layout = {
				Size = TODO_ITEM_SIZE,
				OutAbsolutePosition = itemPosition
			},
			Dragging = {
				SelfDragInfo = scope:Computed(function(use)
					local dragInfo = use(currentlyDragging)
					return 
						if dragInfo == nil or dragInfo.id ~= item.id
						then nil
						else dragInfo
				end)
				OverlayFrame = overlayFrame
			},
			OnMouseDown = function()
				if peek(currentlyDragging) == nil then
					local itemPos = peek(itemPosition) or Vector2.zero
					local mouseOffset = peek(mousePos) - itemPos
					currentlyDragging:set({
						id = item.id,
						mouseOffset = mouseOffset
					})
				end
			end
		}
	end
)

table.insert(scope,
	UserInputService.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local dragInfo = peek(currentlyDragging)
		if dragInfo == nil then
			return
		end
		local item = getTodoItemForID(dragInfo.id)
		local action = peek(dropAction)
		if item ~= nil then
			if action == "mark-as-incomplete" then
				item.completed:set(false)
			elseif action == "mark-as-completed" then
				item.completed:set(true)
			end
		end
		currentlyDragging:set(nil)
	end)
)

local ui = scope:New "ScreenGui" {
	Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	[Children] = {
		overlayFrame,
		taskLists,
		-- Don't pass `allEntries` in here - they manage their own parent!
	}
}
```