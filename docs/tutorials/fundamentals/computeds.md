Computeds are state objects that can process values from other state objects.
You pass in a callback to define a calculation. Then, you can use
`peek()` to read the result of the calculation at any time.

```Lua
local numCoins = Value(50)
local itemPrice = Value(10)

local finalCoins = Computed(function(use)
    return use(numCoins) - use(itemPrice)
end)

print(peek(finalCoins)) --> 40

numCoins:set(25)
itemPrice:set(15)
print(peek(finalCoins)) --> 10
```

-----

## Usage

To use `Computed` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Computed = Fusion.Computed
```

To create a new computed object, call the `Computed` function. You need to give
it a callback representing the calculation - for now, we'll add two numbers:

```Lua
local hardMaths = Computed(function(use)
    return 1 + 1
end)
```

The value the callback returns will be stored as the computed's value. You can
get the computed's current value using `peek()`:

```Lua
print(peek(hardMaths)) --> 2
```

The calculation is only run once by default. If you try and use `peek()` inside
the calculation, your code won't work:

```Lua
local number = Value(2)
local double = Computed(function(use)
    return peek(number) * 2
end)

-- The calculation runs once by default.
print(peek(number), peek(double)) --> 2 4

-- The calculation won't re-run! Oh no!
number:set(10)
print(peek(number), peek(double)) --> 10 4
```

This is where the `use` parameter comes in (see line 2 above). If you want your
calculation to re-run when your objects change value, pass the object to `use()`:

```Lua
local number = Value(2)
local double = Computed(function(use)
	use(number) -- the calculation will re-run when `number` changes value
    return peek(number) * 2
end)

print(peek(number), peek(double)) --> 2 4

-- Now it re-runs!
number:set(10)
print(peek(number), peek(double)) --> 10 20
```

For convenience, `use()` will also read the value, just like `peek()`, so you
can easily replace `peek()` calls with `use()` calls:

```Lua
local number = Value(2)
local double = Computed(function(use)
    return use(number) * 2 -- works identically to before
end)
```

-----

## When To Use This

Computeds are more specialist than regular values and observers. They're
designed for a single purpose: they make it easier and more efficient to derive
new values from existing state objects.

Derived values show up in a lot of places throughout UIs. For example, you might
want to insert a death counter into a string. Therefore, the contents of the
string are derived from the death counter:

![Diagram showing how the message depends on the death counter.](Derived-Value-Dark.svg#only-dark)
![Diagram showing how the message depends on the death counter.](Derived-Value-Light.svg#only-light)

While you can do this with values and observers alone, your code could get messy.

Consider the following code that doesn't use computeds - the intent is to create
a derived value, `finalCoins`, which equals `numCoins - itemPrice` at all times:

```Lua linenums="1"
local numCoins = Value(50)
local itemPrice = Value(10)

local finalCoins = Value(peek(numCoins) - peek(itemPrice))
local function updateFinalCoins()
    finalCoins:set(peek(numCoins) - peek(itemPrice))
end
Observer(numCoins):onChange(updateFinalCoins)
Observer(itemPrice):onChange(updateFinalCoins)
```

There are a few problems with this code currently:

- It's not immediately clear what's happening at a glance; there's lots of
boilerplate code obscuring what the *intent* of the code is.
- The logic for calculating `finalCoins` is duplicated twice - on lines 4 and 6.
- You have to manage updating the value yourself using observers. This is an
easy place for desynchronisation bugs to slip in.
- Another part of the code base could call `finalCoins:set()` and mess with the
value.

When written with computeds, the above problems are largely solved:

```Lua linenums="1"
local numCoins = Value(50)
local itemPrice = Value(10)

local finalCoins = Computed(function(use)
    return use(numCoins) - use(itemPrice)
end)
```

- The intent is immediately clear - this is a derived value.
- The logic is only specified once, in one callback.
- The computed updates itself when a state object you `use()` changes value.
- The callback is the only thing that can change the value - there is no `:set()`
method.

??? warning "A warning about delays in computed callbacks"

    One small caveat of computeds is that you must return the value immediately.
    If you need to send a request to the server or perform a long-running
    calculation, you shouldn't use computeds.

    The reason for this is consistency between variables. When all computeds run
    immediately (i.e. without yielding), all of your variables will behave
    consistently:

    ```Lua
    local numCoins = Value(50)
    local isEnoughCoins = Computed(function(use)
        return use(numCoins) > 25
    end)

    local message = Computed(function(use)
        if use(isEnoughCoins) then
            return use(numCoins) .. " is enough coins."
        else
            return use(numCoins) .. " is NOT enough coins."
        end
    end)

    print(peek(message)) --> 50 is enough coins.
    numCoins:set(2)
    print(peek(message)) --> 2 is NOT enough coins.
    ```

    If a delay is introduced, then inconsistencies and nonsense values could
    quickly appear:

    ```Lua hl_lines="3 17"
    local numCoins = Value(50)
    local isEnoughCoins = Computed(function(use)
        task.wait(5) -- Don't do this! This is just for the example
        return use(numCoins) > 25
    end)

    local message = Computed(function(use)
        if use(isEnoughCoins) then
            return use(numCoins) .. " is enough coins."
        else
            return use(numCoins) .. " is NOT enough coins."
        end
    end)

    print(peek(message)) --> 50 is enough coins.
    numCoins:set(2)
    print(peek(message)) --> 2 is enough coins.
    ```

    For this reason, yielding in computed callbacks is disallowed.

    If you have to introduce a delay, for example when invoking a
    RemoteFunction, consider using values and observers.

    ```Lua hl_lines="3-10 13-14 24-26"
    local numCoins = Value(50)

    local isEnoughCoins = Value(nil)
    local function updateIsEnoughCoins()
        isEnoughCoins:set(nil) -- indicate that we're calculating the value
        task.wait(5) -- this is now ok
        isEnoughCoins:set(peek(numCoins) > 25)
    end
    task.spawn(updateIsEnoughCoins)
    Observer(numCoins):onChange(updateIsEnoughCoins)

    local message = Computed(function()
        if peek(isEnoughCoins) == nil then
            return "Loading..."
        elseif peek(isEnoughCoins) then
            return peek(numCoins) .. " is enough coins."
        else
            return peek(numCoins) .. " is NOT enough coins."
        end
    end)

    print(peek(message)) --> 50 is enough coins.
    numCoins:set(2)
    print(peek(message)) --> Loading...
    task.wait(5)
    print(peek(message)) --> 2 is NOT enough coins.
    ```