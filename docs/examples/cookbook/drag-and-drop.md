```Lua linenums="1"
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
-- [Fusion imports omitted for clarity]

-- This example shows a full drag-and-drop implementation for mouse input only.
-- Extending this system to generically work with other input types, such as
-- touch gestures or gamepads, is left as an exercise to the reader. However, it
-- should robustly support dragging many types of UI around flexibly.

-- To ensure best accessibility, any interactions you implement shouldn't force
-- the player to hold the mouse button down. Either allow drag-and-drop using
-- single inputs, or provide a non-dragging alternative; this will ensure that
-- players with reduced motor ability aren't locked out of UI functions.

-- We're going to need to account for the UI inset sometimes. We cache it here.
local TOP_LEFT_INSET = GuiService:GetGuiInset()

-- To reflect the current position of the cursor on-screen, we'll use a state
-- object that's updated using UserInputService.
local mousePos = Value(UserInputService:GetMouseLocation() - TOP_LEFT_INSET)
local mousePosConn = UserInputService.InputChanged:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		mousePos:set(Vector2.new(inputObject.Position.X, inputObject.Position.Y))
	end
end)

-- We need to keep drag of which item is currently being dragged. Only one item
-- can be dragged at a time. This type stores all the information needed:
export type CurrentlyDragging = {
	-- Each draggable item will have a unique ID; the ID stored here represents
	-- which item is being dragged right now. We'll use strings for this, but
	-- you could use numbers if that's more convenient for you.
	id: string,
	-- When a drag is started, we store the mouse's offset relative to the item
	-- being dragged. When the mouse moves, we can then apply the same offset to
	-- make it look like the item is 'pinned' to the cursor.
	offset: Vector2
}
-- This state object stores the above during a drag, or `nil` when not dragging.
local currentlyDragging = Value(nil :: CurrentlyDragging?)

-- Now we need a component to encapsulate all of our dragging behaviour, such
-- as moving our UI between different parents, placing it at the mouse cursor,
-- managing sizing, and so on.

export type DraggableProps = {
	-- This should uniquely identify the draggable item apart from all other
	-- draggable items. This is constant and so shouldn't be a state object.
	ID: string,
	-- It doesn't make sense for a draggable item to have a constant parent. You
	-- wouldn't be able to drop it anywhere else, so we enforce that Parent is a
	-- state object for our own convenience.
	Parent: StateObject<Instance?>,
	-- When an item is being dragged, it needs to appear above all other UI. We
	-- will create an overlay frame that fills the screen to achieve this.
	OverlayFrame: Instance,
	-- To start a drag, we'll need to know where the top-left corner of the item
	-- is, so we can calculate `currentlyDragging.offset`. We'll allow the
	-- calling code to pass through a Value object to [Out "AbsolutePosition"].
	OutAbsolutePosition: Value<Vector2?>?,

	Name: CanBeState<string>?,
	LayoutOrder: CanBeState<number>?,
	Position: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,
	Size: CanBeState<UDim2>?,
	AutomaticSize: CanBeState<Enum.AutomaticSize>?,
	ZIndex: CanBeState<number>?,
	[Children]: Child
}

local function Draggable(props: DraggableProps): Child
	-- If we need something to be cleaned up when our item is destroyed, we can
	-- add it to this array. It'll be passed to `[Cleanup]` later.
	local cleanupTasks = {}

	-- This acts like `currentlyDragging`, but filters out anything without a
	-- matching ID, so it'll only exist when this specific item is dragged.
	local thisDragging = Computed(function()
		local dragInfo = currentlyDragging:get()
		return if dragInfo ~= nil and dragInfo.id == props.ID then dragInfo else nil
	end)

	-- Our item controls its own parent - one of the few times you'll see this
	-- done in Fusion. This means we don't have to destroy and re-build the item
	-- when it moves to a new location.
	local itemParent = Computed(function()
		return if thisDragging:get() ~= nil then props.OverlayFrame else props.Parent:get()
	end, Fusion.doNothing)

	-- If we move a scaled UI into the `overlayBox`, by default it will stretch
	-- to the screen size. Ideally we want it to preserve its current size while
	-- it's being dragged, so we need to track the parent's size and calculate
	-- the item size ourselves.

	-- To start with, we'll store the parent's absolute size. This takes a bit
	-- of legwork to get right, and we need to remember the UI might not have a
	-- parent which we can measure the size of - we'll represent that as `nil`.
	-- Feel free to extract this into a separate function if you want to.
	local parentSize = Value(nil)
	do
		-- We'll call this whenever the parent's AbsoluteSize changes, or when
		-- the parent changes (because different parents might have different
		-- absolute sizes, if any)
		local function recalculateParentSize()
			-- We're not in a Computed, so we want to pass `false` to `:get()`
			-- to avoid adding dependencies.
			local parent = props.Parent:get(false)
			local parentHasSize = parent ~= nil and parent:IsA("GuiObject")
			parentSize:set(if parentHasSize then parent.AbsoluteSize else nil)
		end

		-- We don't just need to connect to the AbsoluteSize changed event of
		-- the parent we have *right now*! If the parent changes, we need to
		-- disconnect the old event and re-connect on the new parent, which we
		-- do here.
		local parentSizeConn = nil
		local function rebindToParentSize()
			if parentSizeConn ~= nil then
				parentSizeConn:Disconnect()
				parentSizeConn = nil
			end
			local parent = props.Parent:get(false)
			local parentHasSize = parent ~= nil and parent:IsA("GuiObject")
			if parentHasSize then
				parentSizeConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalculateParentSize)
			end
			recalculateParentSize()
		end
		rebindToParentSize()
		local disconnect = Observer(props.Parent):onChange(rebindToParentSize)

		-- When the item gets destroyed, we need to disconnect that observer and
		-- our AbsoluteSize change event (if any is active right now)
		table.insert(cleanupTasks, function()
			disconnect()
			if parentSizeConn ~= nil then
				parentSizeConn:Disconnect()
				parentSizeConn = nil
			end
		end)
	end

	-- Now that we have a reliable parent size, we can calculate the item's size
	-- without worrying about all of those event connections.
	if props.Size == nil then
		props.Size = Value(UDim2.fromOffset(0, 0))
	elseif typeof(props.Size) == "UDim2" then
		props.Size = Value(props.Size)
	end
	local itemSize = Computed(function()
		local udim2 = props.Size:get()
		local scaleSize = parentSize:get() or Vector2.zero -- might be nil!
		return UDim2.fromOffset(
			udim2.X.Scale * scaleSize.X + udim2.X.Offset,
			udim2.Y.Scale * scaleSize.Y + udim2.Y.Offset
		)
	end)

	-- Similarly, we'll need to override the item's position while it's being
	-- dragged. Happily, this is simpler to do :)
	if props.Position == nil then
		props.Position = Value(UDim2.fromOffset(0, 0))
	elseif typeof(props.Position) == "UDim2" then
		props.Position = Value(props.Position)
	end
	local itemPosition = Computed(function()
		local dragInfo = thisDragging:get()
		if dragInfo == nil then
			return props.Position:get()
		else
			-- `dragInfo.offset` stores the distance from the top-left corner
			-- of the item to the mouse position. Subtracting the offset from
			-- the mouse position therefore gives us the item's position.
			local position = mousePos:get() - dragInfo.offset
			return UDim2.fromOffset(position.X, position.Y)
		end
	end)

	return New "Frame" {
		Name = props.Name or "Draggable",
		LayoutOrder = props.LayoutOrder,
		AnchorPoint = props.AnchorPoint,
		AutomaticSize = props.AutomaticSize,
		ZIndex = props.ZIndex,

		Parent = itemParent,
		Position = itemPosition,
		Size = itemSize,

		BackgroundTransparency = 1,

		[Out "AbsolutePosition"] = props.OutAbsolutePosition,

		[Children] = props[Children]
	}
end

-- The hard part is over! Now we just need to create some draggable items and
-- start/stop drags in response to mouse events. We'll use a very basic example.

-- Let's make some to-do items. They'll show up in two lists - one for
-- incomplete tasks, and another for complete tasks. You'll be able to drag
-- items between the lists to mark them as complete. The lists will be sorted
-- alphabetically so we don't have to deal with calculating where the items
-- should be placed when they're dropped.

export type TodoItem = {
	id: string,
	text: string,
	completed: Value<boolean>
}
local todoItems: Value<TodoItem> = {
	{
		-- You can use HttpService to easily generate unique IDs statelessly.
		id = HttpService:GenerateGUID(),
		text = "Wake up today",
		completed = Value(true)
	},
	{
		id = HttpService:GenerateGUID(),
		text = "Read the Fusion docs",
		completed = Value(true)
	},
	{
		id = HttpService:GenerateGUID(),
		text = "Take over the universe",
		completed = Value(false)
	}
}
local function getTodoItemForID(id: string): TodoItem?
	for _, item in todoItems do
		if item.id == id then
			return item
		end
	end
	return nil
end

-- These represent the individual draggable to-do item entries in the lists.
-- This is where we'll use our `Draggable` component!
export type TodoEntryProps = {
	Item: TodoItem,
	Parent: StateObject<Instance?>,
	OverlayFrame: Instance,
}
local function TodoEntry(props: TodoEntryProps): Child
	local absolutePosition = Value(nil)

	-- Using our item's ID, we can figure out if we're being dragged to apply
	-- some styling for dragged items only!
	local isDragging = Computed(function()
		local dragInfo = currentlyDragging:get()
		return dragInfo ~= nil and dragInfo.id == props.Item.id
	end)

	return Draggable {
		ID = props.Item.id,
		Parent = props.Parent,
		OverlayFrame = props.OverlayFrame,
		OutAbsolutePosition = absolutePosition,

		Name = props.Item.text,
		Size = UDim2.new(1, 0, 0, 50),

		[Children] = New "TextButton" {
			Name = "TodoEntry",

			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Computed(function()
				if isDragging:get() then
					return Color3.new(1, 1, 1)
				elseif props.Item.completed:get() then
					return Color3.new(0, 1, 0)
				else
					return Color3.new(1, 0, 0)
				end
			end),
			Text = props.Item.text,
			TextSize = 28,

			-- This is where we'll detect mouse down. When the mouse is pressed
			-- over this item, we should pick it up.
			[OnEvent "MouseButton1Down"] = function()
				-- only start a drag if we're not already dragging
				if currentlyDragging:get(false) == nil then
					local itemPos = absolutePosition:get(false) or Vector2.zero
					local offset = mousePos:get(false) - itemPos
					currentlyDragging:set({
						id = props.Item.id,
						offset = offset
					})
				end
			end

			-- We're not going to detect mouse up here, because in some rare
			-- cases the event could be dropped due to lag between the item's
			-- position and the cursor position. We'll deal with this at a
			-- global level instead.
		}
	}
end

-- Now we should construct our two task lists for housing our to-do entries.
-- Notice that they don't manage the entries themselves! The entries don't
-- belong to these lists after all, so that'd be nonsense :)

-- When we release our mouse, we need to know where to drop any dragged item we
-- have. This will tell us if we're hovering over either list.
local dropAction = Value(nil)

local incompleteList = New "ScrollingFrame" {
	Name = "IncompleteTasks",
	Position = UDim2.fromScale(0.1, 0.1),
	Size = UDim2.fromScale(0.35, 0.9),

	BackgroundTransparency = 0.75,
	BackgroundColor3 = Color3.new(1, 0, 0),

	[OnEvent "MouseEnter"] = function()
		dropAction:set("incomplete")
	end,

	[OnEvent "MouseLeave"] = function()
		if dropAction:get(false) == "incomplete" then
			dropAction:set(nil) -- only clear this if it's not overwritten yet
		end
	end,

	[Children] = {
		New "UIListLayout" {
			SortOrder = "Name",
			Padding = UDim.new(0, 5)
		}
	}
}

local completedList = New "ScrollingFrame" {
	Name = "CompletedTasks",
	Position = UDim2.fromScale(0.55, 0.1),
	Size = UDim2.fromScale(0.35, 0.9),

	BackgroundTransparency = 0.75,
	BackgroundColor3 = Color3.new(0, 1, 0),

	[OnEvent "MouseEnter"] = function()
		dropAction:set("completed")
	end,

	[OnEvent "MouseLeave"] = function()
		if dropAction:get(false) == "completed" then
			dropAction:set(nil) -- only clear this if it's not overwritten yet
		end
	end,

	[Children] = {
		New "UIListLayout" {
			SortOrder = "Name",
			Padding = UDim.new(0, 5)
		}
	}
}

-- Now we can write a mouse up handler to drop our items.

local mouseUpConn = UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	local dragInfo = currentlyDragging:get(false)
	if dragInfo == nil then
		return
	end
	local item = getTodoItemForID(dragInfo.id)
	local action = dropAction:get(false)
	if item ~= nil then
		if action == "incomplete" then
			item.completed:set(false)
		elseif action == "completed" then
			item.completed:set(true)
		end
	end
	currentlyDragging:set(nil)
end)

-- We'll need to construct an overlay frame for our items to live in while they
-- get dragged around.

local overlayFrame = New "Frame" {
	Size = UDim2.fromScale(1, 1),
	ZIndex = 10,
	BackgroundTransparency = 1
}

-- Let's construct the items themselves! Because we're constructing them at the
-- global level like this, they're only created and destroyed when they're added
-- and removed from the list.

local allEntries = ForValues(todoItems, function(item)
	return TodoEntry {
		Item = item,
		Parent = Computed(function()
			return if item.completed:get() then completedList else incompleteList
		end, Fusion.doNothing),
		OverlayFrame = overlayFrame
	}
end, Fusion.cleanup)

-- Finally, construct the whole UI :)

local ui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	[Cleanup] = {
		mousePosConn,
		mouseUpConn
	},

	[Children] = {
		overlayFrame,
		incompleteList,
		completedList

		-- We don't have to pass `allEntries` in here - they manage their own
		-- parenting thanks to `Draggable` :)
	}
}
```