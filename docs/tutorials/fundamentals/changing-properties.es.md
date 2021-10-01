Ahora que ya sabemos cómo representar y trabajar con state de la UI, aprendamos 
cómo vincular propiedades a nuestro state de la UI para que podamos mostrar un 
mensaje en pantalla.

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numPlayers = State(5)
	local message = Computed(function()
		return "Hay " .. numPlayers:get() .. " en línea."
	end)

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "ExampleGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50)
		}
	}
	```

-----

## Pasando State a Propiedades

En nuestro código actual estamos usando state y computed objects para guardar 
y procesar algunos datos:

```Lua linenums="11"
local numPlayers = State(5)
local message = Computed(function()
	return "Hay " .. numPlayers:get() .. " en línea."
end)
```

Cuando usamos la función `New`, podemos usar estos state objects como propiedades. 
En otras palabras, podemos establecer el Text de nuestro TextLabel para que sea 
nuestro estado `message`:

```Lua linenums="11" hl_lines="18"
local numPlayers = State(5)
local message = Computed(function()
	return "Hay " .. numPlayers:get() .. " en línea."
end)

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "ExampleGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = message
	}
}
```

Esto establecerá el Text a lo que esté guardado en `message`, y lo mantiene 
actualizado a medida que `message` se cambia.

Para mantener las cosas organizadas, puedes crear el computed object directamente 
junto a la propiedad, para mantenerla cerca de donde se usa:

```Lua linenums="11" hl_lines="15-17"
local numPlayers = State(5)

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "ExampleGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = Computed(function()
			return "Hay " .. numPlayers:get() .. " en línea."
		end)
	}
}
```

Eso es todo lo que debes saber - es común usar cualquier estado como propiedad 
cuando se usa la función `New`.
-----

## Actualizaciones Pospuestas

Vale la pena saber que los cambios de propiedades no son aplicados de inmediato - 
son pospuestos hasta el siguiente render step.

En este ejemplo, el valor del state object cambia muchas veces. Sin embargo, 
Fusion solo actualizará la propiedad en el siguiente render step, esto significa 
que solo veremos el último cambio tener efecto:

=== "Lua"
	```Lua
	local state = State(1)

	local ins = New "NumberValue" {
		Value = state,
		[OnChange "Value"] = function(newValue)
			print("El nuevo valor es:", newValue)
		end)
	}

	state:set(2)
	state:set(3)
	state:set(4)
	state:set(5)
	```
=== "Output esperado"
	```
	El nuevo valor es: 5
	```

Esto es hecho por propósitos de optimización; mientras es relativamente menos costoso 
actualizar state objects muchas veces por fotograma, es costoso actualizar instancias. 
Además, no hay ningún motivo para actualizar una instancia tantas veces por fotograma, 
porque este solo se renderiza una vez.

En casi todos los casos, esto es una optimización conveniente. Sin embargo, en 
unos pocos casos puede ser problemático.

En concreto, en el ejemplo anterior, el controlador de `OnChange` no se ejecuta 
cada vez que el valor del state object cambia. En cambio, se ejecuta en el render 
step *después* de que el state object cambia, porque es cuando la propiedad cambia 
en realidad.

Esto puede conducir a errores off-by-one-frame (por un fotograma) si no eres 
cuidadoso, así que sé cauteloso en cuanto uses `OnChange` en propiedades que 
vincules al state.

-----

Eso es todo lo que tienes que saber para conectar propiedades con state - es un 
concepto simple pero fundamental para crear UIs dinámicas e interactivas.

??? summary "Código finalizado"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numPlayers = State(5)

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "ExampleGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = Computed(function()
				return "Hay " .. numPlayers:get() .. " jugadores en línea."
			end)
		}
	}
	```

!!! quote "Última Actualización de la Localización 30/09/2021"
