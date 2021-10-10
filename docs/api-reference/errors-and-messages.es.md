Si tu código no está funcionando adecuadamente o si Fusion está fallando, podrías 
ver algunos errores aparecer en el output. Cada mensaje tiene un ID único al final.

En esta página, puedes aprender más acerca de cualquier error que estés recibiendo.

-----

## `cannotAssignProperty`

```
The class type 'Foo' has no assignable property 'Bar'.
```

Este mensaje aparece si estás intentando asignar una propiedad no existente o bloqueada 
usando la función [New](../new):

```Lua
local folder = New "Folder" {
	DataCost = 12345,
	ThisPropertyDoesntExist = "Ejemplo"
}
```

!!! tip
	Diferentes scripts pueden tener diferentes privilegios - por ejemplo, los plugins 
	tienen un mayor privilegio que los scripts del juego. ¡Asegúrate de tener los 
	privilegios necesarios para poder asignar a tus propiedades!

-----

## `cannotConnectChange`

```
The Frame class doesn't have a property called 'Foo'.
```

Este mensaje aparece si estás intentando conectar un handler con una propiedad 
de change event que no existe usando la función [New](../new):

```Lua
local textBox = New "TextBox" {
	[OnChange "EstaPropiedadNoExiste"] = function()
		...
	end)
}
```

-----

## `cannotConnectEvent`

```
The Frame class doesn't have an event called 'Foo'.
```

Este mensaje aparece si estás intentando conectar un handler con un evento que 
no existe usando la función [New](../new):

```Lua
local button = New "TextButton" {
	[OnEvent "EsteEventoNoExiste"] = function()
		...
	end)
}
```

-----

## `cannotCreateClass`

```
Can't create a new instance of class 'Foo'.
```

Este mensaje aparece cuando se usa la función [New](../new) con una clase de 
tipo inválida:

```Lua
local instance = New "ThisClassTypeIsInvalid" {
	...
}
```

-----

## `computedCallbackError`

```
Computed callback error: attempt to index a nil value
```

Este mensaje aparece cuando el callback de un [computed object](../computed) 
encuentra un error:

```Lua
local example = Computed(function()
	local badMath = 2 + "pez"
end)
```

-----

## `invalidSpringDamping`

```
The damping ratio for a spring must be >= 0. (damping was -0.50)
```

Este mensaje aparece si estás intentando proporcionar una amortiguación a un 
[spring](../spring) que sea menor que 0:

```Lua
local speed = 10
local damping = -12345
local spring = Spring(state, speed, damping)
```

La amortiguación siempre tiene que ser entre 0 y infinito para que un spring 
sea físicamente simulable.

-----

## `invalidSpringSpeed`

```
The speed of a spring must be >= 0. (speed was -2.00)
```

Este mensaje aparece si estás intentando proporcionar una velocidad a un 
[spring](../spring) que sea menor que 0:

```Lua
local speed = -12345
local spring = Spring(state, speed)
```

Ya que una velocidad de 0 es equivalente a un spring que no se mueve, cualquier 
velocidad menor no es simulable o físicamente sensible.

-----

## `mistypedSpringDamping`

```
The damping ratio for a spring must be a number. (got a boolean)
```

Este mensaje aparece si estás intentando proporcionar una amortiguación a un 
[spring](../spring) que no sea un número:

```Lua
local speed = 10
local damping = true
local spring = Spring(state, speed, damping)
```

-----

## `mistypedSpringSpeed`

```
The speed of a spring must be a number. (got a boolean)
```

Este mensaje aparece si estás intentando proporcionar una velocidad a un 
[spring](../spring) que no sea un número:

```Lua
local speed = true
local spring = Spring(state, speed)
```

-----

## `pairsDestructorError`

```
ComputedPairs destructor error: attempt to index a nil value
```

Este mensaje aparece cuando el callback `destructor` de un [ComputedPairs object](../computedpairs) 
encuentra un error:

```Lua
local example = ComputedPairs(
	data,
	processor,
	function(value)
		local badMath = 2 + "pez"
	end
)
```

-----

## `pairsProcessorError`

```
ComputedPairs callback error: attempt to index a nil value
```

Este mensaje aparece cuando el callback `processor` de un [ComputedPairs object](../computedpairs) 
encuentra un error:

```Lua
local example = ComputedPairs(data, function(key, value)
	local badMath = 2 + "pez"
end)
```

-----

## `springTypeMismatch`

```
The type 'number' doesn't match the spring's type 'Color3'.
```

Algunos métodos en objetos de [spring](../spring) requieren valores entrantes para 
emparejar los tipos que fueron usados previamente en el spring.

Este mensaje aparece cuando un valor entrante no tiene el mismo tipo que los valores 
usados previamente en el spring:

```Lua
local colour = State(Color3.new(1, 0, 0))
local colourSpring = Spring(colour)

colourSpring:addVelocity(Vector2.new(2, 3))
```

-----

## `strictReadError`

```
'Foo' is not a valid member of 'Bar'.
```

En Fusion, algunas tablas pueden tener reglas de lectura estrictas (strict). Esto 
es comúnmente usado en APIs públicas como defensa de errores de escritura.

Este mensaje aparece cuando se intenta leer un miembro no existente de estas tablas.

-----

## `unknownMessage`

```
Unknown error: attempt to index a nil value
```

Si ves este mensaje, es casi seguro que sea un bug interno, así que asegúrate de 
ponerte en contacto para que el error pueda ser arreglado.

Cuando el código de Fusion intenta registrar un mensaje, advertencia o error, 
necesita proporcionar un ID. Este ID es usado para mostrar el mensaje correcto, 
y funciona como un identificador simple y memorable por si necesitas buscar el 
mensaje después. Sin embargo, si ese código no proporciona un ID válido, entonces 
el mensaje será reemplazado con este.

-----

## `unrecognisedChildType`

```
'number' type children aren't accepted as children in `New`.
```

Este mensaje aparece cuando se intenta pasar algo como un child que no es una 
instancia, tabla de instancias, o state object que contenga una instancia (cuando 
se usa la función [New](../new.md)):

```Lua
local instance = New "Folder" {
	[Children] = {
		1, 2, 3, 4, 5,

		{true, false},

		State(Enum.Material.Grass)
	}
}
```

!!! note
	Ten en cuenta que los state objects pueden guardar `nil` para representar 
	la ausencia de una instancia, como excepción a estas reglas.

-----

## `unrecognisedPropertyKey`

```
'number' keys aren't accepted in the property table of `New`.
```

Cuando creas una instancia en Fusion usando [New](../new), puedes pasar una 
'property table' que contenga propiedades, children, handlers de cambio de 
propiedad y eventos, etc.

Esta tabla solo se espera que contenga keys de dos tipos:

- string keys, ej. `#!Lua Name = "Ejemplo"`
- unas cuantas keys de símbolos, ej. `#!Lua [OnEvent "Foo"] = ...`

Este mensaje aparece si Fusion encuentra una key de un tipo diferente, o si 
la key no es una de las keys de símbolos usadas en New:

```Lua
local folder = New "Folder" {
	[Vector3.new()] = "Ejemplo",

	"Esto", "No deberia", "Estar", "Aquí"
}
```

!!! quote "Última Actualización de la Localización 10/10/2021"
