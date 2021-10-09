Usualmente es una buena idea separar nuestra UI en partes reusables, 
conocidas como 'componentes'. Aprendamos cómo crear estas con Fusion.

-----

## ¿Qué son los Componentes?

Cuando pensamos en nuestras UIs como humanos, usualmente pensamos de estas en 
términos de ‘bloques’ reusables de UI. Por ejemplo, puedes dividir la siguiente 
interfaz en estos ‘bloques’.

![Diagrama de componentes resaltados en la UI](ComponentsDiagram.png)

En el diseño y desarrollo de UI, estos son ampliamente conocidos como ‘componentes’.

Los componentes son útiles, porque solo necesitan definir *generalmente* como cada 
uno se ve. Luego podemos aplicar como se ven a cada componente a lo largo de nuestra UI. 
Puedes incluso proporcionar propiedades, como texto a insertar, o si se muestra un icono:

![Diagrama definiendo y aplicando como cada componente se ve](ComponentDefinitionDiagram.png)

Construyendo nuestra UI ensamblando componentes (en vez de crear cada instancia 
manualmente) nos ayudará a reusar y organizar nuestro código de UI, y lo hace más 
fácil de leer y editar.

-----

## Reutilizando UI

Cuando queremos reutilizar un poco de código, usualmente lo ponemos en una función. 
Después podemos usar ese fragmento de código en múltiples lugares, opcionalmente 
proporcionando argumentos para ajustar cómo se ejecuta.

Eso se alinea con lo que necesitamos que los ‘componentes’ hagan - queremos que se 
pueda reutilizar partes de nuestra UI en múltiples lugares, opcionalmente proporcionando 
propiedades para ajustar cómo se ve.

Por esto, en Fusion, los componentes son solo funciones. Toman una tabla de propiedades, 
crean UI, y la regresan:

```Lua
local function Greeting(props)
	return New "TextLabel" {
		BackgroundColor3 = Color3.new(1, 1, 0),
		TextColor3 = Color3.new(0, 0, 1),
		Size = UDim2.fromOffset(200, 50),
		Text = props.Message
	}
end
```

Podemos llamar la función `Greeting` para tener una copia de esa UI con cualquier mensaje 
que deseemos:

```Lua
local greeting1 = Greeting {
	Message = "¡Hola!"
}

local greeting2 = Greeting {
	Message = "Ey :)"
}
```

!!! note
	Si estás usando un solo argumento `props` (como lo hacemos posteriormente), 
	¡no necesitas paréntesis `()` al llamar la función con una tabla!

También podemos incorporar componentes dentro de otro código de Fusion facilmente:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = Greeting {
		Message = "¿Qué onda? B)"
	}
}
```

Esto hace a los componentes una herramienta potente para crear código de UI organizado 
y reutilizable dentro de Fusion.

Por el resto del tutorial, veamos patrones de programación comunes que puedes usar 
con componentes para hacerlos aún más útiles.

-----

## Pasando Children

A veces, podemos crear componentes que puede tener children. Por ejemplo, veamos 
este componente, que ordena children dentro de un scrolling grid:

```Lua
local function Gallery(props)
	return New "ScrollingFrame" {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,

		[Children] = {
			New "UIGridLayout" {
				CellPadding = UDim2.fromOffset(4, 4),
				CellSize = UDim2.fromOffset(100, 100)
			},

			-- TODO: ¿agregar algunos children aquí?
		}
	}
end
```

Supongamos que queremos que los usuarios pasen children para que aparezcan en el grid:

```Lua
local gallery = Gallery {
	Position = UDim2.fromScale(.5, .5)
	Size = UDim2.fromOffset(400, 300),
	AnchorPoint = Vector2.new(.5, .5),

	[Children] = {
		New "ImageLabel" { ... },
		New "ImageLabel" { ... },
		New "ImageLabel" { ... }
	}
}
```

Podemos acceder a estos children en nuestra función usando `#!Lua props[Children]`.Ya que 
la función `New` nos permite pasar arrays de children, podemos incluirlas directamente 
en nuestro código así:

```Lua
local function Gallery(props)
	return New "ScrollingFrame" {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,

		[Children] = {
			New "UIGridLayout" {
				CellPadding = UDim2.fromOffset(4, 4),
				CellSize = UDim2.fromOffset(100, 100)
			},

			props[Children]
		}
	}
end
```

¡Eso es todo lo que hay! Solo recuerda que `#!Lua [Children]` aún es una propiedad como 
cualquiera, así que si estás procesando los children, puede ser bueno primero hacer 
una comprobación de tipos:

-----

## Múltiples Instancias

En algunas específicas circunstancias, desearías regresar más de una instancia 
de un componente.

No deberías regresar múltiples valores de un componente directamente. Debido a como 
Lua funciona, esto puede producir bugs sutiles en tu código:

```Lua
local function ManyThings(props)
	-- ¡no hagas esto!
	-- deberías regresar un valor de un componente
	return
		New "TextLabel" {...},
		New "ImageButton" {...},
		New "Frame" {...}
end

local gui1 = New "ScreenGui" {
	-- ¡esto solo establecerá el parent del TextLabel!
	[Children] = ManyThings {}
}

local gui2 = New "ScreenGui" {
	[Children] = {
		New "TextLabel" {...},

		-- this is also broken
		ManyThings {},

		New "TextLabel" {...}
	}
}
```

A better way to do this is to return an *array* of instances. This means you
only return a single value - the array. This gets around the subtle bugs that
normally occur when dealing with multiple return values.

Since `#!Lua [Children]` supports arrays of children, all our instances are now
parented as expected:

```Lua
local function ManyThings(props)
	-- using an array ensures we only return one value
	return {
		New "TextLabel" {...},
		New "ImageButton" {...},
		New "Frame" {...}
	}
end

local gui1 = New "ScreenGui" {
	-- this now works!
	[Children] = ManyThings {}
}

local gui2 = New "ScreenGui" {
	[Children] = {
		New "TextLabel" {...},

		-- this also now works!
		ManyThings {},

		New "TextLabel" {...}
	}
}

```

!!! tip
	If you're coming from other UI libraries or frameworks, you may have heard
	of this concept referred to as 'fragments'. In Fusion, fragments are just
	plain arrays of children rather than a special kind of object.

-----

## Callbacks

For some components (e.g. buttons or text boxes), some code might need to run in
response to events like clicks or typing. You can use callbacks to achieve this.

Consider this `Button` component as an example. Notice we're using `props.OnClick`
with `#!Lua [OnEvent "Activated"]`:

```Lua
local function Button(props)
	return New "TextButton" {
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,

		BackgroundColor3 = Color3.new(0, 0.4, 1),
		TextColor3 = Color3.new(1, 1, 1),
		Text = props.Message,

		[OnEvent "Activated"] = props.OnClick
	}
end
```

This means that anyone using the `Button` component can provide a callback
function, which will then be run when the button is clicked:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		Button {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Message = "Click me!",

			OnClick = function()
				-- this callback function will be passed into OnEvent, so it'll
				-- run when the button is clicked
				print("The button was clicked!")
			end
		},
	}
}
```

This isn't just limited to event handlers, either - any time you want to let
the caller provide some code, callbacks are a great option.

-----

## State

Because components are functions, we can do more than just creating instances.
You can also store state inside them!

Let's make a 'toggle button' component to demonstrate this. When we click it,
it should toggle on and off.

Here's some basic code to get started - we just need to add some state to this:

```Lua
local function ToggleButton(props)
	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromOffset(200, 50),
		Text = props.message,

		[OnEvent "Activated"] = function()
			-- TODO: toggle the button!
		end
	}
end
```

Firstly, let's create a state object to store whether the button is currently
toggled on or off:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			-- TODO: toggle the button!
		end
	}
end
```

Next, we can toggle the stored value in our event handler:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			isButtonOn:set(not isButtonOn:get())
		end
	}
end
```

Finally, we can make the background colour show whether the button is toggled on
or off, using some computed state:

```Lua
local function ToggleButton(props)
	local isButtonOn = State(false)

	return New "TextButton" {
		BackgroundColor3 = Computed(function()
			if isButtonOn:get() then
				return Color3.new(0, 1, 0) -- green when toggled on
			else
				return Color3.new(1, 0, 0) -- red when toggled off
			end
		end),
		TextColor3 = Color3.new(0, 0, 0),
		Text = props.message,

		[OnEvent "Activated"] = function()
			isButtonOn:set(not isButtonOn:get())
		end
	}
end
```

With just this code, we've made our toggle button fully functional! Again, this
is a regular Lua function, so nothing fancy is going on behind the scenes.

Just like before, we can now include our toggle button in our UI easily:

```Lua
local gui = New "ScreenGui" {
	Name = "ExampleGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "UIListLayout" {
			Padding = UDim.new(0, 4)
		},

		ToggleButton {
			message = "Click me!"
		},

		ToggleButton {
			message = "Also, click me!"
		},

		ToggleButton {
			message = "Each button is independent :)"
		}
	}
}
```

Because we create a new button each time we call the function, each button keeps
it's own state and functions independently.