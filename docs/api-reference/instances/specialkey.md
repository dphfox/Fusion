<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">SpecialKey</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

The standard interface for special keys that can be used in property tables for
instance processing. Compatible with the [New](./new.md) and 
[Hydrate](./hydrate.md) functions.

```Lua
{
    type: "SpecialKey",
    kind: string,
    stage: "self" | "descendants" | "ancestor" | "observer",
    apply: (
        self: SpecialKey, 
        value: any, 
        applyTo: Instance, 
        cleanupTasks: {Task}
    ) -> ()
}
```

-----

## Fields

- `type` - identifies this table as a special key
- `kind` - gives a developer-friendly name to the object for debugging
- `stage` - determines when
the special key should apply itself during the hydration process
- `apply` - the method that will be called to apply the special key to an
instance

-----

## Example Usage

```Lua
local Example = {}
Example.type = "SpecialKey"
Example.kind = "Example"
Example.stage = "observer"

function Example:apply(value, applyTo, cleanupTasks)
	local conn = applyTo:GetAttributeChangedSignal("Foo"):Connect(function()
        print("My value is", value)
    end)
    table.insert(cleanupTasks, conn)
end
```

-----

## Stages

When using [New](../instances/new.md) and [Hydrate](../instances/hydrate.md), 
properties are applied in the following order:

1. String keys, except Parent
2. Special keys with `stage = "self"`
3. Special keys with `stage = "descendants"`
4. Parent, if provided
5. Special keys with `stage = "ancestor"`
6. Special keys with `stage = "observer"`

There are multiple motivations for splitting special keys into stages like these:

- Before we parent descendants to the instance, we want to initialise all of
the instance's properties that don't depend on anything else
- Before we parent the instance to an ancestor, we want to parent and initialise
all of the instance's descendants as fully as possible
- Before we attach handlers to anything, we want to parent to and initialise
the instance's ancestor as fully as possible

For these reasons, the roles of each stage are as follows:

### self

The `self` stage is used for special keys that run before descendants are
parented. This is typically used for special keys that operate on the instance
itself in a vacuum.

### descendants

The `descendants` stage is used for special keys that need to deal with
descendants, but which don't need to know about the ancestry. This is important
because parenting descendants after the instance is parented to an ancestor can
be more expensive in terms of performance.

### ancestor

The `ancestor` stage is used for special keys that deal with the ancestor of
the instance. This is the last stage that should be used for initialising the
instance, and occurs after the Parent has been set.

### observer

The `observer` stage is used for special keys that watch the instance for
changes or export references to the instance. This stage is where any event
handlers should be connected, as initialisation should be done by this point.