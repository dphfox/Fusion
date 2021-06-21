---
  hide:
    - toc
    - navigation
---

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
    <img style="display: block; width: 100%; height: auto;" src="images/index/performance.svg" alt="Vector illustration of different device types" width="586" height="200">
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
    <img style="display: block; width: 100%; height: auto;" src="images/index/get-started.svg" alt="Vector illustration of 'get started' process" width="586" height="200">
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

<style>
    /* in the future, I'd like to move this into an external css file somehow */
    /* i apologise in advance to anyone who has to maintain this, I've had to
    do a ton of hacks to get css parallax to work */

    html {
        height: 100%;
        overflow-y: hidden;
        scroll-behavior: auto;
    }

    body {
        position: absolute;
        top: 0;
        left: 0;
        background-color: var(--md-primary-fg-color);
        perspective: 1px;
        perspective-origin: top center;
        overscroll-behaviour: contain;
        height: 100%;
        overflow-x: hidden;
        overflow-y: auto;
    }

    [data-md-color-primary=black] .md-header {
        background: none;
    }

    [data-md-color-primary=black] .md-tabs {
        background: none;
    }

    .md-content__inner > .md-content__button:first-child {
        display: none;
    }

    .fusion-home-landing {
        min-height: 50rem;
        font-size: 1.25em;
        text-align: center;
    }

    body::before {
        content: '';
        position: absolute;
        top: 40rem;
        left: calc(50% - (116.4rem / 2));
        width: 116.4rem;
        height: 65.475rem;
        background: url("images/index/background2.jpg");
        background-size: 100%;
        background-repeat: no-repeat;

        z-index: -10;

        transform: translateZ(-0.8px) scale(1.8);
        transform-style: preserve-3d;
    }

    .fusion-home-landing h1 {
        margin-bottom: 0.5em;
    }

    .fusion-home-landing p {
        max-width: 38em;
        margin: 1em auto;
    }

    .fusion-home-landing nav {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
        gap: 2em;
    }

    .fusion-home-landing a.arrow-link::after {
        content: "->";
        display: inline-block;
        margin-left: 0.25em;
        margin-right: 0.25em;
        transition: margin 0.2s ease;
    }

    .fusion-home-landing a.arrow-link:hover::after {
        margin-left: 0.5em;
        margin-right: 0em;
    }

    .fusion-home-landing .landing-image {
        margin-top: 3em;
        margin-bottom: 3em;
        width: 100%;
        max-width: 48em;
        height: auto;
    }

    .fusion-home-float {
        float: left;
        width: 50%;
        padding-right: 1rem;
    }

    .fusion-home-centre {
        margin: auto;
        max-width: 40em;
        padding-right: 1rem;
    }

    /* adding some height to the #learn-more anchor tag means the title of the
       first section won't be cut off by the page header.
    */
    #learn-more {
        display: block;
        width: 1em;
        height: 3em;
    }

    /* HACK: code blocks don't support being floated properly, so they end up taking 100% of
       the page width, overlapping the paragraph next to them.

        To fix this, we disable pointer events on the code block directly, but enable it for the
        children, which are correctly positioned.
    */
    div.highlight {
        pointer-events: none;
    }

    div.highlight * * {
        pointer-events: initial;
    }

    .md-typeset code {
        background: var(--md-primary-fg-color);
    }

    .md-typeset hr {
        border-bottom-color: var(--md-default-fg-color);
        opacity: calc(35 / 255);
    }

    @media screen and (max-width: 45rem) {
        .fusion-home-landing {
            font-size: 1em;
        }

        body::before {
            top: 20rem;
            transform: translateZ(-0.5px) scale(1.2);
        }
    }

    @media screen and (max-width: 60rem) {
        .fusion-home-float {
            float: none;
            width: 100%;
            padding: 0rem;
        }
    }

    section h2 {
        margin-top: 0 !important;
    }
</style>

<script>
    // hack; if the body is scrolled, manually activate the header background
    const header = document.querySelector("[data-md-color-primary=black] .md-header")
    function updateScroll() {
        if(document.body.scrollTop > 10) {
            header.dataset.mdState = "shadow";
        } else {
            header.dataset.mdState = "";
        }
    }

    updateScroll();
    document.body.addEventListener("scroll", updateScroll);
</script>