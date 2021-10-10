```Lua
function ComputedPairs(
	inputTable: StateOrValue<{[any]: any}>,
	processor: (key: any, value: any) -> any,
	destructor: ((any) -> any)?
): Computed
```

Construye y regresa un nuevo computed object, lo que genera una tabla procesando 
valores de otra tabla.

La tabla ingresada puede ser pasada directamente, o dentro de un state object o 
computed object.

La tabla generada tendrá todas las keys de la tabla ingresada, pero todos los 
valores serán pasados mediante la función `processor`.

Cuando los valores son eliminados de la tabla generada, pueden ser pasados 
opcionalmente mediante una función `destructor`. Esto permite que puedas limpiar 
algunos tipos adecuadamente como instancias - [más detalles pueden ser encontrados en el 
tutorial.](../../../tutorials/further-basics/arrays-and-lists)

-----

## Parámetros

- `inputTable: StateOrValue<{[any]: any}>` - una tabla, o state object que contiene 
una tabla, que será procesado por este ComputedPairs
- `processor: (key: any, value: any) -> any` - valores de la tabla ingresada serán 
pasados mediante esta función y colocados en la tabla regresada por este objeto
- `destructor: ((any) -> any)?` - cuando un valor es eliminado de la tabla generada, 
será pasado a esta función para su limpieza. Si no se proporciona, se establece por 
defecto a una función de limpieza como Maid.

-----

## Métodos del Objeto

### `get()`

```Lua
function ComputedPairs:get(): any
```
Regresa el valor almacenado de este computed object, el cual será la tabla generada 
de key/value pairs.

Si las dependencias actualmente están siendo detectadas (ej. dentro de un computed 
callback), entonces este computed object será usado como una dependencia.

-----

## Ejemplo de Uso

```Lua
local playerList = State({
	"AxisAngles",
	"boatbomber",
	"Elttob",
	"grilme99",
	"Phalanxia",
	"Reselim",
	"thisfall"
})

local textLabels = ComputedPairs(playerList, function(key, value)
	return New "TextLabel" {
		Text = value
	}
end)
```

-----

!!! quote "Última Actualización de la Localización 10/10/2021"
