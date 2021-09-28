Ahora que podemos crear instancias, aprendamos cómo manejar eventos y cambios 
de propiedad.

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "MyFirstGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = {
			New "TextButton" {
				Position = UDim2.new(0.5, 0, 0.5, -100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "¡Cliqueame!"
			},

			New "TextBox" {
				Position = UDim2.new(0.5, 0, 0.5, 100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "",
				ClearTextOnFocus = false
			}
		}
	}

	```

-----

## Conectando a Eventos

Dentro del código anterior, notarás un TextButton. Intentemos conectarle el 
evento `Activated` para detectar clics del mouse.

Para ayudar con esto, `New` nos permite agregar controladores de eventos a nuestra 
instancia directamente. Para poder usar esta característica, necesitamos importar 
`OnEvent` desde Fusion:

```Lua linenums="1" hl_lines="7"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
```

Ahora puedes pasar funciones de control de eventos usando `#!Lua [OnEvent "EventName"]` 
como la key.

Como un ejemplo, aquí estamos conectando una función a nuestros TextButtons con 
el evento `Activated`:

```Lua linenums="14" hl_lines="11-13"
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextButton" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion es divertido :)",

			[OnEvent "Activated"] = function(...)
				print("¡Cliqueado!", ...)
			end
		},

		New "TextBox" {
            Position = UDim2.new(0.5, 0, 0.5, 100),
```

Esto funciona como un regular `:Connect()` - recibirás todos los argumentos de este 
evento. Aquí, solo estamos les estamos haciendo print por propósitos de demostración.

Si presionas 'Play' y cliqueas el botón unas cuantas veces, deberías ver algo así 
en el output:

![Output del event handler](Clicked-Output.png)

¡Eso es todo lo que hay para el control de eventos! Fusion maneja las conexiones 
del evento por ti automáticamente.

-----

## Respondiendo al Cambio

Además de eventos regulares, puedes escuchar eventos de cambio de propiedad (los 
eventos regresados por `GetPropertyChangedSignal`).

Para usar eventos de cambio de propiedad, necesitarás importar `OnChange`:

```Lua linenums="1" hl_lines="8"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
```

Ahora puedes pasar funciones usando `#!Lua [OnChange "PropertyName"]` como la key. 
Cuando la propiedad es cambiada, tu función será llamada con el nuevo valor como su 
único argumento.

Para demostrar esto, aquí estamos haciendo print del texto en nuestro TextBox cuando 
sea que cambie:

```Lua linenums="25" hl_lines="14-16"
			[OnEvent "Activated"] = function(...)
				print("!Cliqueado!", ...)
			end
		},

		New "TextBox" {
			Position = UDim2.new(0.5, 0, 0.5, 100),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "",
			ClearTextOnFocus = false,

			[OnChange "Text"] = function(newText)
				print(newText)
			end
		}
	}
}
```

Ahora, si presionas 'Play' y empiezas a escribir dentro del TextBox, deberías 
ver el contenido del TextBox reflejado en el output por cada carácter que escribes:

![Output del controlador de cambio](Typing-Output.png)

-----

Con esto, has cubierto todo lo que hay para saber de controladores de evento y 
cambio de propiedad. En tutoriales posteriores, esto será útil para responder 
al input del usuario.

??? abstract "Código finalizado"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children
	local OnEvent = Fusion.OnEvent
	local OnChange = Fusion.OnChange

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "MyFirstGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = {
			New "TextButton" {
				Position = UDim2.new(0.5, 0, 0.5, -100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "¡Cliqueame!",

				[OnEvent "Activated"] = function(...)
					print("¡Cliqueado!", ...)
				end
			},

			New "TextBox" {
				Position = UDim2.new(0.5, 0, 0.5, 100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "",
				ClearTextOnFocus = false,

				[OnChange "Text"] = function(newText)
					print(newText)
				end
			}
		}
	}

	```

!!! quote "Última Actualización de la Localización 27/09/2021"
