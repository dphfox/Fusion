Ahora que tenemos Fusion en marcha, aprendamos a crear instancias desde un 
script de manera rápida y ordenada. 

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```

-----

## Instancias desde Código

En Fusion, tu creas todas las instancias de UI desde código. Eso puede sonar 
contraproducente, pero eso próximamente te permitirá reusar fácilmente tus 
componentes de UI y hacer uso de herramientas potentes para conectar tu UI 
y scripts del juego juntos.

Para hacer la experiencia más agradable, Fusion introduce una alternativa a 
`Instance.new` que te permite construir instancias completas de golpe - 
llamada la función `New`.

Aqui esta un fragmento de código de ejemplo usando `New` - puedes compararlo a `Instance.new`:

=== "New"

	```Lua
	local myPart = New "Part" {
		Parent = workspace,

		Position = Vector3.new(1, 2, 3),
		BrickColor = BrickColor.new("Bright green"),
		Size = Vector3.new(2, 1, 4)
	}
	```

=== "Instance.new"

	```Lua
	local myPart = Instance.new("Part")

	myPart.Position = Vector3.new(1, 2, 3)
	myPart.BrickColor = BrickColor.new("Bright green")
	myPart.Size = Vector3.new(2, 1, 4)

	myPart.Parent = workspace
	```

!!! note
	No necesitas paréntesis `()` para `New` - solo escribe el 
	nombre de la clase y sus propiedades como lo hemos hecho anteriormente.

En el fragmento de código anterior, la función `New`:

- crea una nueva parte
- le da una posición, tamaño y color
- asigna el workspace como su parent
- regresa la parte, para que pueda ser guardada en `myPart`

La función `New` tiene muchas características incorporadas, las cuales usarás 
después, pero por ahora la usaremos para establecer propiedades.

-----

## Creando Un ScreenGui

Usemos la función `New` para crear un ScreenGui.

Lo pondremos en nuestro PlayerGui, así que necesitamos importar el servicio `Players`.

```Lua linenums="1" hl_lines="2"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)
```

También tendremos que importar `New` desde Fusion:

```Lua linenums="1" hl_lines="5"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
```

Ahora podemos usar la función `New` como hicimos en el fragmento anterior. 
Queremos crear un ScreenGui con estas propiedades:

- un nombre de 'MyFirstGui'
- `ResetOnSpawn` deshabilitado
- el ZIndexBehavior` establecido como 'Sibling'
- PlayerGui como su parent

??? question "¿Qué hacen estas propiedades?"
	- Un nombre hace más fácil encontrar nuestra UI en el Explorer.
	- Deshabilitando `ResetOnSpawn` detiene que Roblox destruya nuestra UI 
	después de que reaparezcamos.
	- `ZIndexBehavior` es más que todo preferencia, pero [cambia como la UI 
	es organizada por profundidad](https://devforum.roblox.com/t/new-zindexbehavior-property-is-now-live/76051).
	- Asignando el PlayerGui como su parent hace nuestra UI visible en la pantalla.


El siguiente fragmento de código hace todo esto por nosotros:

```Lua linenums="1" hl_lines="7-13"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling"
}
```

Si presionas 'Play', deberías ver que un ScreenGui ha aparecido en tu 
PlayerGui, con todas las propiedades que hemos establecido:

![Pantallazo del Explorer](MyFirstGui.png)

Esperamos que te estés sintiendo cómodo con esta sintaxis - nos extenderemos en 
esto en la siguiente sección.

-----

## Agregando un Child

Ahora agreguemos un TextLabel con un mensaje y asignar su parent a nuestro ScreenGui.

Para ayudar con esto, la función `New` nos permite agregar children directamente a 
nuestra instancia. Para usar esta característica, primero tendremos que importar 
`Children` desde Fusion:

```Lua linenums="1" hl_lines="6"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children

```

Ahora podemos crear cualquier instancia como child de nuestro ScreenGui - solo 
pasalo usando `#!Lua [Children]` como la key.

Por ejemplo, aquí estamos creando nuestro TextLabel, y agregandolo como un child:

```Lua linenums="8" hl_lines="8-14"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = "Fusion es divertido :)"
	}
}
```

Si ahora presionas 'Play', deberías ver un TextLabel en el centro de tu pantalla:

![Resultado final](FinalResult.png)

-----

## Múltiples Children

Puedes agregar más de una instancia - `Children` permite usar arrays de instancias.

Si deseamos múltiples TextLabels, podemos crear un array para mantener nuestros children:

```Lua linenums="8" hl_lines="8 16"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion es divertido :)"
		}
	}
}
```

Ahora, podemos agregar otro TextLabel al array, y este también tendrá un parent:

```Lua linenums="8" hl_lines="17-23"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion es divertido :)"
		},

		New "TextLabel" {
			Position = UDim2.new(.5, 0, .5, 50),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "¡Dos es mejor que uno!"
		}
	}
}
```

Si presionas 'Play', deberías ver ambos TextLabels aparecer:

![Resultado final con muchos mensajes](FinalResult-Many.png)

-----

Felicidades - ¡has aprendido a crear instancias simples con Fusion! Durante 
el curso de los siguientes tutoriales, verás usada esta sintaxis mucho, 
así que tendrás un poco de tiempo para acostumbrarte a esta.

Es importante entender lo básico de la función `New`, debido a que es usada a lo largo de casi todo el código de Fusion.

??? abstract "Código finalizado"
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
			New "TextLabel" {
				Position = UDim2.fromScale(.5, .5),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "Fusion es divertido :)"
			},

			New "TextLabel" {
				Position = UDim2.new(.5, 0, .5, 50),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "¡Dos es mejor que uno!"
			}
		}
	}

	```

!!! quote "Última Actualización de la Localización 27/09/2021"
