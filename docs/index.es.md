---
  hide:
    - toc
    - navigation
---

<link rel="stylesheet" href="assets/index.css">
<script>
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

<section class="fusion-home-landing">
    <h1>Construye tu mejor UI.</h1>
    <p>
        Fusion es una biblioteca reactiva moderna, construida específicamente para
        <a href="https://developer.roblox.com/">Roblox</a>
        y
        <a href="https://luau-lang.org/">Luau</a>.
    </p>
    <p>
        Construye tu UI con una sintaxis declarativa que es fácil de leer y escribir.<br>
        Conecta datos en vivo con una gestión de estados realmente simple, flexible y reactiva.<br>
        Entrega una experiencia impecable y rápida a todos - en móvil, consola, PC o VR.
    </p>
    <nav>
        <a href="tutorials/" class="arrow-link">Empezar</a>
        <a href="https://github.com/Elttob/Fusion/releases" class="arrow-link external-link">Descargar último lanzamiento</a>
    </nav>
</section>

-----

<section class="fusion-home-float">
    <h2>Sintaxis declarativa de UI</h2>
    <p>
        Fusion provee una sintaxis natural y fácil de leer, para que te puedas 
        enfocar en cómo tu UI debe verse, sin preocuparte acerca de su implementación.
    </p>
    <p>
        Enfócate en las propiedades y los children en tu UI, no en APIs verbosos.
    </p>
</section>

```Lua
return New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,

    [Children] = New "TextButton" {
        Position = UDim2.fromScale(.5, .5)
        AnchorPoint = Vector2.new(.5, .5),
        Size = UDim2.fromOffset(200, 50),

        Text = "Fusion es divertido :)",

        [OnEvent "Activated"] = function()
            print("¡Cliqueado!")
        end
    }
}
```

-----

<section class="fusion-home-float">
    <h2>Gestión de estados reactivos</h2>
    <p>
        Escribe fluidamente todos tus cálculos, y se ejecutarán automáticamente 
        cuando sus variables cambian.
    </p>
    <p>
        Fusion acelera y optimiza todos tus cálculos por ti.
    </p>
</section>

```Lua
local numCoins = State(10)

local doubleCoins = Computed(function()
    return numCoins:get() * 2
end)

local coinsMessage = Computed(function()
    return "Tienes " .. numCoins:get() .. " monedas."
end)

return New "TextLabel" {
    Text = coinsMessage
}
```

-----

<section class="fusion-home-float">
    <h2>Anima todo</h2>
    <p>
        Dale vida a tu UI con las herramientas de animación más fáciles y 
        universales de cualquier biblioteca de Roblox. Accede a tweens y 
        springs con una línea de código.
    </p>
    <p>
        Anima cualquier cosa instantáneamente, sin necesidad de usar 
        refactorización o trucos de rendimiento.
    </p>
</section>

```Lua
local playerCount = State(100)
local position = State(UDim2.new(0, 0, 0, 0))

local smoothCount = Tween(playerCount, TweenInfo.new(0.5))

return New "TextLabel" {
    Position = Spring(position, 25, 0.2),

    Text = Computed(function()
        return "Jugadores en línea: " .. math.floor(smoothCount:get())
    end)
}
```

<section class="fusion-home-centre" style="margin-top: 5em">
    <img style="display: block; width: 100%; height: auto;" src="index/performance.svg" alt="Vector illustration of different device types" width="586" height="200">
    <h2>Fusion es construido teniendo en cuenta el rendimiento, desde la idea hasta la implementación.</h2>
    <p>
        Desde PCs de escritorio de gama alta hasta celulares de hace años, 
        Fusion entrega una experiencia excepcionalmente impecable y ligera 
        como estándar.
    </p>
    <p>
        Construye tus interfaces más bonitas, intrépidas y animadas con 
        confianza - Fusion se adapta a dispositivos con alta frecuencia 
        de actualización y VR.
    </p>
</section>

<section class="fusion-home-centre" style="margin-top: 5em">
    <img style="display: block; width: 100%; height: auto;" src="index/get-started.svg" alt="Vector illustration of 'get started' process" width="586" height="200">
    <h2>Ponte en marcha con Fusion en minutos.</h2>
    <p>
       Descargar e importar Fusion a Studio es rápido, fácil y 100% gratis.
    </p>
    <p>
       Los tutoriales para comenzar están dirigidos a una amplia gama de 
       creadores, desde desarrolladores de UI expertos a programadores novatos.
    </p>
</section>