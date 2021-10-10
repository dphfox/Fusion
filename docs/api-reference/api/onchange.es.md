```Lua
function OnChange(propertyName: string): Symbol
```

Genera símbolos usados para denotar controladores de cambio de propiedades al trabajar 
con la función [New](../new).

Al usar este símbolo como una key en la tabla de propiedades de `New`, se espera 
que el valor sea una función callback. El callback será conectado al evento 
`GetPropertyChangedSignal` de las propiedades en la instancia.

Unlike normal property change handlers, the new value is passed in as an
argument to the callback for convenience.

!!! warning "Usando OnChange con el bound state"
	Al pasar un [state object](../state) o [computed object](../computed) como 
	una propiedad, los cambios en el state solo afectarán a la propiedad en el siguiente 
	render step (un concepto conocido como 'deferred updating').

	Debido a que `OnChange` se conecta a `GetPropertyChangedSignal`, es posible 
	que se presenten errores off-by-one (por un paso) de un fotograma si dependes 
	de `OnChange` para mantener otras cosas sincronizadas con la propiedad. En 
	cambio opta por conectarse al state del evento `onChange`.

-----

## Parámetros

- `propertyName: string` - la propiedad que monitorea por si hay cambios en la instancia

-----

## Ejemplo de Uso

```Lua
local example = New "TextBox" {
	[OnChange "Text"] = function(newText)
		print("Escribiste:", newText)
	end
}
```

!!! quote "Última Actualización de la Localización 10/10/2021"
