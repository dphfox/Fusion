```Lua
function Compat(watchedState: State<any>): Compat
```

Construye y regresa un nuevo compatibility object, el cual escuchará eventos en 
el objeto `watchedState` dado.

Compat está designado como una API para integrar Fusion con otro código que no 
es de Fusion. Algunos usos como ejemplo incluyen sincronizar colores del tema a UIs que no 
son de Fusion, o guardar state objects en data stores cuando cambian.

!!! warning
	Solo debes usar `Compat` para lidiar con código que no sea de Fusion.

	Si estás construyendo una interfaz con Fusion, ya existen herramientas reactivas 
	para casi cualquier caso de uso, el cual puede ser optimizado por Fusion y 
	dirigirse a un código más limpio y representativo. Usar `Compat` en estas 
	situaciones no es nada recomendable.

	Cambiar state objects en `:onChange()` es un antipatrón particular que Compat 
	puede incentivar a abusar. Si necesitas actualizar el valor de un state object 
	cuando otro state object cambia, considera usar en cambio [computed state](../computed.md).

	[Para ver más detalles, mira este issue en GitHub.](https://github.com/Elttob/Fusion/issues/8#issuecomment-888109650)

-----

## Parámetros

- `watchedState: State<any>` - un [state object](../state.md), [computed object](../computed.md) 
o otro state object para monitorear.

-----

## Métodos del Objeto

### `onChange()`

```Lua
function Compat:onChange(callback: () -> ()): () -> ()
```
Conecta el callback dado como un controlador de cambio, y regresa una función 
que desconectará el callback.

Cuando el valor de este `watchedState` de Compat cambia, el callback será ejecutado.

!!! danger "Fugas en la memoria de conexión"
	Asegúrate de desconectar cualquier controlador de cambio hecho usando esta 
	función una vez hayas terminado de usarlos.

	Siempre y cuando un controlador de cambio esté conectado, este objeto Compat 
	(y el `watchedState`) será conservado en la memoria, así los cambios pueden ser 
	detectados. Esto significa que, si no llamas la función disconnect, puedes 
	terminar conservando el state object en la memoria accidentalmente después 
	de que lo termines de usar.

-----

## Ejemplo de Uso

```Lua
local numCoins = State(50)

local compat = Compat(numCoins)

local disconnect = numCoins:onChange(function()
	print("coins ahora es:", numCoins:get())
end)

numCoins:set(25) -- se le hace print a 'coins ahora es: 25'

-- ¡siempre limpia tus conexiones!!
disconnect()
```

-----

!!! quote "Última Actualización de la Localización 10/10/2021"
