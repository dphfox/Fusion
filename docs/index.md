---
  hide:
    - toc
    - navigation
---

<link rel="stylesheet" href="assets/index.css">
<script src="assets/index.js"></script>

<section class="fusion-home-landing">
    <h1>Build your best UI.</h1>
    <p>
        Fusion is a modern reactive UI library, built specifically for
        <a href="https://developer.roblox.com/">Roblox</a>
        and
        <a href="https://luau-lang.org/">Luau</a>.
    </p>
    <p>
        Build your UI with a declarative syntax that's easy to read and write.<br>
        Plug in live data with simple, flexible, truly reactive state management.<br>
        Deliver a fast, smooth experience to everyone - on mobile, console, PC or in VR.
    </p>
    <nav>
        <a href="tutorials/" class="arrow-link">Get started</a>
        <a href="https://github.com/Elttob/Fusion/releases" class="arrow-link external-link">Download latest</a>
    </nav>
</section>

-----

<section class="fusion-home-float">
    <h2>Declarative UI syntax</h2>
    <p>
        Fusion provides a natural, easy to read syntax, so you can focus on what
        your UI should look like, without worrying about the implementation.
    </p>
    <p>
        Focus on the properties and children in your UI, not verbose APIs.
    </p>
</section>

```Lua
return New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,

    [Children] = New "TextButton" {
        Position = UDim2.fromScale(.5, .5)
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromOffset(200, 50),

        Text = "Fusion is fun :)",

        [OnEvent "Activated"] = function()
            print("Clicked!")
        end
    }
}
```

-----

<section class="fusion-home-float">
    <h2>Reactive state management</h2>
    <p>
        Fluidly write all your calculations, and they'll be automatically run as
        your variables change.
    </p>
    <p>
        Fusion accelerates and optimises all of your computations for you.
    </p>
</section>

```Lua
local numCoins = State(10)

local doubleCoins = Computed(function()
    return numCoins:get() * 2
end)

local coinsMessage = Computed(function()
    return "You have " .. numCoins:get() .. " coins."
end)

return New "TextLabel" {
    Text = coinsMessage
}
```

-----

<section class="fusion-home-float">
    <h2>Animate everything</h2>
    <p>
        Bring your UI to life with the simplest, most universal animation tools
        of any Roblox library. Access tweens and springs with one line of code.
    </p>
    <p>
        Animate anything instantly, no refactoring or performance tricks required.
    </p>
</section>

```Lua
local playerCount = State(100)
local position = State(UDim2.new(0, 0, 0, 0))

local smoothCount = Tween(playerCount, TweenInfo.new(0.5))

return New "TextLabel" {
    Position = Spring(position, 25, 0.2),

    Text = Computed(function()
        return "Players online: " .. math.floor(smoothCount:get())
    end)
}
```

<section class="fusion-home-centre" style="margin-top: 5em">
    <img style="display: block; width: 100%; height: auto;" src="index/performance.svg" alt="Vector illustration of different device types" width="586" height="200">
    <h2>Fusion is built with performance in mind, from idea to implementation.</h2>
    <p>
        From top-end desktop PCs to budget phones from years ago, Fusion
        delivers an exceptionally light, fluid experience as standard.
    </p>
    <p>
        Build your most beautiful, bold, animated interfaces with confidence -
        Fusion scales to high-refresh-rate devices and VR effortlessly.
    </p>
</section>

<section class="fusion-home-centre" style="margin-top: 5em">
    <img style="display: block; width: 100%; height: auto;" src="index/get-started.svg" alt="Vector illustration of 'get started' process" width="586" height="200">
    <h2>Get up and running with Fusion in minutes.</h2>
    <p>
        Downloading and importing Fusion into Studio is quick, easy and 100%
        free.
    </p>
    <p>
        The Fusion starter tutorials are aimed at a wide range of creators, from
        seasoned UI developers to novice scripters.
    </p>
</section>