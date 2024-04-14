<nav class="fusiondoc-api-breadcrumbs">
	<span>Animation</span>
	<span>Types</span>
	<span>Animatable</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Animatable</span>
</h1>

```Lua
export type Animatable =
	number |
	CFrame |
	Color3 |
	ColorSequenceKeypoint |
	DateTime |
	NumberRange |
	NumberSequenceKeypoint |
	PhysicalProperties |
	Ray |
	Rect |
	Region3 |
	Region3int16 |
	UDim |
	UDim2 |
	Vector2 |
	Vector2int16 |
	Vector3 |
	Vector3int16
```

Any data type that Fusion can decompose into a tuple of animatable parameters.

!!! note "Passing other types to animation objects"
	Other types can be passed to `Tween` and `Spring` objects, however those
	types will not animate. Instead, non-`Animatable` types will immediately
	arrive at their goal value.

-----

## Learn More

- [Tweens tutorial](../../../../tutorials/animation/tweens)
- [Springs tutorial](../../../../tutorials/animation/springs)