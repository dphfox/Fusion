Welcome to the Fusion tutorial section! Here, you'll learn how to build great
things with Fusion, even if you're a complete newcomer to the library.

You'll not only learn how Fusion's features work, but you'll also be presented
with wisdom from those who've worked with some of the largest Fusion codebases
today.

!!! caution "But first, some advice from the maintainers..."
	**<span style="font-size: 1.5em; color: var(--fusiondoc-accent);">
	Fusion is pre-1.0 software.
	</span>**

	We *(the maintainers and contributors)* work hard to keep releases bug-free
	and relatively complete, so it should be safe to use in production. Many
	people already do, and report fantastic results!

	However, we mark Fusion as pre-1.0 because we are working on the design of
	the library itself. We strive for the best library design we can deliver,
	which means breaking changes are common and sweeping.

	With Fusion, you should expect:

	- upgrades to be frictionful, requiring code to be rethought
	- features to be superseded or removed across versions
	- advice or best practices to change over time

	You should *also* expect:

	- careful consideration around breakage, even though we reserve the right to
	  do it
	- clear communication ahead of any major changes
	- helpful advice to answer your questions and ease your porting process

	We hope you enjoy using Fusion!

-----

## What You Need To Know

These tutorials assume:

- That you're comfortable with the Luau scripting language.
	- These tutorials aren't an introduction to Luau! If you'd like to learn,
	check out the [Roblox documentation](https://create.roblox.com/docs).
- That - if you're using Roblox features - you're familiar with how Roblox works.
    - You don't have to be an expert! Knowing about basic instances, events
	and data types will be good enough.

Based on your existing knowledge, you may find some tutorials easier or harder.
Don't be discouraged - Fusion's built to be easy to learn, but it may still take
<<<<<<< HEAD
a bit of time to absorb some concepts. Learn at a pace which is right for you.

-----

## Installing Fusion

There are two ways of installing Fusion, dependent on your use case.

If you are creating Luau experiences in Roblox Studio, then you can import a
Roblox model file containing Fusion.

??? example "Steps (click to expand)"

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

	Now, you can create a script for testing:

	1. Create a `LocalScript` in `StarterGui` or `StarterPlayerScripts`.
	2. Remove the default code, and paste the following code in:
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```
	3. Press 'Play' - if there are no errors, everything was set up correctly!.

If you're using pure Luau, or if you're synchronising external files into Roblox
Studio, then you can use Fusion's source code directly.

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
	local Fusion = require("../shared/Fusion/init.luau")
	```

-----

## Getting Help

Fusion is built to be easy to use, and this website strives to be as useful and
comprehensive as possible. However, you might need targeted help on a specific
issue, or you might want to grow your understanding of Fusion in other ways.

The best place to get help is [the #fusion channel](https://discord.com/channels/385151591524597761/895437663040077834)
over on [the Roblox OSS Discord server](https://discord.gg/h2NV8PqhAD).
Maintainers and contributors drop in frequently, alongside many eager Fusion
users.

For bugs and feature requests, [open an issue](https://github.com/Elttob/Fusion/issues)
on GitHub.
=======
a bit of time to absorb some concepts. Learn at a pace which is right for you.
>>>>>>> upstream/main
