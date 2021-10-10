```Lua
function Tween(goalValue: State<Animatable>, tweenInfo: TweenInfo?): Tween
```

Construye y regresa un nuevo state object de Tween, el cual sigue el valor de 
`goalValue`. Cuando el valor del objetivo cambia, el valor de este objeto es 
interpolado hacia el valor del objetivo usando el `tweenInfo` dado.

-----

## Parámetros

- `goalValue: State<Animatable>` - el valor del objetivo que este objeto debe abordar
- `tweenInfo: TweenInfo?` - el tween usado para animar el valor de este objeto

-----

## Métodos del Objeto

### `get()`

```Lua
function Tween:get(): any
```
Regresa el actual valor guardado de este state object de Tween.

Si las dependencias están siendo detectadas actualmente (ej. dentro de un computed 
callback), entonces este state object será usado como una dependencia.

-----

## Ejemplo de Uso

```Lua
local EASE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local position = State(UDim2.fromScale(0.25, 0.25))
local ui = New "Frame" {
	Position = Tween(position, EASE)
}
```

```Lua
local playerCount = State(0)
local smoothPlayerCount = Tween(playerCount)

local message = Computed(function()
	return "Actualmente en línea: " .. math.floor(smoothPlayerCount:get())
end)
```

-----

!!! quote "Última Actualización de la Localización 10/10/2021"
