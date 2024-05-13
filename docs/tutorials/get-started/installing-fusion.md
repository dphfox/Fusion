## Install via Roblox

If you are creating Luau experiences in Roblox Studio, then you can import a
Roblox model file containing Fusion.

- Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
- Click the 'Assets' dropdown to view the downloadable files:

![Picture of Fusion's GitHub Releases page, with the Assets dropdown highlighted.](Github-Releases-Guide-1-Light.png#only-light)
![Picture of Fusion's GitHub Releases page, with the Assets dropdown highlighted.](Github-Releases-Guide-1-Dark.png#only-dark)

- Click on the `Fusion.rbxm` file to download it. This model contains Fusion.

![The Assets dropdown opened to reveal downloads, with Fusion.rbxm highlighted.](Github-Releases-Guide-2-Light.png#only-light)
![The Assets dropdown opened to reveal downloads, with Fusion.rbxm highlighted.](Github-Releases-Guide-2-Dark.png#only-dark)

- Head into Roblox Studio to import the model; if you're just following the
tutorials, an empty baseplate will do.
- Right-click on `ReplicatedStorage`, and select 'Insert from File':

![ReplicatedStorage is right-clicked, showing a context menu of items. Insert from File is highlighted.](Github-Releases-Guide-3-Light.png#only-light)
![ReplicatedStorage is right-clicked, showing a context menu of items. Insert from File is highlighted.](Github-Releases-Guide-3-Dark.png#only-dark)

- Select the `Fusion.rbxm` file you just downloaded. Y
- You should see a 'Fusion' module script appear in `ReplicatedStorage`!

Now, you can create a script for testing:

- Create a `LocalScript` in `StarterGui` or `StarterPlayerScripts`.
- Remove the default code, and paste the following code in:

```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
```

- Press 'Play' - if there are no errors, everything was set up correctly!

-----

## Install as Source Code

If you're using pure Luau, or if you're synchronising external files into Roblox
Studio, then you can use Fusion's source code directly.

- Head over to [Fusion's 'Releases' page](https://github.com/Elttob/Fusion/releases).
- Under 'Assets', download `Source code (zip)`. Inside is a copy
of the Fusion GitHub repository.
- Inside the zip, copy the `src` folder - it may be inside another folder.
- Paste the `src` folder into your local project, wherever you keep your
libraries 
	- For example, you might paste it inside a `lib` or `shared` folder.
- Rename the pasted folder from `src` to `Fusion`.

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