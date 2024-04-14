<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Errors</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-x-circle-24:</span>
	<span class="fusiondoc-api-name">Errors</span>
</h1>

Whenever Fusion outputs any errors or messages to the console, it will have a
short error ID at the end. This is used to uniquely identify what kind of error
or message you're seeing.

Use the search box below to paste in or type an error ID, and it will scroll to
the details for you.

<input
	id="fusiondoc-error-paste-box"
	class="md-input md-input--stretch"
	placeholder="Type or paste an error ID here..."
/>

<script src="./error-paste-box.js" defer></script>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotAssignProperty

```
The class type 'Foo' has no assignable property 'Bar'.
```

**Thrown by:**
[`New`](../../instances/members/new),
[`Hydrate`](../../instances/members/hydrate)

You tried to set a property on an instance, but the property can't be assigned 
to for some reason. This could be because the property doesn't exist, or because
it's locked by Roblox to prevent edits.

!!! warning "Check your privileges"
	Different scripts may have different privileges - for example, plugins will
	be allowed more privileges than in-game scripts. Make sure you have the
	necessary privileges to assign to your properties!
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotConnectChange

```
The Frame class doesn't have a property called 'Foo'.
```

**Thrown by:**
[`OnChange`](../../instances/members/onchange)

You tried to connect to a property change event, but the property you specify
doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotConnectEvent

```
The Frame class doesn't have an event called 'Foo'.
```

**Thrown by:**
[`OnEvent`](../../instances/members/onevent)

You tried to connect to an event on an instance, but the event you specify
doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## callbackError

```
Error in callback: attempt to perform arithmetic (add) on number and string
```

**Thrown by:**
[`Computed`](../../state/members/computed),
[`ForKeys`](../../state/members/forkeys),
[`ForValues`](../../state/members/forvalues),
[`ForPairs`](../../state/members/forpairs),
[`Contextual`](../../memory/members/contextual)

Fusion ran a function you specified, but the function threw an error that Fusion
couldn't handle.

The error includes a more specific message which can be used to diagnose the
issue.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cleanupWasRenamed

```
`Fusion.cleanup` was renamed to `Fusion.doCleanup`. This will be an error in
future versions of Fusion.
```

**Thrown by:**
[`doCleanup`](../../memory/members/docleanup)

You attempted to use `cleanup()` in Fusion 0.3, which replaces it with the
`doCleanup()` method.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## destroyedTwice

```
Attempted to destroy Computed twice; ensure you're not manually calling
`:destroy()` while using scopes. See discussion #292 on GitHub for advice.
```

**Thrown by:**
[`Value`](../../state/members/value),
[`Computed`](../../state/members/computed),
[`Observer`](../../state/members/observer),
[`ForKeys`](../../state/members/forkeys),
[`ForValues`](../../state/members/forvalues),
[`ForPairs`](../../state/members/forpairs),
[`Spring`](../../animation/members/spring),
[`Tween`](../../animation/members/tween)

**Related discussions:** 
[`#292`](https://github.com/dphfox/Fusion/discussions/292)

The `:destroy()` method of the object in question was called more than once.

This usually means you called `:destroy()` manually, which is almost never
required because Fusion's constructors always link objects to
[scopes](../../../tutorials/fundamentals/scopes). When that scope is passed to 
[`doCleanup()`](../../memory/members/docleanup), the `:destroy()` method is
called on every object inside.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## destructorRedundant

```
Computed destructors no longer do anything. If you wish to run code on destroy,
`table.insert` a function into the `scope` argument. See discussion #292 on
GitHub for advice.
```

**Thrown by:**
[`Computed`](../../state/members/computed),
[`ForKeys`](../../state/members/forkeys),
[`ForValues`](../../state/members/forvalues),
[`ForPairs`](../../state/members/forpairs)

**Related discussions:** 
[`#292`](https://github.com/dphfox/Fusion/discussions/292)

You passed an extra parameter to the constructor, which has historically been
interpreted as a function that runs when a value is cleaned up.

This mechanism has been replaced by
[scopes](../../../tutorials/fundamentals/scopes).
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## forKeyCollision

```
The key '6' was returned multiple times simultaneously, which is not allowed in
`For` objects.
```

**Thrown by:**
[`ForKeys`](../../state/members/forkeys),
[`ForPairs`](../../state/members/forpairs)

When called with different items from the table, the same key was returned for
both of them. This is not allowed, because keys have to be unique in a table.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidChangeHandler

```
The change handler for the 'AbsoluteSize' property must be a function.
```

**Thrown by:**
[`OnChange`](../../instances/members/onchange)

`OnChange` expected you to provide a function for it to run when the property
changes, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidAttributeChangeHandler

```
The change handler for the 'Active' attribute must be a function.
```

**Thrown by:**
[`AttributeChange`](../../instances/members/attributechange)

`AttributeChange` expected you to provide a function for it to run when the
attribute changes, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidEventHandler

```
The handler for the 'MouseEnter' event must be a function.
```

**Thrown by:**
[`OnEvent`](../../instances/members/onevent)

`OnEvent` expected you to provide a function for it to run when the event is
fired, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidPropertyType

```
'Frame.BackgroundColor3' expected a 'Color3' type, but got a 'Vector3' type.
```

**Thrown by:**
[`New`](../../instances/members/new),
[`Hydrate`](../../instances/members/hydrate)

You attempted to assign a value to a Roblox instance's property, but the 
assignment threw an error because that property doesn't accept values of that
type.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidRefType

```
Instance refs must be Value objects.
```

**Thrown by:**
[`Ref`](../../instances/members/ref)

`Ref` expected you to give it a [value](../../state/members/value), but you gave
it something else.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutType

```
[Out] properties must be given Value objects.
```

**Thrown by:**
[`Out`](../../instances/members/out)

`Out` expected you to give it a [value](../../state/members/value), but you gave
it something else.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidAttributeOutType

```
[AttributeOut] properties must be given Value objects.
```

**Thrown by:**
[`AttributeOut`](../../instances/members/attributeout)

`AttributeOut` expected you to give it a [value](../../state/members/value), but
you gave it something else.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutProperty

```
The Frame class doesn't have a property called 'MouseButton1Down'.
```

**Thrown by:**
[`Out`](../../instances/members/out)

The property that you tried to output doesn't exist on the instance that `Out`
was used with.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidSpringDamping

```
The damping ratio for a spring must be >= 0. (damping was -1.00)
```

**Thrown by:**
[`Spring`](../../instances/members/spring)

You provided a damping ratio that the spring doesn't support, for example `NaN`,
or a negative damping implying negative friction.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidSpringSpeed

```
The speed of a spring must be >= 0. (speed was NaN)
```

**Thrown by:**
[`Spring`](../../instances/members/spring)

You provided a speed multiplier that the spring doesn't support, for example
`NaN` or a negative speed implying the spring moves backwards through time.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedSpringDamping

```
The damping ratio for a spring must be a number. (got a string)
```

**Thrown by:**
[`Spring`](../../instances/members/spring)

You provided a damping ratio that the spring couldn't understand. Damping ratio
has to be a number.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedSpringSpeed

```
The speed of a spring must be a number. (got a string)
```

**Thrown by:**
[`Spring`](../../instances/members/spring)

You provided a speed multiplier that the spring couldn't understand. Speed has
to be a number.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedTweenInfo

```
The tween info of a tween must be a TweenInfo. (got a table)
```

**Thrown by:**
[`Tween`](../../instances/members/tween)

You provided an easing curve that the tween couldn't understand. The easing
curve has to be specified using Roblox's `TweenInfo` data type.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mergeConflict

```
Multiple definitions for 'Observer' found while merging.
```

**Thrown by:**
[`scoped`](../../memory/members/scoped)

Fusion tried to merge together multiple tables, but a key was found in more than
one of the tables, and it's unclear which one you intended to have in the final
merged result.

This can happen subtly with methods such as 
[`scoped()`](../../memory/members/scoped) which automatically merge together all
of their arguments.
</div>