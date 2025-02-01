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

<script src="../../../assets/scripts/error-paste-box.js" defer></script>

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
[`Contextual`](../../general/members/contextual)

Fusion ran a function you specified, but the function threw an error that Fusion
couldn't handle.

The error includes a more specific message which can be used to diagnose the
issue.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotAssignProperty

```
The class type 'Foo' has no assignable property 'Bar'.
```

**Thrown by:**
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate)

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
[`OnChange`](../../roblox/members/onchange)

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
[`OnEvent`](../../roblox/members/onevent)

You tried to connect to an event on an instance, but the event you specify
doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotCreateClass

```
Can't create a new instance of class 'EditableImage'.
```

**Thrown by:**
[`New`](../../roblox/members/new)

You attempted to create a type of instance that Fusion can't create.

!!! warning "Beta features"
	Some instances are only creatable when you have certain Studio betas
	enabled. Check your Beta Features tab to ensure that beta features aren't
	causing the issue.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotDepend

```
Observer can't depend on Observer.
```

**Thrown by:**
[`Observer`](../../graph/members/observer)

You attempted to form a dependency between two
[graph objects](../../graph/types/graphobject), but either the dependency set or
dependent set were frozen.

You might be trying to connect them in the wrong order, or the objects might not
be designed to have dependents or dependencies.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## destroyedTwice

```
`doCleanup()` was given something that it is already cleaning up. Unclear how to
proceed.
```

**Thrown by:**
[`doCleanup`](../../memory/members/docleanup)

You called `doCleanup()` on a function or object which carried some code. When
that code was run, it attempted to call `doCleanup()` on the same thing you
called with.

Usually, this would result in an infinite loop, because the same code would try
to clean itself up over and over again. Because cleanup tasks are only meant to
run once, this is invalid behaviour and so this error is thrown instead.

Ensure your code is the rightful owner of scopes that it is trying to clean up.
In particular, avoid cleaning up scopes you receive from elsewhere, unless you
and the original provider of the scope agree to transfer the responsibility of
cleaning up the scope.
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

## invalidAttributeChangeHandler

```
The change handler for the 'Active' attribute must be a function.
```

**Thrown by:**
[`AttributeChange`](../../roblox/members/attributechange)

`AttributeChange` expected you to provide a function for it to run when the
attribute changes, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidAttributeOutType

```
[AttributeOut] properties must be given Value objects.
```

**Thrown by:**
[`AttributeOut`](../../roblox/members/attributeout)

`AttributeOut` expected you to give it a [value](../../state/members/value), but
you gave it something else.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidChangeHandler

```
The change handler for the 'AbsoluteSize' property must be a function.
```

**Thrown by:**
[`OnChange`](../../roblox/members/onchange)

`OnChange` expected you to provide a function for it to run when the property
changes, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidEventHandler

```
The handler for the 'MouseEnter' event must be a function.
```

**Thrown by:**
[`OnEvent`](../../roblox/members/onevent)

`OnEvent` expected you to provide a function for it to run when the event is
fired, but you provided something other than a function.

For example, you might have accidentally provided `nil`.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutProperty

```
The Frame class doesn't have a property called 'MouseButton1Down'.
```

**Thrown by:**
[`Out`](../../roblox/members/out)

The property that you tried to output doesn't exist on the instance that `Out`
was used with.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutType

```
[Out] properties must be given Value objects.
```

**Thrown by:**
[`Out`](../../roblox/members/out)

`Out` expected you to give it a [value](../../state/members/value), but you gave
it something else.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidPropertyType

```
'Frame.BackgroundColor3' expected a 'Color3' type, but got a 'Vector3' type.
```

**Thrown by:**
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate)

You attempted to assign a value to a Roblox instance's property, but the 
assignment threw an error because that property doesn't accept values of that
type.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidSpringDamping

```
The damping ratio for a spring must be >= 0. (damping was -1.00)
```

**Thrown by:**
[`Spring`](../../animation/members/spring)

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
[`Spring`](../../animation/members/spring)

You provided a speed multiplier that the spring doesn't support, for example
`NaN` or a negative speed implying the spring moves backwards through time.
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

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedSpringDamping

```
The damping ratio for a spring must be a number. (got a string)
```

**Thrown by:**
[`Spring`](../../animation/members/spring)

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
[`Spring`](../../animation/members/spring)

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
[`Tween`](../../animation/members/tween)

You provided an easing curve that the tween couldn't understand. The easing
curve has to be specified using Roblox's `TweenInfo` data type.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## noTaskScheduler

```
Fusion is not connected to an external task scheduler.
```

Fusion depends on a task scheduler being present to perform certain time-related
tasks such as deferral, delays, or updating animations. You'll need to define a
set of standard task scheduler functions that Fusion can use for those purposes.

Roblox users should never see this error, as Fusion automatically connects to
Roblox's task scheduling APIs.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## poisonedScope

```
Attempted to use a scope after it's been destroyed; `doCleanup()` was previously
called on this scope. Ensure you are not reusing scopes after cleanup.
```

**Thrown by:**
scopes after being passed to [`doCleanup`](../../memory/members/docleanup)

If you attempt to read from, or write to, a scope that's been destroyed, this
message is shown. After a scope has been cleaned up, your code should forget the
reference to it, as it is no longer valid.

</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## propertySetError

```
Error setting property: UIAspectRatioConstraint.AspectRatio set to a
non-positive value. Value must be a positive.
```

**Thrown by:**
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate)

You attempted to set a property, but Roblox threw an error in response.

The error includes a more specific message which can be used to diagnose the
issue.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## springNanGoal

```
A spring was given a NaN goal, so some simulation has been skipped. Ensure no
springs have NaN goals.
```

**Thrown by:**
[`Spring`](../../animation/members/spring)

The goal parameter given to the spring during construction contained one or more
NaN values. 

This typically occurs when zero is accidentally divided by zero, or some other
invalid mathematical operation has occurred. Check that your code is free of
maths errors, and handles all edge cases.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## springNanMotion

```
A spring encountered NaN during motion, so has snapped to the goal position.
Ensure no springs have NaN positions or velocities.
```

**Thrown by:**
[`Spring`](../../animation/members/spring)

While calculating updated position and velocity, one or both of those values
ended up as NaN.

This typically occurs when zero is accidentally divided by zero, or some other
invalid mathematical operation has occurred. Check that your code is free of
maths errors, and handles all edge cases.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## springTypeMismatch

```
The type 'Vector3' doesn't match the spring's type 'Color3'.
```

**Thrown by:**
[`Spring`](../../animation/members/spring)

The spring expected you to provide a type matching the data type that the spring
is currently outputting. However, you provided a different data type.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## tweenNanGoal

```
A tween was given a NaN goal, so some animation has been skipped. Ensure no
tweens have NaN goals.
```

**Thrown by:**
[`Tween`](../../animation/members/tween)

The goal parameter given to the tween during construction contained one or more
NaN values. 

This typically occurs when zero is accidentally divided by zero, or some other
invalid mathematical operation has occurred. Check that your code is free of
maths errors, and handles all edge cases.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## tweenNanMotion

```
A tween encountered NaN during motion, so has snapped to the goal. Ensure no
tweens have NaN in their tween infos.
```

**Thrown by:**
[`Tween`](../../animation/members/tween)

While calculating an updated tween position, the final value contained one or
more NaN values.

This typically occurs when zero is accidentally divided by zero, or some other
invalid mathematical operation has occurred. Check that your code is free of
maths errors, and handles all edge cases.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unknownMessage

```
Unknown error: attempt to call a nil value
```

Fusion ran into a problem, but couldn't associate it with a valid type of error.
This is a fallback error type which shouldn't be seen by end users, because it
indicates that Fusion code isn't reporting errors correctly.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedChildType

```
'string' type children aren't accepted by `[Children]`.
```

**Thrown by:**
[`Children`](../../roblox/members/children)

You provided a value inside of `[Children]` which didn't meet the definition of
a [child](../../roblox/types/child) value. Check that you're only passing
instances, arrays and state objects.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedPropertyKey

```
'number' keys aren't accepted in property tables.
```

**Thrown by:**
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate)

You provided something other than a property assignment (`Property = Value`) or
[special key](../../roblox/types/specialkey) in your property table.

Most commonly, this means you tried to add child instances directly into the
property table, rather than passing them into the
[`[Children]`](../../roblox/members/children) special key.
</div>


-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedPropertyStage

```
'children' isn't a valid stage for a special key to be applied at.
```

**Thrown by:**
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate)

You attempted to use a [special key](../../roblox/types/specialkey) which has a
misconfigured `stage`, so Fusion didn't know when to apply it during instance
construction.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## useAfterDestroy

```
The Value object is no longer valid - it was destroyed before the Computed that 
is use()-ing. See discussion #292 on GitHub for advice.
```

**Thrown by:**
[`Spring`](../../animation/members/spring),
[`Tween`](../../animation/members/tween),
[`New`](../../roblox/members/new),
[`Hydrate`](../../roblox/members/hydrate),
[`Attribute`](../../roblox/members/attribute),
[`AttributeOut`](../../roblox/members/attributeout),
[`Out`](../../roblox/members/out),
[`Computed`](../../state/members/computed),
[`Observer`](../../graph/members/observer)

**Related discussions:** 
[`#292`](https://github.com/dphfox/Fusion/discussions/292)

Your code attempted to access an object after that object was destroyed..

Make sure your objects are being added to the correct scopes according to when
you expect them to be destroyed. Additionally, make sure your code can detect
and deal with situations where other objects are no longer available.
</div>
