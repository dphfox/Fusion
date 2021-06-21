Welcome to the Fusion tutorial section! Here, you'll learn how to build great
interfaces with Fusion, even if you're a complete newcomer to the library.

-----

## What You Need To Know

These tutorials assume:

- You're comfortable with Roblox and the Luau scripting language.
	- These tutorials aren't an introduction to scripting! If you'd like to
	  learn, check out the [Roblox DevHub](https://developer.roblox.com/).
- You're familiar with how UI works on Roblox.
    - You don't have to be a designer - knowing about UI instances, events
	and data types like `UDim2` and `Color3` will be good enough.

Of course, based on your existing knowledge, you may find some tutorials easier
or harder. Fusion's built to be easy to learn, but it may still take a bit of
time to absorb some concepts, so don't be discouraged 🙂

-----

## How These Tutorials Work

You can find the tutorials in the navigation bar to your left. Tutorials are
grouped together by category, and are designed to explore specific features of
Fusion.

You can either do them in order (recommended for newcomers), or you can
jump to a specific tutorial for a quick refresh.

You'll also see 'projects' at regular intervals, which combine concepts from
earlier tutorials and show how they interact and work together in a real setting.

-----

At the beginning of every tutorial, you'll see a section titled 'Required code'.
They look like this - you can click to expand them:

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	print("This is an example!")
	```

Before starting each tutorial, make sure to copy the code into your script
editor, so you can follow along properly.

-----

Similarly, you'll find the finished code for the tutorial at the end, under
'Finished code':

??? abstract "Finished code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	print("This is an example!")
	print("Pretend we added some code during the tutorial here...")
	```

You can use the finished code as a reference if you get stuck - it'll contain
the script as it appears after following all the steps of the tutorial.

-----

## Installing Fusion

!!! fail "Unreleased"
	Fusion is not yet released - check back here later!

<!--
Fusion is distributed as a single `ModuleScript`. Before starting, you'll need
to add this module script to your game. Here's how:

### Fusion for Roblox Studio

If you script in Roblox Studio, here's how to install Fusion:

!!! example "Steps"
	1. Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
	There, you can find the latest version of Fusion.
	2. Under 'Assets', click the `.rbxm` file to download it. This contains the
	Fusion module script.
	3. In Roblox Studio, open or create a place.
	4. Right-click on ReplicatedStorage, and select 'Insert from File'.
	5. Find the `.rbxm` you just downloaded, and select it.

	You should now see a ModuleScript called 'Fusion' sitting in ReplicatedStorage -
	you're ready to go!

### Fusion for External Editors

If you use an external editor to write scripts, and synchronise them into Roblox
using a plugin, here's how to install Fusion:

??? example "Steps (click to expand)"
	1. Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
	There, you can find the latest version of Fusion.
	2. Under 'Assets', click the `.zip` file to download it. Inside is a copy
	of the Fusion GitHub repository.
	3. Inside the zip, copy the `src` folder - it may be in a nested folder.
	4. Paste `src` into your local project, preferably in your `shared` folder
	if you have one.
	5. Rename the folder from `src` to `Fusion`.

	Once everything is set up, you should see Fusion appear in Studio when you
	next synchronise your project.
	-->

-----

## Setting Up A Test Script

Now that you've installed Fusion, you can set up a local script for testing.
Here's how:

1. Create a `LocalScript` in a service like `StarterGui` or `StarterPlayerScripts`.
2. Remove the default code, and paste the following code in:

```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
```

!!! note
	This code assumes you've installed Fusion into ReplicatedStorage.
	If you've installed Fusion elsewhere, you'll need to tweak the `require()`
	to point to the correct location.

If everything was set up correctly, you can press 'Play' and everything should
run without any errors.

??? fail "My script doesn't work - common errors"
	```
	Fusion is not a valid member of ReplicatedStorage "ReplicatedStorage"
	```

	If you're seeing this error, then your script can't find Fusion. Refer back
	to [the previous section](#installing-fusion) and double-check you've set
	everything up properly.

	If you're using the installation guide from above, your `ReplicatedStorage`
	should look like this:

	![Explorer screenshot](index/ReplicatedStorage-Fusion.png)

