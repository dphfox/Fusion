---
title: Referencia del API
---

# Referencia del API

Fusion es una biblioteca reactiva moderna, construida para 
[Roblox](https://developer.roblox.com/) y [Luau](https://luau-lang.org/).<br>
Aquí, puedes encontrar documentación para cada API pública expuesta por el módulo de Fusion.

## Navegación

Usando la barra lateral de la izquierda, puedes encontrar miembros de la API 
agrupados por categoría. Como alternativa puedes buscar las APIs usando la 
barra de búsqueda en la parte superior de la página.

## Información de Tipos

En varias páginas de la API, verás anotaciones de tipos describiendo el miembro 
de la API. Por ejemplo:

```Lua
function New(className: string): (props: {[string | Symbol]: any}) -> Instance
```

Mientras que este tipo de anotaciones son diseñadas para ser como las de Luau, 
estas son básicamente pseudocódigos incluidos para ayudar al desarrollador. 
Para una total precisión y sintaxis, por favor consulta el código fuente directamente.

## Usadas Comúnmente

Dirígete directamente a la documentación para ver algunas APIs comunes:

### Instancias
- [New](api/new)

### Gestión de State
- [State](api/state)
- [Computed](api/computed)
- [ComputedPairs](api/computedpairs)

### Animación
- [Tween](api/tween)
- [Spring](api/tween)

!!! quote "Última Actualización de la Localización 10/10/2021"
