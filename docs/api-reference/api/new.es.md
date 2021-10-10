```Lua
function New(className: string): (props: {[string | Symbol]: any}) -> Instance
```

Construye y regresa una nueva instancia con opciones para ajustar propiedades, 
handlers de eventos y otros atributos en la instancia de inmediato.

La función tiene parámetros currificados (curried) - cuando se llama `New` con el 
parámetro `className`, este regresara una segunda función que acepta el parámetro 
`props`. Esto se hace para aprovechar el azúcar sintáctico para llamadas a 
funciones en Lua:

```Lua
local myInstance = New("Frame")({...})
-- es equivalente a:
local myInstance = New "Frame" {...}
```

!!! warning "Limpiando instancias"
	Asegúrate de destruir tus instancias adecuadamente. Sin usar un explícito 
	`:Destroy()`, es fácil introducir accidentalmente fugas en la memoria (memory leaks).

	Para listas de instancias, puedes usar [ComputedPairs](../computedpairs), 
	el cual viene con buenos valores predeterminados para la limpieza y caché 
	de instancias.

-----

## Parámetros

- `className: string` - el tipo de clase de la instancia que será creada
- `props: {[string | Symbol]: any}` - una tabla de propiedades, controladores de 
eventos y otros atributos que serán aplicados a la instancia

-----

## Ejemplo de Uso

```Lua
local myButton: TextButton = New "TextButton" {
	Parent = Players.LocalPlayer.PlayerGui,

	Position = UDim2.fromScale(.5, .5),
	AnchorPoint = Vector2.new(.5, .5),
	Size = UDim2.fromOffset(200, 50),

	Text = "¡Hola, mundo!",

	[OnEvent "Activated"] = function()
		print("¡El botón fue cliqueado!")
	end,

	[OnChange "Name"] = function(newName)
		print("El botón fue renombrado a:", newName)
	end,

	[Children] = New "UICorner" {
		CornerRadius = UDim.new(0, 8)
	}
}
```

-----

## Pasando Propiedades

La tabla `props` usa una mezcla de keys de string y symbol para especificar atributos 
de la instancia que deben ser establecidos.

Las keys de string son tratadas como declaraciones de propiedad - los valores pasados serán 
establecidos en la instancia:

```Lua
local example = New "Part" {
	-- establece la propiedad Position
	Position = Vector3.new(1, 2, 3)
}
```

Además, al pasar [state objects](api-reference/state.md) o [computed objects](api-reference/computed.md) 
se vincula el valor de la propiedad; cuando el valor del objeto cambia, la propiedad también 
se actualiza en el siguiente render step:

```Lua
local myName = State("Bob")

local example = New "Part" {
	-- al principio, el Name será establecido a Bob
	Name = myName
}

-- se cambia el state object para guardar "John"
-- en el siguiente render step, el Name de la parte será cambiado a John
myName:set("John")
```

Fusion proporciona keys de symbol adicionales para otros propósitos especializados 
- mira la documentación para más información en cómo funciona cada uno:

- [Children](../children) - hace una instancia parent de otras instancias
- [OnEvent](../onevent) - conecta un callback a un evento en esta instancia
- [OnChange](../onchange) - conecta un callback al evento `GetPropertyChangedSignal` 
para una propiedad en esta instancia

-----

## Propiedades Predeterminadas

La función `New` proporciona su propia colección de valores de propiedades 
'sensible default' para algunos tipos de clase, que serán usados en lugar 
de los valores predeterminados de Roblox. Esto se hace para optar por no usar 
características heredadas y valores predeterminados poco útiles.

Puedes ver las propiedades predeterminadas que Fusion usa aqui:

??? note "Propiedades predeterminadas"
	```Lua
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling"
	},

	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling"
	},

	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		SizingMode = "PixelsPerStud",
		PixelsPerStud = 50
	},

	Frame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ScrollBarImageColor3 = Color3.new(0, 0, 0)
	},

	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ClearTextOnFocus = false,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	ImageLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false
	},

	ViewportFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	VideoFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	}
	```

!!! quote "Última Actualización de la Localización 10/10/2021"
