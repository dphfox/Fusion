!!! warning "En construcción"
	Esta página está en construcción - la información puede faltar o estar incompleta.

Aplicando todo lo que hemos aprendido hasta el momento, construyamos una UI para 
ver como las herramientas básicas de Fusion trabajan juntas en un proyecto verdadero.

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children
	local OnEvent = Fusion.OnEvent

	local State = Fusion.State
	local Computed = Fusion.Computed
	```

-----

## Construyendo La UI

Crearemos un botón el cual muestra la cantidad de veces que ha sido bloqueado - 
esto es un ejemplo común usado como introducción a la UI en muchas bibliotecas 
y frameworks porque este involucra UI.

Comenzaremos creando un ScreenGui para mantener nuestro botón:

```Lua linenums="1" hl_lines="12-17"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local State = Fusion.State
local Computed = Fusion.Computed

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling"
}

```

Luego, crearemos un TextButton que podemos cliquear, y un mensaje en un TextLabel 
para mostrar eventualmente la cantidad de clics realizados.

```Lua linenums="12" hl_lines="7-29"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "¡Cliqueame!"
		},

		New "TextLabel" {
			Name = "Message",
			Position = UDim2.new(0.5, 0, 0.5, 100),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(255, 255, 255),

			Text = "Mensaje provisional..."
		}
	}
}

```

Con estas tres instancias, tenemos suficiente con lo que trabajar por lo que 
queda del tutorial. Ejecutando el código anterior nos da esto:

![Imagen de UI básica](BasicUI.png)

-----

## Agregando State

Ahora, agreguemos algunos state para hacer nuestra UI dinámica. Comencemos 
con un state object para guardar el número de clics:

```Lua linenums="12" hl_lines="1"
local numClicks = State(0)

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling",

	[Children] = {

```

Ahora, podemos reemplazar el texto provisional con un computed state, para 
tornar el número de clics dentro de un mensaje completo:

```Lua linenums="29" hl_lines="12-14"
			Text = "¡Cliqueame!"
		},

		New "TextLabel" {
			Name = "Message",
			Position = UDim2.new(0.5, 0, 0.5, 100),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(255, 255, 255),

			Text = Computed(function()
				return "Cliqueaste " .. numClicks:get() .. " veces."
			end)
		}
	}
}
```

Ahora te darás cuenta que el mensaje refleja en el texto el número de clics 
guardados en `numClicks`:

![Imagen de la UI con el mensaje usando computed state](UIWithState.png)

-----

## Monitoreando Clics

Ahora que ya tenemos nuestra UI en su lugar y funciona con nuestro state, solo 
tenemos que incrementar el número de clics guardados en `numClicks` cuando 
liqueamos el botón.

Para comenzar, agreguemos un handler de `OnEvent` para el evento Activated del 
botón. Esto se ejecutará cuando cliqueamos el botón.

```Lua hl_lines="12-15"
	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "¡Cliqueame!",

			[OnEvent "Activated"] = function()
				-- ¡el botón fue cliqueado!
				-- TODO: incrementar el state
			end
		},

		New "TextLabel" {
```

Luego, para incrementar el state, podemos usar `:get()` para conseguir el número 
de clics, sumarle uno, y establecerlo con `:set()` con el nuevo valor:

```Lua hl_lines="14"
	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "¡Cliqueame!",

			[OnEvent "Activated"] = function()
				-- ¡el botón fue cliqueado!
				numClicks:set(numClicks:get() + 1)
			end
		},

		New "TextLabel" {
```

Eso es todo - intenta cliquear el botón, y observa el mensaje cambiar en respuesta:


![Imagen de la UI terminada respondiendo ante clics](FinishedUI.png)

-----

Si has logrado seguir a lo largo del tutorial, felicidades - ¡ahora deberías tener 
un buen conocimiento en los conceptos fundamentales de Fusion!

Con solo estas herramientas, serás capaz de construir casi todo lo que puedas pensar. 
Sin embargo, Fusion aún tiene más herramientas disponibles para hacer tu código más 
fácil y simple de gestionar - cubriremos esto en *'Otros Fundamentos'*.

!!! quote "Última Actualización de la Localización 26/09/2021"
