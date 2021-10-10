```Lua
function State(initialValue: any?): State
```

Construye y regresa un nuevo state object con un valor inicial opcional.

-----

## Parámetros

- `initialValue: any?` - el valor que inicialmente debería ser guardado en el 
state object.

-----

## Métodos del Objeto

### `get()`

```Lua
function State:get(): any
```
Regresa el valor actualmente guardado de este state object.

Si las dependencias actualmente están siendo detectadas (ej. dentro de un computed 
callback), entonces este state object será usado como una dependencia.

### `set()`

```Lua
function State:set(newValue: any, force: boolean?)
```
Establece el nuevo valor de este state object.

Si los nuevos y antiguos valores son distintos, esto actualizará otros objetos 
que usen este state object. Sin embargo, si son los mismos, no se realizará  
la actualización.

!!! tip "Forzar actualización"
	Si quieres anular este comportamiento, puedes establecer `force` a `true`. 
	Esto se asegurará que las actualizaciones siempre sean realizadas, aún 
	si los nuevos y antiguos valores son iguales (medido por el operador ==). 
	Esto es más útil al trabajar con tablas mutables.

	Sin embargo, ten mucho cuidado con esto y solo fuerza actualizaciones cuando 
	lo necesites, por razones de rendimiento. Prueba primero una solución que 
	involucre tablas inmutables. El abuso de forzar actualizaciones puede 
	llevar a código no óptimo que se actualiza redundantemente.

-----

## Ejemplo de Uso

```Lua
local numCoins = State(50)

print(numCoins:get()) --> 50

numCoins:set(25)
print(numCoins:get()) --> 25

numCoins.onChange:Connect(function()
	print("Coins ha cambiado a:", numCoins:get())
end)
```

!!! quote "Última Actualización de la Localización 10/10/2021"
