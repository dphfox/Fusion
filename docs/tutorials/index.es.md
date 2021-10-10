¡Bienvenido a la sección de tutoriales de Fusion! Aqui, aprenderas cómo construir 
grandes interfaces con Fusion, aún si eres un completo novato en la biblioteca.

!!! warning "Beta Temprana"
	Fusion es actualmente un proyecto en curso. Hay muchas funciones que no 
	funcionan, no están implementadas, no están documentadas por completo o 
	tal vez serán modificadas o eliminadas. No recomendamos usar Fusion para 
	ningún proyecto importante por ahora a menos que estés dispuesto a 
	hacer más trabajo en seguir los cambios.

	Versiones más estables y mantenidas a largo plazo de Fusion estarán disponibles 
	una vez Fusion pase la fase beta.

-----


## Lo Que Debes Saber

Estos tutoriales asumen que:

- Estás cómodo con Roblox y el lenguaje de programación Luau.
	- ¡Estos tutoriales no son una introducción para programar! Si deseas aprender, 
	mira el [Roblox DevHub](https://developer.roblox.com/).
- Eres familiar en cómo funciona la UI en Roblox.
    - No tienes que ser un diseñador - conocer sobre instancias, eventos 
	y tipos de datos de UI como `UDim2` y `Color3` será suficiente.

Por supuesto, basado en tus conocimientos previos, encontrarás algunos tutoriales 
más fáciles o difíciles. Fusion está construido para ser fácil de aprender, pero aún así 
puede tomar un poco de tiempo aprender algunos conceptos, así que no te desalientes :smile:

-----

## Cómo Funcionan Estos Tutoriales

Puedes encontrar los tutoriales en la barra de navegación a tu izquierda. Los 
tutoriales son agrupados por categoría, y son diseñados para explorar 
características específicas de Fusion:

- *'Fundamentos'* presenta las ideas centrales de Fusion - creando instancias, guardando 
estados y respondiendo a eventos.
- *'Otros Fundamentos'* se desarrolla en esas ideas centrales, agregando herramientas 
útiles para construir UIs más complejas.
- *'Animación'* demuestra cómo agregar tweens, transiciones y físicas de springs para 
darle vida a tu UI.

Puedes hacerlos en orden (recomendado para novatos), o puedes dirigirte a 
un tutorial en especifico para dar un repaso rápido.

También verás 'proyectos', el cual combina conceptos de tutoriales anteriores y 
muestra cómo pueden interactuar y trabajar juntos en un entorno real.

-----

En el comienzo de cada tutorial, verás una sección titulada 'Código necesario'. 
Se ven así - puedes presionarlos para expandirlos:

??? abstract "Código necesario"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	print("¡Esto es un ejemplo!")
	```

Antes de comenzar cada tutorial, asegúrate de copiar el código en tu editor de 
codigo, para que puedas seguirlo adecuadamente.

-----

De manera similar, encontraras código finalizado del tutorial al final, dentro 
de 'Código finalizado':

??? abstract "Código finalizado"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	print("¡Esto es un ejemplo!")
	print("Supón que agregamos código aquí durante el tutorial...")
	```

Puedes usar el código finalizado como una referencia si te quedas bloqueado - 
contendrá el código como si ya hubiera pasado todos los pasos del tutorial.

-----

## Instalando Fusion

Fusion es distribuido como un solo `ModuleScript`. Antes de comenzar, necesitarás 
agregar este module script a tu juego. Aquí te decimos cómo:

### Fusion para Roblox Studio

Si programas en Roblox Studio, aquí te decimos como instalar Fusion:

!!! example "Pasos"
	1. Dirigete a la [página de  'Releases' de Fusion](https://github.com/Elttob/Fusion/releases).
	Ahí, podrás encontrar la última versión de Fusion.
	2. Debajo de 'Assets', presiona en el archivo `.rbxm` para descargarlo. Este contiene 
	el module script de Fusion.
	3. En Roblox Studio, abre o crea un place.
	4. Da clic derecho en ReplicatedStorage, y selecciona 'Insert from File'.
	5. Encuentra el `.rbxm` que descargaste, y seleccionalo.

	Ahora deberías ver un ModuleScript llamado 'Fusion' dentro de ReplicatedStorage - ¡estás listo para comenzar!


### Fusion para Editores Externos

Si usas un editor externo para programar, y los sincronizas a Roblox usando un 
plugin, aquí te decimos como instalar Fusion:

??? example "Pasos (presiona para expandir)"
	1. Dirigete a la [página de  'Releases' de Fusion](https://github.com/Elttob/Fusion/releases). 
	Ahí, podrás encontrar la última versión de Fusion.
	2.Debajo de 'Assets', presiona en el archivo `.zip` para descargarlo. Dentro 
	de este se encuentra una copia del repositorio de GitHub de Fusion.
	3. Dentro del zip, copia la carpeta `src` - puede que esté dentro de otra 
	carpeta.
	4. Pega `src` dentro de tu proyecto local, preferiblemente en tu carpeta 
	`shared`, si tienes una.
	5. Renombra la carpeta de `src` a `Fusion`.

	Una vez esté instalado, deberías ver Fusion aparecer en Studio cuando sincronices 
	tu proyecto.

-----

## Configurando Un Script De Prueba

Ahora que ya has instalado Fusion, puedes configurar un local script para probar. 
Aquí te decimos cómo:

1. Crea un `LocalScript` en un servicio como `StarterGui` o `StarterPlayerScripts`.
2. Elimina el código predeterminado, y pega el siguiente código:

```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
```

!!! note
	Este código asume que ya has instalado Fusion dentro de ReplicatedStorage. 
	Si has instalado Fusion en otra parte, necesitarás ajustar el `require()` 
	para dirigirse a la ubicación correcta.

Si todo se ha configurado correctamente, puedes presionar 'Play' y todo debería 
ejecutarse sin errores.

??? fail "Mi script no funciona  - errores comunes"
	```
	Fusion is not a valid member of ReplicatedStorage "ReplicatedStorage"
	```

	Si estás viendo este error, entonces tu script no puede encontrar a Fusion. 
	Vuelce a consultar [la sección anterior](#instalando-fusion) y verifica de nuevo que 
	has configurado todo adecuadamente.

	Si estás usando la guia de instalacion anterior, tu `ReplicatedStorage` 
	debería verse algo así:

	![Pantallazo del Explorer](index/ReplicatedStorage-Fusion.png)

!!! quote "Última Actualización de la Localización 25/09/2021"
