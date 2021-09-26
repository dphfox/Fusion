Nuestros UIs usan unos cuantos datos - llamados 'state' - para cambiar como aparecen. 
Aprendamos a guardar estos datos en Fusion.

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```

-----

## ¿Qué es State?

State es (simplificando) las variables que determinan como tu UI se ve en un cierto 
punto del tiempo.

Un simple ejemplo de esto es una barra de vida. Para saber como la barra de vida 
se ve en cualquier cierto punto del tiempo, necesitamos saber dos cosas:

- la vida actual a mostrar
- el máximo de vida del jugador

Por lo tanto, estas dos variables son conocidas como el 'state' de la barra de vida. 
Para mostrar la barra de vida en pantalla, necesitamos usar los valores de estas variables.

-----

## Guardando State

Fusion proporciona algunas herramientas buenas para manipular state y usarlo en 
nuestro UI; pero para usar esas herramientas necesitamos guardar nuestro state 
en 'state objects' - objetos simples que guardan un solo valor usando OOP.

Para usar state objects, primero tenemos que importar el constructor `State`:

```Lua linenums="1" hl_lines="4"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
```

Ahora, podemos crear un state object llamando al constructor. Si pasas un valor, 
este será guardado dentro del state object:

```Lua linenums="1" hl_lines="6"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State

local message = State("Hola")
```

En cualquier momento puedes obtener el valor actualmente guardado con el método `:get()`:

=== "Lua"
	```Lua linenums="1" hl_lines="7"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hola")
	print("El valor es:", message:get())
	```
=== "Output esperado"
	``` hl_lines="1"
	El valor es: Hola
	```

También puedes establecer el valor llamando `:set()` con un nuevo valor:

=== "Lua"
	```Lua linenums="1" hl_lines="9-10"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hola")
	print("El valor es:", message:get())

	message:set("Mundo")
	print("El nuevo valor es:", message:get())
	```
=== "Output esperado"
	``` hl_lines="2"
	El valor es: Hola
	El nuevo valor es: Mundo
	```

-----

Con eso, deberías tener una idea básica de state objects - son algo como variables, 
pero en forma de objeto. Estos objetos posteriormente actuarán como 'inputs' hacia 
otras herramientas de manejo de state en Fusion.

??? summary "Código finalizado"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hola")
	print("El valor es:", message:get())

	message:set("Mundo")
	print("El nuevo valor es:", message:get())
	```

!!! quote "Última Actualización de la Localización 26/09/2021"
