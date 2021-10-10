```Lua
function Spring(goalValue: State<Animatable>, speed: number?, dampingRatio: number?): Spring
```

Construye y regresa un nuevo state object de Spring, el cual sigue el valor de 
`goalValue`. El valor de este objeto es simulado físicamente, como si estuviera 
vinculado al valor del objetivo por un amortiguador.

`speed` actúa como un multiplicador de tiempo, duplicando `speed` corresponde 
a un movimiento que es dos veces más rápido.

`dampingRatio` afecta la fricción; `0` representa que no hay fricción, y `1` es 
solo la suficiente fricción para alcanzar el objetivo sin rebasamiento u 
oscilación. Esto se puede variar libremente para ajustar la cantidad de fricción 
o 'rebote' que tiene el movimiento.

-----

## Parámetros

- `goalValue: State<Animatable>` - el valor del objetivo que este objeto debe abordar
- `speed: number?` - cuán rápido este objeto debe abordar el objetivo
- `dampingRatio: number?` - escala cuánta fricción es aplicada

-----

## Métodos del Objeto

### `get()`

```Lua
function Spring:get(): any
```
Regresa el valor guardado actualmente de este state object de Spring.

Si las dependencias están siendo detectadas actualmente (ej. dentro de un computed 
callback), entonces este state object será usado como una dependencia.

-----

## Ejemplo de Uso

```Lua
local position = State(UDim2.fromScale(0.25, 0.25))

local ui = New "Frame" {
	Position = Spring(position, 25, 0.5)
}
```

```Lua
local playerCount = State(0)
local smoothPlayerCount = Spring(playerCount)

local message = Computed(function()
	return "Actualmente en línea: " .. math.floor(smoothPlayerCount:get())
end)
```

-----

!!! quote "Última Actualización de la Localización 10/10/2021"
