Welcome to the Fusion tutorial section! Here, you'll learn how to build great
things with Fusion, even if you're a complete newcomer to the library.

You'll not only learn how Fusion's features work, but you'll also be presented
with wisdom from those who've worked with some of the largest Fusion codebases
today.

!!! caution "But first, something important..."
	**<span style="font-size: 1.5em; color: var(--fusiondoc-accent);">
	Do not use Fusion for real-world work unless you're 100,000% able to deal
	with a changing environment!
	</span>**

	Fusion is not version 1.0 yet! You *will* encounter:

	- updates that completely remove existing features
	- changes in behaviour between versions
	- changing advice on coding conventions and how to structure your project

	This is not a bad thing! Moving fast with Fusion at this early stage means
	we can quickly abandon counterproductive ideas and features, and discover
	much more solid foundations to build upon.

	Don't be discouraged from Fusion though! Once features have settled down,
	releases will be more stable.

-----

## What You Need To Know

These tutorials assume:

- That you're comfortable with the Luau scripting language.
	- These tutorials aren't an introduction to Luau! If you'd like to learn,
	check out the [Roblox documentation](https://create.roblox.com/docs).
- That - if you're using Roblox features - you're familiar with how Roblox works.
    - You don't have to be an expert! Knowing about basic instances, events
	and data types will be good enough.

Of course, based on your existing knowledge, you may find some tutorials easier
or harder. Fusion's built to be easy to learn, but it may still take a bit of
time to absorb some concepts, so don't be discouraged!

-----

## Install Fusion inside Roblox Studio

If you are creating Luau experiences in Roblox Studio, then you can use a
version of Fusion packaged up as a Roblox model. Before starting, you'll need
to add this model to your game.

Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
Click the 'Assets' dropdown to view the downloadable files:

![Picture of Fusion's GitHub Releases page, with the Assets dropdown highlighted.](index/Github-Releases-Guide-1-Light.png#only-light)
![Picture of Fusion's GitHub Releases page, with the Assets dropdown highlighted.](index/Github-Releases-Guide-1-Dark.png#only-dark)

Now, click on the `Fusion.rbxm` file to download it. This model contains Fusion.

![The Assets dropdown opened to reveal downloads, with Fusion.rbxm highlighted.](index/Github-Releases-Guide-2-Light.png#only-light)
![The Assets dropdown opened to reveal downloads, with Fusion.rbxm highlighted.](index/Github-Releases-Guide-2-Dark.png#only-dark)

Head into Roblox Studio to import the model; if you're just following the
tutorials, an empty baseplate will do.

Right-click on `ReplicatedStorage`, and select 'Insert from File':

![ReplicatedStorage is right-clicked, showing a context menu of items. Insert from File is highlighted.](index/Github-Releases-Guide-3-Light.png#only-light)
![ReplicatedStorage is right-clicked, showing a context menu of items. Insert from File is highlighted.](index/Github-Releases-Guide-3-Dark.png#only-dark)

Select the `Fusion.rbxm` file you just downloaded. You should see a 'Fusion'
module script appear in `ReplicatedStorage`!

### Setting Up A Test Script

Now that you've installed Fusion, you can set up a local script for testing.
Here's how:

1. Create a `LocalScript` in `StarterGui` or `StarterPlayerScripts`.
2. Remove the default code, and paste the following code in:
```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
```
3. Press 'Play' - if there are no errors, everything was set up correctly!

??? fail "My script didn't work! (click to expand)"
	```
	Fusion is not a valid member of ReplicatedStorage "ReplicatedStorage"
	```

	If you're seeing this error, then your script can't find Fusion.

	This code assumes you've installed Fusion into `ReplicatedStorage`. If
	you've installed Fusion elsewhere, you'll need to tweak the `require()` on
	line 2 to point to the correct location.

	If line 2 looks like it points to the correct location, refer back to
	[the previous section](#installing-fusion) and double-check you've set
	everything up properly. Make sure you have a `ModuleScript` inside
	`ReplicatedStorage` called "Fusion".

-----

## Install Fusion to your filesystem

If you're using pure Luau, or if you're synchronising into Roblox Studio from
the filesystem or an external editor, you can use these alternate steps instead:

??? example "Steps (click to expand)"
	1. Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
	2. Under 'Assets', download `Source code (zip)`. Inside is a copy
	of the Fusion GitHub repository.
	3. Inside the zip, copy the `src` folder - it may be inside another folder.
	4. Paste the `src` folder into your local project, wherever you keep your
	libraries (e.g. inside a `lib` or `shared` folder)
	5. Rename the pasted folder from `src` to `Fusion`.

	Once everything is set up, you should be able to `require()` Fusion in one
	of the following ways:

	```Lua
	-- Rojo
	local Fusion = require(ReplicatedStorage.Fusion)

	-- darklua
	local Fusion = require("../shared/Fusion")

	-- vanilla Luau
	local Fusion = require("../shared/Fusion/init.lua")
	```

-----

## Where To Get Help

Fusion is built to be easy to use, and we want these tutorials to be as useful
and comprehensive as possible. However, maybe you're stuck on a cursed issue
and really need some help; or perhaps you're looking to get a better overall
understanding of Fusion!

Whatever you're looking for, here are some resources for you to get help:

- [The Roblox OSS Discord](https://discord.gg/h2NV8PqhAD) has a [#fusion](https://discord.com/channels/385151591524597761/895437663040077834) channel
- Check out [our Discussions page](https://github.com/Elttob/Fusion/discussions) on GitHub
- [Open an issue](https://github.com/Elttob/Fusion/issues) if you run into bugs or have feature requests
