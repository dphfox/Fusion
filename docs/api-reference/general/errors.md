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
`Fusion.cleanup` was renamed to `Fusion.doCleanup`. This will be an error in future versions of Fusion.
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
Attempted to destroy Computed twice; ensure you're not manually calling `:destroy()` while using scopes. See discussion #292 on GitHub for advice.
```

**Thrown by:**
[`Value`](../../state/members/value),
[`Computed`](../../state/members/computed),
[`Observer`](../../state/members/observer),
[`For`](../../state/members/for),
[`Spring`](../../animation/members/spring),
[`Tween`](../../animation/members/tween),

The `:destroy()` method of the object in question was called more than once.

This usually means you called `:destroy()` manually, which is almost never
required because Fusion's constructors always link objects to
[scopes](../../../tutorials/fundamentals/scopes). When that scope is passed to 
[`doCleanup()`](../../memory/members/docleanup), the `:destroy()` method is
called on every object inside.
</div>