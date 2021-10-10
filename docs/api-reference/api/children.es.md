```Lua
local Children: Symbol
```

El símbolo utilizado para denotar los children de una instancia cuando se trabaja 
con la función [New](../new).

Cuando se usa este símbolo como key en la tabla de propiedades de `New`, los valores 
serán tratados como children, y su parent será establecido de acuerdo a las reglas posteriores.

-----

## Ejemplo de Uso

```Lua
local example = New "Folder" {
	[Children] = New "StringValue" {
		Value = "¡Mi parent es la Folder!"
	}
}
```

-----

## Procesando Children

Un 'child' es definido (recursivamente) como:

- una instancia
- un [state object](../state) o [computed object](../computed) que contenga children
- una array de children

Dado que esta definición es recursiva, arrays y state objects pueden ser anidadas; 
es decir que el siguiente código es válido:

```Lua
local example = New "Folder" {
	[Children] = {
		{
			{
				New "StringValue" {
					Value = "¡Mi parent es la Folder!"
				}
			}
		}
	}
}
```

Este comportamiento es especialmente útil al trabajar con componentes - el siguiente 
componente puede regresar múltiples instancias para establecer sus parents sin 
interrumpir el código junto a él:

```Lua
local function Component(props)
	return {
		New "TextLabel" {
			LayoutOrder = 1,
			Text = "Instancia uno"
		},

		New "TextLabel" {
			LayoutOrder = 2,
			Text = "Instancia dos"
		}
	}
end

local parent = New "Frame" {
	Children = {
		New "UIListLayout" {
			SortOrder = "LayoutOrder"
		},

		Component {}
	}
}
```

Al usar state o computed object como child, se vinculará; cuando el valor del state 
object cambia, se le quitara el parent a los viejos children y se le establecerá 
el parent a los nuevos children.

!!! note
	Al igual que con propiedades bound, las actualizaciones son pospuestas al siguiente 
	render step, por lo que el establecimiento de un parent no ocurrirá al instante.

```Lua
local child1 = New "Folder" {
	Name = "Child uno"
}
local child2 = New "Folder" {
	Name = "Child dos"
}

local childState = State(child1)

local parent = New "Folder" {
	[Children] = childState
}

print(parent:GetChildren()) -- { Child uno }

childState:set(child2)
wait(1) -- espera a que las actualizaciones pospuestas se ejecuten

print(parent:GetChildren()) -- { Child dos }
```

!!! warning
	Al usar state objects, fijate que los children viejos *no serán* destruidos, 
	solo se les quitará el parent - depende de ti decidir cuándo/si los children 
	necesitan ser destruidos.

	Si estás usando un helper como [ComputedPairs](../computedpairs), la limpieza 
	de instancias es controlada por defecto por ti (aunque esto es ajustable).

!!! quote "Última Actualización de la Localización 10/10/2021"
