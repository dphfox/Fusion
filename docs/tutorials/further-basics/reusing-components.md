It's often a good idea to split our UI into reusable parts, known as
'components'. Let's learn how you can create these with Fusion.

-----

## Components Are Just Functions

When we want to reuse a bit of code, we often put it in a function. We can give
it different parameters to modify what the function does. This makes them useful
for creating reusable pieces of UI, often known as 'components'.

You might have seen something like this before when developing Roblox UIs:

```Lua
-- this functions takes in a table of properties (props), and returns some UI
local function Greeting(props)
	local greeting = Instance.new("TextLabel")
	-- every greeting will have these properties
	greeting.BackgroundColor3 = Color3.new(1, 1, 0)
	greeting.TextColor3 = Color3.new(0, 0, 1)
	greeting.Size = UDim2.fromOffset(200, 50)
	-- different greetings can have different messages though!
	greeting.Text = props.message

	return greeting
end
```

This is a relatively intuitive way to make components normally, since it hides
away all the common properties we don't care about (e.g. colours), and exposes
only the properties that we want to modify (e.g. the message).

Because Fusion is designed around instances, we can borrow this code pattern.
The function below returns a TextLabel instance just like we do above:

```Lua
local function Greeting(props)
	return New "TextLabel" {
		BackgroundColor3 = Color3.new(1, 1, 0),
		TextColor3 = Color3.new(0, 0, 1),
		Size = UDim2.fromOffset(200, 50),
		Text = props.message
	}
end
```

Furthermore, since `#!Lua [Children]` works with instances, it's very easy to
add a `Greeting` as a child:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "Frame" {
			-- some other UI...
		},

		Greeting {
			message = "Hello, world!"
		}
	}
}
```

!!! note
	Because our function accepts just one table as an argument (`props`), we
	don't need parentheses `()` when we call the function with a new table!

In the above code;

- we call `Greeting` with a table of properties, containing our message
- the `Greeting` function creates and returns our TextLabel for us
- the returned TextLabel becomes part of the `[Children]`

Therefore, when we run this code, we'll see our greeting TextLabel show up in
our ScreenGui.

That's the basic idea of 'components' in Fusion; they're just functions which
take in some properties and return some UI. For the rest of this tutorial, we'll
take a look at some code patterns that you can use with components in Fusion.

-----

## State In Components

Because components are functions, we can do more than just creating instances.
You can also store state inside them!

Let's make a 'toggle button' component to demonstrate this. When we click it,
it should toggle on and off.

Here's some basic code to get started - we just need to add some state to this:

```Lua
local function ToggleButton(props)
	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromOffset(200, 50),
		Text = props.message,

		[OnEvent "Activated"] = function()
			-- TODO: toggle the button!
		end
	}
end
```

Firstly, let's create a state object to store whether the button is currently
toggled on or off:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			-- TODO: toggle the button!
		end
	}
end
```

Next, we can toggle the stored value in our event handler:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			isButtonOn:set(not isButtonOn:get())
		end
	}
end
```

Finally, we can make the background colour show whether the button is toggled on
or off, using some computed state:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Computed(function()
			if isButtonOn:get() then
				return Color3.new(0, 1, 0) -- green when toggled on
			else
				return Color3.new(1, 0, 0) -- red when toggled off
			end
		end),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			isButtonOn:set(not isButtonOn:get())
		end
	}
end
```

With just this code, we've made our toggle button fully functional! Again, this
is a regular Lua function, so nothing fancy is going on behind the scenes.

Just like before, we can now include our toggle button in our UI easily:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "UIListLayout" {
			Padding = UDim.new(0, 4)
		},

		ToggleButton {
			message = "Click me!"
		},

		ToggleButton {
			message = "Also, click me!"
		},

		ToggleButton {
			message = "Each button is independent :)"
		}
	}
}
```

Because we create a new button each time we call the function, each button keeps
it's own state and functions independently.

-----

## Passing in Children

Sometimes, we want to create components that can hold children. For example,
take a look at this component, which arranges some children into a scrolling
grid:

```Lua
local function Gallery(props)
	return New "ScrollingFrame" {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,

		[Children] = {
			New "UIGridLayout" {
				CellPadding = UDim2.fromOffset(4, 4),
				CellSize = UDim2.fromOffset(100, 100)
			},

			-- TODO: put some children here?
		}
	}
end
```

Suppose we'd like users to be able to pass in children to show up in the grid:

```Lua
Gallery {
	Position = UDim2.fromScale(.5, .5)
	Size = UDim2.fromOffset(400, 300),
	AnchorPoint = Vector2.new(.5, .5),

	[Children] = {
		New "ImageLabel" { ... },
		New "ImageLabel" { ... },
		New "ImageLabel" { ... }
	}
}
```

We can access those children in our function using `#!Lua props[Children]`. Since the
`New` function lets us pass in arrays of children, we can just include it
directly in our code like so:

```Lua
local function Gallery(props)
	return New "ScrollingFrame" {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,

		[Children] = {
			New "UIGridLayout" {
				CellPadding = UDim2.fromOffset(4, 4),
				CellSize = UDim2.fromOffset(100, 100)
			},

			props[Children]
		}
	}
end
```

That's all there is to it! Just keep in mind that `Children` is still a property
like any other, so if you're processing the children, it might be good to do
some type checking first.

-----

## Callbacks

For some components (e.g. buttons or text boxes), some code might need to run in
response to events like clicks or typing. You can use callbacks to achieve this.

Consider this `Button` component as an example. Notice we're using `props.OnClick`
with `#!Lua [OnEvent "Activated"]`:

```Lua
local function Button(props)
	return New "TextButton" {
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,

		BackgroundColor3 = Color3.new(0, 0.4, 1),
		TextColor3 = Color3.new(1, 1, 1),
		Text = props.Message,

		[OnEvent "Activated"] = props.OnClick
	}
end
```

This means that anyone using the `Button` component can provide a callback
function, which will then be run when the button is clicked:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		Button {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Message = "Click me!",

			OnClick = function()
				-- this callback function will be passed into OnEvent, so it'll
				-- run when the button is clicked
				print("The button was clicked!")
			end
		},
	}
}
```

This isn't just limited to event handlers, either - any time you want to let
the caller provide some code, callbacks are a great option.

-----

## Returning Many Children

In some specific circumstances, you may want to return more than one instance
from a component.

You shouldn't return multiple values from a component directly. Because of how
Lua works, this can introduce subtle bugs in your code:

```Lua
local function ManyThings(props)
	-- don't do this!
	-- you should only return one value from a component
	return
		New "TextLabel" {...},
		New "ImageButton" {...},
		New "Frame" {...}
end

local gui1 = New "ScreenGui" {
	-- this will only parent the TextLabel!
	[Children] = ManyThings {}
}

local gui2 = New "ScreenGui" {
	[Children] = {
		New "TextLabel" {...},

		-- this is also broken
		ManyThings {}

		New "TextLabel" {...}
	}
}
```

A better way to do this is to return an *array* of instances. This means you
only return a single value - the array.

This solves all of our issues; since `[Children]` supports arrays of children,
all our instances are now parented as expected:

```Lua
local function ManyThings(props)
	-- using an array ensures we only return one value
	return {
		New "TextLabel" {...},
		New "ImageButton" {...},
		New "Frame" {...}
	}
end

local gui1 = New "ScreenGui" {
	-- this now works!
	[Children] = ManyThings {}
}

local gui2 = New "ScreenGui" {
	[Children] = {
		New "TextLabel" {...},

		-- this also now works!
		ManyThings {},

		New "TextLabel" {...}
	}
}

```