```Lua
function Computed(callback: () -> any): Computed
```

Construye y regresa un nuevo computed object, usando el callback dado para calcular 
los valores del objeto basado en otros [state objects](../state) o computed objects.

-----

## Parámetros

- `callback: () -> any` - una función que calcula y regresa el valor a usar para 
este computed object.

-----

## Métodos del Objeto

### `get()`

```Lua
function Computed:get(): any
```
Regresa el valor caché de este computed object, como regresa de la función callback.

Si las dependencias actualmente están siendo detectadas (ej. dentro de un computed 
callback), entonces este computed object será usado como una dependencia.

-----

## Ejemplo de Uso

```Lua
local numCoins = State(50)

local doubleCoins = Computed(function()
	return numCoins:get() * 2
end)

print(doubleCoins:get()) --> 100

numCoins:set(2)
print(doubleCoins:get()) --> 4
```

-----

## Gestión de Dependencias

Los computed objects automáticamente detectan dependencias usadas dentro de su callback 
cada vez que su callback se ejecuta. Esto significa, que al usar una función como 
`:get()` en un state object, este registrará el state object como dependencia:

```Lua
local numCoins = State(50)

local doubleCoins = Computed(function()
	-- Fusion detecta que llamamos :get() en `numCoins`, y por esto agrega `numCoins`
	-- como una dependencia de este computed object.
	return numCoins:get() * 2
end)
```

Cuando una dependencia cambia su valor, el computed object re-ejecuta su callback 
para generar y almacenar el valor actual internamente. Este valor es luego expuesto 
mediante el método `:get()`.

Algo importante es que las dependencias son dinámicas; puedes cambiar los valores de 
los que dependen tus computed objects, y las dependencias serán actualizadas para 
reducir actualizaciones innecesarias:

=== "Lua"
	```Lua
	local stateA = State(5)
	local stateB = State(5)
	local selector = State("A")

	local computed = Computed(function()
		print("> ¡actualizando computed!")
		local selected = selector:get()
		if selected == "A" then
			return stateA:get()
		elseif selected == "B" then
			return stateB:get()
		end
	end)

	print("se ha incrementado el state A (se espera una actualización debajo)")
	stateA:set(stateA:get() + 1)
	print("se ha incrementado el state B (no se espera actualización)")
	stateA:set(stateA:get() + 1)

	print("cambia para seleccionar B")
	selector:set("B")

	print("se ha incrementado el state A (no se espera actualización)")
	stateA:set(stateA:get() + 1)
	print("se ha incrementado el state B (se espera una actualización debajo)")
	stateA:set(stateA:get() + 1)
	```
=== "Output esperado"
	```
	> ¡actualizando computed!
	se ha incrementado el state A (se espera una actualización debajo)
	> ¡actualizando computed!
	se ha incrementado el state B (no se espera actualización)
	cambia para seleccionar B
	> ¡actualizando computed!
	se ha incrementado el state A (no se espera actualización)
	se ha incrementado el state B (se espera una actualización debajo)
	> ¡actualizando computed!
	```

!!! danger
	Aférrate a usar state y computed objects dentro de tus cómputos. Fusion puede 
	detectar cuando usas estos objetos y escucha cuando hay cambios.

	Fusion *no puede* detectar cambios automáticamente cuando usas variables 'normales':

	```Lua
	local theVariable = "Hola"
	local badValue = Computed(function()
		-- ¡no hagas esto! usa state o computed objects aqui
		return "Di " .. theVariable
	end)

	print(badValue:get()) -- printea 'Di Hola'

	theVariable = "Mundo"
	print(badValue:get()) -- aún printea 'Di Hola' - ¡eso es un problema!
	```

	Usando un state object aqui, Fusion puede actualizar el computed object 
	correctamente, porque sabe que usamos el state object:

	```Lua
	local theVariable = State("Hola")
	local goodValue = Computed(function()
		-- esto es mucho mejor - ¡Fusion puede detectar que usamos el state object!
		return "Di " .. theVariable:get()
	end)

	print(goodValue:get()) -- printea 'Di Hola'

	theVariable:set("Mundo")
	print(goodValue:get()) -- printea 'Di Mundo'
	```

	Esto también aplica a cualquier función que pueda cambiarse por sí misma, 
	como `os.clock()`. Si necesitas usarlas, guarda valores de la función en un 
	state object, y actualiza el valor de ese objeto tantas veces como 
	sea necesario.

!!! quote "Última Actualización de la Localización 10/10/2021"
