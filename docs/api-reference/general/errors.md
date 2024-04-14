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

**Related to:**
[`New`](../../instances/members/new),
[`Hydrate`](../../instances/members/hydrate)

This message means you tried to set a property on an instance, but the property
can't be assigned to. This could be because the property doesn't exist, or
because it's locked by Roblox to prevent edits.

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

**Related to:**
[`OnChange`](../../instances/members/onchange)

This message means you tried to connect to a property change event, but the
property you specify doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotConnectEvent

```
The Frame class doesn't have an event called 'Foo'.
```

**Related to:**
[`OnEvent`](../../instances/members/onevent)

This message means you tried to connect to an event on an instance, but the
event you specify doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## callbackError

```
Error in callback: attempt to perform arithmetic (add) on number and string
```

**Related to:**
[`Computed`](../../state/members/computed),
[`ForKeys`](../../state/members/forkeys),
[`ForValues`](../../state/members/forvalues),
[`ForPairs`](../../state/members/forpairs),
[`Contextual`](../../memory/members/contextual)

This message means that Fusion ran a function you specified, but the function
threw an error that Fusion couldn't handle.

The error includes a more specific message which can be used to diagnose the
issue.
</div>