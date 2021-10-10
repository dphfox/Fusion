```Lua
function OnEvent(eventName: string): Symbol
```

Genera símbolos usados para denotar controladores de eventos al trabajar con la 
función [New](../new).

Al usar este símbolo como una key en la tabla de propiedades de `New`, se espera 
que el valor sea una función callback, la cual será conectada al evento dado en 
la instancia.

La función se comporta al igual que un controlador de eventos; recibe todo los argumentos 
del evento. La conexión se limpia automáticamente cuando la instancia se destruye.

-----

## Parámetros

- `eventName: string` - el nombre del evento en la instancia

-----

## Ejemplo de Uso

```Lua
local example = New "TextButton" {
	[OnEvent "Activated"] = function(...)
		print("El evento Activated se ejecuta con args:", ...)
	end
}
```

!!! quote "Última Actualización de la Localización 10/10/2021"
