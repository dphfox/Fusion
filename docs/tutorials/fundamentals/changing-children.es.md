!!! warning "En construcción"
	Esta página está en construcción - la información puede faltar o estar incompleta.


-----

## Pasando State a Children

!!! note "Incompleto"
	Esta sección está incompleta - puede que se necesite agregar más detalle en el futuro.

Anteriormente, encontramos que podíamos pasar state como propiedades para vincularlas:

```Lua
local message = State("Hola")

local gui = New "TextLabel" {
	Text = message
}

message:set("Mundo") -- establece Text como Mundo
```

El mismo principio funciona con `[Children]` - puedes pasarlo en un state object que 
contenga cualquier children que desees agregar, y se vincularan de manera similar:

```Lua
local child = State(New "Folder" {})

local gui = New "TextLabel" {
	[Children] = child
}

child:set(New "ScreenGui") -- cambia el child de la carpeta al screen gui

```

```Lua
local child1 = New "Folder" {}
local child2 = New "Folder" {}
local child3 = New "Folder" {}

local children = State({child1, child2})

local gui = New "TextLabel" {
	[Children] = child
}

children:set({child2, child3}) -- remueve el parent del child1, y le asigna el parent al child2

```

Date cuenta de que cuando un child se remueve de esta manera, solo pierde el parent, no se 
destruye. Asegúrate de destruir cualquier instancia que elimines si no estás utilizando un 
ayudante como ComputedPairs.

-----

## Actualizaciones Pospuestas

!!! note "Incompleto"
	Esta sección está incompleta - puede que se necesite agregar más detalle en el futuro.

Los cambios para vincular children están pospuestos hasta el siguiente render step, 
al igual que cambios para vincular propiedades.

!!! quote "Última Actualización de la Localización 26/09/2021"
