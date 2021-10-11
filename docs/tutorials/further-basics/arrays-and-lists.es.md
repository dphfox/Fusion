Trabajar eficientemente con tablas puede ser difícil. Aprendamos acerca de las 
herramientas que Fusion proporciona para que trabajar con arrays y tablas sea más fácil.

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numbers = State({1, 2, 3, 4, 5})
	```

-----

## Computed Arrays

Supón que tenemos un state object que guarda una array de números, y queremos crear 
un computed object el cual duplique cada número. Podemos lograr esto usando un loop 
for-pairs:

```Lua linenums="7" hl_lines="3-9"
local numbers = State({1, 2, 3, 4, 5})

local doubledNumbers = Computed(function()
	local doubled = {}
	for index, number in pairs(numbers:get()) do
		doubled[index] = number * 2
	end
	return doubled
end)

print(doubledNumbers:get()) --> {2, 4, 6, 8, 10}
```

Aunque esto funciona, es muy verboso. Para hacer este código más simple, Fusion tiene 
un computed object especial diseñado para procesar tablas, conocido como `ComputedPairs`.

Para usarlo, tenemos que importar `ComputedPairs` desde Fusion:

```Lua linenums="1" hl_lines="7"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
local Computed = Fusion.Computed
local ComputedPairs = Fusion.ComputedPairs
```

`ComputedPairs` actúa de manera similar a el loop for-pairs que escribimos arriba - este 
va por cada entrada de la array, procesa el valor, y lo guarda dentro de la nueva array:

```Lua linenums="8" hl_lines="3-5"
local numbers = State({1, 2, 3, 4, 5})

local doubledNumbers = ComputedPairs(numbers, function(index, number)
	return number *  2
end)

print(doubledNumbers:get()) --> {2, 4, 6, 8, 10}
```

Esto puede ser usado para procesar cualquier tipo de tabla, no solo arrays. Observa que 
las keys son las mismas, y el valor es lo que sea que tu regreses:

```Lua linenums="8"
local data = State({Blue = "bueno", Green = "malo"})

local processedData = ComputedPairs(data, function(colour, word)
	return colour .. " es " .. word
end)

print(processedData:get()) --> {Blue = "Blue es bueno", Green = "Green es malo"}
```

-----

## Limpiando Valores

A veces, podrías usar `ComputedPairs` para generar listas de instancias, o otro 
tipo de datos parecido. Cuando acabemos con estos, necesitamos destruirlos.

Convenientemente, `ComputedPairs` ya limpia algunos tipos cuando son eliminados 
de la array generada:

- instancias regresadas serán destruidas
- conexiones a eventos regresadas serán destruidas
- funciones regresadas serán ejecutadas
- objetos regresados tendrán sus métodos `:Destroy()` o `:destroy()` ejecutados
-array regresadas tendrán su contenido limpio

Esto debería cubrir la mayoría de usos por defecto. Sin embargo, si necesitas anular 
este comportamiento de limpieza, puedes pasar una función opcional `destructor` como 
un segundo argumento. Cuando el valor generado es eliminado o anulado, será ejecutado 
para que lo puedas limpiar:

=== "Lua"
	```Lua linenums="8" hl_lines="8-10"
	local names = State({"John", "Dave", "Sebastian"})

	local greetings = ComputedPairs(
		names,
		function(index, name)
			return "Hola, " .. name
		end,
		function(greeting)
			print("Eliminado: " .. greeting)
		end
	)

	names:set({"John", "Trey", "Charlie"})
	```
=== "Output esperado"
	```
	Eliminado: Hola, Dave
	Eliminado: Hola, Sebastian
	```

-----

## Optimización

Para mejorar el rendimiento, `ComputedPairs` no recalcula una key si su valor sigue igual:

=== "Lua"
	```Lua linenums="8"
	local data = State({
		One = 1,
		Two = 2,
		Three = 3
	})

	print("Creando processedData...")

	local processedData = ComputedPairs(data, function(key, value)
		print("  ...recalculando key: " .. key)
		return value * 2
	end)

	print("Cambiando los valores de algunas keys...")
	data:set({
		One = 1,
		Two = 100,
		Three = 3,
		Four = 4
	})
	```
=== "Output esperado"
	```
	Creando processedData...
	  ...recalculando key: One
	  ...recalculando key: Two
	  ...recalculando key: Three
	Cambiando los valores de algunas keys...
	  ...recalculando key: Two
	  ...recalculando key: Four
	```

Debido a que las keys `Two` y `Four` tienen diferentes valores después del cambio, 
son recalculadas. Sin embargo, `One` y `Three` tienen los mismos valores, así que 
se reutilizarán en su lugar:

![Diagrama que muestra cómo las keys se almacenan en el caché](OptimisedKeyValues.png)

Esto es una simple regla que debería funcionar adecuadamente para las tablas con 
'stable keys' (keys que no cambian cuando otros valores son agregados o eliminados).

Sin embargo, si estás trabajando con 'keys inestables' (ej. una array en la cual los 
valores se pueden mover a diferentes keys) puedes obtener recálculos innecesarios. 
En el siguiente código, `Yellow` es recalculado, porque se mueve a una key diferente:

=== "Lua"
	```Lua linenums="8"
	local data = State({"Red", "Green", "Blue", "Yellow"})

	print("Creando processedData...")

	local processedData = ComputedPairs(data, function(key, value)
		print("  ...recalculando key: " .. key .. " valor: " .. value)
		return value
	end)

	print("Eliminando Blue...")
	data:set({"Red", "Green", "Yellow"})
	```
=== "Output esperado"
	```
	Creando processedData...
	  ...recalculando key: 1 valor: Red
	  ...recalculando key: 2 valor: Green
	  ...recalculando key: 3 valor: Blue
	  ...recalculando key: 4 valor: Yellow
	Moving the values around...
	  ...recalculando key: 3 valor: Yellow
	```

Puedes ver esto más claramente en el siguiente diagrama - el valor de la key 3 
ha cambiado, así que provocó una recalculación:

![Diagrama que muestra las keys inestables](UnstableKeys.png)

Si las keys no se necesitan, puedes usar tus valores como keys. Esto las hace 
estables, ya que no serán afectadas por otras inserciones o extracciones:

=== "Lua"
	```Lua linenums="8" hl_lines="1 5-8 11"
	local data = State({Red = true, Green = true, Blue = true, Yellow = true})

	print("Creando processedData...")

	local processedData = ComputedPairs(data, function(key)
		print("  ...recalculando key: " .. key)
		return key
	end)

	print("Eliminando Blue...")
	data:set({Red = true, Green = true, Yellow = true})
	```
=== "Output esperado"
	```
	Creando processedData...
	  ...recalculando key: Red
	  ...recalculando key: Green
	  ...recalculando key: Blue
	  ...recalculando key: Yellow
	Eliminando Blue...
	```

Fijate que, cuando eliminamos `Blue`, ningún otro valor es recalculado. Esto es 
ideal, y significa que no estamos haciendo procesos innecesarios:

![Diagrama que muestra las keys estables](StableKeys.png)

Esto es especialmente importante al optimizar arrays ‘pesadas’, por ejemplo largas 
listas de instancias. ¡Entre menos recálculo innecesario, mejor!

-----

Con esto, deberías tener una idea básica de como trabajar con state de tablas en 
Fusion. Cuando te acostumbres a este flujo de trabajo, puedes expresar tu lógica 
hábilmente, y tener un buen comportamiento de almacenamiento de caché y limpieza 
gratuitamente.

??? abstract "Código finalizado"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State
	local Computed = Fusion.Computed
	local ComputedPairs = Fusion.ComputedPairs

	local data = State({Red = true, Green = true, Blue = true, Yellow = true})

	print("Creando processedData...")

	local processedData = ComputedPairs(data, function(key)
		print("  ...recalculando key: " .. key)
		return key
	end)

	print("Eliminando Blue...")
	data:set({Red = true, Green = true, Yellow = true})
	```

-----

!!! quote "Última Actualización de la Localización 10/10/2021"
