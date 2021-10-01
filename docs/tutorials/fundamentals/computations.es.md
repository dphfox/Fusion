Usualmente, no usamos state tal cual en nuestra UI; normalmente primero la procesamos. 
Aprendamos cómo realizar cómputos en nuestro state. 

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local numPlayers = State(5)
	```

-----

## El Problema de Cómputo

En desarrollo de UI, muchos valores son computados basados en otros valores. 
Por ejemplo, puedes computar un mensaje basado en el número de jugadores en línea:

```Lua
local numPlayers = 5
local message = "Hay " .. numPlayers .. " jugadores en línea."
```

Sin embargo, hay un problema - cuando `numPlayers` cambia, tenemos que manualmente 
recalcular el valor `message` por nosotros mismos. Si no lo haces, entonces el 
mensaje mostrará el valor incorrecto de jugadores - un problema conocido como 
'data desynchronisation'.

-----

## Objetos Computados

Para resolver este problema, Fusion introduce un segundo tipo de objeto - 
*'computed objects'*. En vez de guardar un valor arreglado, ejecutan un cálculo. 
Piénsalo como una hoja de cálculo, en la cual puedes escribir una ecuación que 
usa otros valores.

Para usar computed objects, primero necesitamos importar el constructor `Computed`:

```Lua linenums="1" hl_lines="5"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
local Computed = Fusion.Computed
```

Ahora, podemos crear un computed object llamando al constructor. Pasamos nuestro 
cómputo como una función:

```Lua linenums="7" hl_lines="2-4"
local numPlayers = State(5)
local message = Computed(function()
	return "Hay " .. numPlayers:get() .. " jugadores en línea."
end)
```

En cualquier momento, puedes conseguir el computed value con el método `:get()`:

=== "Lua"
	```Lua linenums="7" hl_lines="6"
	local numPlayers = State(5)
	local message = Computed(function()
		return "Hay " .. numPlayers:get() .. " jugadores en línea."
	end)

	print(message:get())
	```
=== "Output esperado"
	``` hl_lines="1"
	Hay 5 jugadores en línea.
	```

Ahora para la magia - cuando sea que uses un state object como parte de tu cómputo, 
el computed object se actualizará cuando el state object cambie:

=== "Lua"
	```Lua linenums="7" hl_lines="8-9"
	local numPlayers = State(5)
	local message = Computed(function()
		return "Hay " .. numPlayers:get() .. " jugadores en línea."
	end)

	print(message:get())

	numPlayers:set(12)
	print(message:get())
	```
=== "Output esperado"
	``` hl_lines="2"
	Hay 5 jugadores en línea.
	Hay 12 jugadores en línea.
	```

Esto resuelve nuestro problema anterior 'data desynchronisation' - no tenemos 
que recalcular manualmente el mensaje. En cambio, Fusion lo controla por nosotros, 
porque estamos guardando nuestro state en los objetos de Fusion.

Esta es la idea básica de computed objects; te permiten naturalmente definir valores 
en términos de otros valores.

!!! danger "Peligro - Yielding"
	El código que esté dentro de un computed callback nunca se debería yieldiar. 
	Mientras actualmente Fusion no muestra un error por esto, hay planes para cambiarlo.

	Yielding en un callback puede romper mucho código de Fusion, lo cual depende de las 
	actualizaciones a tus variables en ser instantáneas, por ejemplo manejo de dependencias. 
	También puede dirigirse a código inconsistente internamente.

	Si necesitas realizar un llamado web cuando algún state cambia, considera usar 
	`Compat(state):onChange()` para vincular un listener, el cual *es* permitido de 
	yildearse, y guardar el resultado del llamado web en un state object para usarlo en cualquier lugar:

	```Lua
	local playerID = State(1670764)

	-- mal - ¡esto se romperá!
	local playerData = Computed(function()
		return ReplicatedStorage.GetPlayerData:InvokeServer(playerID:get())
	end)

	-- mejor - esto mueve el yielding fuera de cualquier state object de manera segura
	-- asegurate de cargar los datos por primera vez si es importante
	local playerData = State(nil)
	Compat(playerData):onChange(function()
		playerData:set(ReplicatedStorage.GetPlayerData:InvokeServer(playerID:get()))
	end)
	```

	En el futuro, hay planes de hacer el yielding del código más fácil de trabajar. 
	[Mira este issue por más detalles.](https://github.com/Elttob/Fusion/issues/4)

!!! danger "Peligro - Usar non-state objects"
	Aférrate a usar state objects y computed objects dentro de tus cómputos. Fusion puede 
	detectar cuando usas estos objetos y escuchar cambios.

	Fusion *no puede* automáticamente detectar cambios cuando usas variables 'normales':

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

	Esto también aplica a cualquier función que pueden cambiarse por sí mismas, 
	como `os.clock()`. Si necesitas usarlas, guarda valores de la función en un 
	state object, y actualiza el valor de ese objeto tantas veces como 
	sea necesario.

-----

Ahora, hemos cubierto todo lo que necesitamos saber acerca de las herramientas 
básicas de state en Fusion. Usando computed objects y state objects juntos, puedes 
guardar y calcular valores fácilmente mientras evitas bugs de desincronización 
de datos.

??? summary "Código finalizado"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numPlayers = State(5)
	local message = Computed(function()
		return "Hay " .. numPlayers:get() .. " jugadores en línea."
	end)

	print(message:get())

	numPlayers:set(12)
	print(message:get())
	```

!!! quote "Última Actualización de la Localización 30/09/2021"
