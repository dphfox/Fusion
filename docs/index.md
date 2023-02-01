---
  template: home.html
  hide:
    - toc
    - navigation
---

<div id="fusiondoc-home" markdown>
<section id="fusiondoc-home-main">
<section id="fusiondoc-home-main-inner">
<h1>Rediscover the joy of UI.</h1>
<p>
Fusion is a UI, state management and animation library for Roblox. With Fusion,
you define declaratively what you want to see, rather than the steps the
computer should take to get there.
</p>
<p>
Starting from simple roots, concepts neatly combine and build up, so there’s
very little learning curve. At every stage, you can robustly guarantee what your
code will do - and when you come back in six months, Fusion code is designed to
be easy to pick back up.
</p>
<nav>
<a href="./tutorials">Get started</a>
<a href="https://github.com/Elttob/Fusion/releases">Download Fusion</a>
</nav>
</section>
</section>

<aside id="fusiondoc-home-scroll">
Scroll down for a quick look at 3 main features.
</aside>

<section id="fusiondoc-home-belowfold" markdown>

![Illustration of state objects](assets/home/State-Light.svg#only-light)
![Illustration of state objects](assets/home/State-Dark.svg#only-dark)

<h2 class="first">Representing change</h2>

Fusion introduces ‘state objects’. They aren’t that complex, but allow you
to write dynamic code that’s highly readable, behaves predictably and splits
into parts easily.

-----

State objects are used to represent changeable or dynamic values in your
program. You can peek at their value at any time.

```Lua
-- For example, suppose this function returned a state object.
local currentTimeObj = getCurrentTimeStateObject()

-- State objects are objects...
print(typeof(currentTimeObj)) --> table

-- ...and you can peek at their value (or ‘state’) at any time.
print(currentTimeObj:get()) --> 0.0
task.wait(5)
print(currentTimeObj:get()) --> 5.0
```

You can write out your logic using Fusion's built-in state objects.
Here's the two basic ones, Value and Computed:

```Lua
-- This creates a state object that you can set manually.
-- You can change its value using myName:set().
local myName = Value("Daniel")

-- This creates a state object from a calculation.
-- It determines its own value automatically.
local myGreeting = Computed(function()
	return "Hello! My name is " .. myName:get()
end)
```

To watch what a state object does, you can use an Observer.
For example, you can run some code when an object changes value.

```Lua
-- This observer watches for when the greeting changes.
local myObserver = Observer(myGreeting)

-- Let’s print out the greeting when there’s a new one.
local disconnect = myObserver:onChange(function()
	print(myGreeting:get())
end)

-- This will run the code above!
myName:set("Danny")
```

-----

![Illustration of creating instances](assets/home/Instances-Light.svg#only-light)
![Illustration of creating instances](assets/home/Instances-Dark.svg#only-dark)

<h2 class="second">Building instances</h2>

Fusion offers comprehensive APIs to build or enrich instances from code, so
you can easily integrate with your game scripts.

-----

Fusion provides dedicated functions to create and modify instances. They allow
you to easily configure your instance in one place.

```Lua
-- This will create a red part in the workspace.
local myPart = New "Part" {
	Parent = workspace,
	BrickColor = BrickColor.Red()
}

-- This adds on some extras after.
Hydrate(myPart) {
	Material = "Wood",
	Transparency = 0.5
}
```

They offer powerful features to keep all your instance code close together. For
example, you can listen for events or add children.

```Lua
-- This will create a rounded button.
-- When you click it, it’ll greet you.
local myButton = New "TextButton" {
	Text = "Click me",
	[OnEvent "Activated"] = function()
		print("Hello! I’m a button.")
	end,
	[Children] = New "UICorner" {
		CornerRadius = UDim.new(1, 0)
	}
}
```

You can also plug state objects in directly. The instance updates as the state
object changes value.

```Lua
-- Creating a state object you can control...
local message = Value("Hello!")

-- Now you can plug that state object into the Text property.
local myLabel = New "TextLabel" {
	Text = message
}
print(myLabel.Text) --> Hello!

-- The Text property now responds to changes:
message:set("Goodbye!")
print(myLabel.Text) --> Goodbye!
```

-----

![Illustration of processing animation](assets/home/Animation-Light.svg#only-light)
![Illustration of processing animation](assets/home/Animation-Dark.svg#only-dark)

<h2 class="third">Animating anything</h2>

Fusion gives you best-in-class tools to animate anything you can think of,
completely out of the box.

-----

Fusion lets you use tweens or physically based springs to animate any value you
want - not just instance properties.

```Lua
-- This could be anything you want, as long as it's a state object.
local health = Value(100)

-- Easily make it tween between values...
local style = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
local tweenHealth = Tween(health, style)

-- ...or use spring physics for extra responsiveness.
local springHealth = Spring(health, 30, 0.9)
```

Tween and Spring are state objects, just like anything else that changes in
your program. That means it's easy to process them afterwards.

```Lua
-- You can round the animated health to whole numbers.
local wholeHealth = Computed(function()
	return math.round(health:get())
end)

-- You can format it as text and put it in some UI, too.
local myText = New "TextLabel" {
	Text = Computed(function()
		return "Health: " .. wholeHealth:get()
	end)
}
```

You can even configure your animations using state objects, too. This makes it
easy to swap out animations or disable them when needed.

```Lua
-- Define some tweening styles...
local TWEEN_FAST = TweenInfo.new(0.5, Enum.EasingStyle.Elastic)
local TWEEN_SLOW = TweenInfo.new(2, Enum.EasingStyle.Sine)

-- Choose more dramatic styles at low health...
local style = Computed(function()
	return if health:get() < 20 then TWEEN_FAST else TWEEN_SLOW
end)

-- Plug it right into your animation!
local tweenHealth = Tween(health, style)
```

-----

## Sparked your curiosity?

Those are the core features of Fusion, and they're the foundation of everything
- whether it’s complex 3D UI systems, procedural animation, or just a hello
world app. It all fits on one page, and that's the magic. You don't have to keep
relearning ever-more-complex tools as you scale up from prototype to product.

If you'd like to learn in depth, <a href="./tutorials">we have a comprehensive
beginner's tutorial track</a>, complete with diagrams, examples and code.

We would love to welcome you into our warm, vibrant community. Hopefully, we'll
see you there :)

</section>
</div>