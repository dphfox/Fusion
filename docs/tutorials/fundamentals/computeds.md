Computeds are state objects that can process values from other state objects.
You pass in a callback which calculates the final value. Then, you can use
`:get()` to retrieve that value at any time.

```Lua
local numCoins = Value(50)
local itemPrice = Value(10)

local finalCoins = Computed(function()
    return numCoins:get() - itemPrice:get()
end)

print(finalCoins:get()) --> 40

numCoins:set(25)
itemPrice:set(15)
print(finalCoins:get()) --> 10
```

-----

## Usage

To use `Computed` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Computed = Fusion.Computed
```

To create a new computed object, call the `Computed` function and pass it a
callback returning a single value:

```Lua
local hardMaths = Computed(function()
    return 1 + 1
end)
```

The value your callback returns will be stored as the computed's value. You can
get the computed's current value using `:get()`:

```Lua
print(hardMaths:get()) --> 2
```

By default, a computed only runs its callback once. However, Fusion can detect
any time you call `:get()` on a state object inside the callback. If any of them
change value, the callback will be re-run and the value will update:

```Lua
local number = Value(2)
local double = Computed(function()
    return number:get() * 2
end)

print(number:get(), "* 2 =", double:get()) --> 2 * 2 = 4

number:set(10)
print(number:get(), "* 2 =", double:get()) --> 10 * 2 = 20

number:set(-5)
print(number:get(), "* 2 =", double:get()) --> -5 * 2 = -10
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

local finalCoins = Value(numCoins:get() - itemPrice:get())
local function updateFinalCoins()
    finalCoins:set(numCoins:get() - itemPrice:get())
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

local finalCoins = Computed(function()
    return numCoins:get() - itemPrice:get()
end)
```

- The intent is immediately clear - this is a derived value.
- The logic is only specified once, in one callback.
- The computed updates itself when a state object you `:get()` changes value.
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
    local isEnoughCoins = Computed(function()
        return numCoins:get() > 25
    end)

    local message = Computed(function()
        if isEnoughCoins:get() then
            return numCoins:get() .. " is enough coins."
        else
            return numCoins:get() .. " is NOT enough coins."
        end
    end)

    print(message:get()) --> 50 is enough coins.
    numCoins:set(2)
    print(message:get()) --> 2 is NOT enough coins.
    ```

    If a delay is introduced, then inconsistencies and nonsense values could
    quickly appear:

    ```Lua hl_lines="3 17"
    local numCoins = Value(50)
    local isEnoughCoins = Computed(function()
        wait(5) -- Don't do this! This is just for the example
        return numCoins:get() > 25
    end)

    local message = Computed(function()
        if isEnoughCoins:get() then
            return numCoins:get() .. " is enough coins."
        else
            return numCoins:get() .. " is NOT enough coins."
        end
    end)

    print(message:get()) --> 50 is enough coins.
    numCoins:set(2)
    print(message:get()) --> 2 is enough coins.
    ```

    For this reason, yielding in computed callbacks is disallowed.

    If you have to introduce a delay, for example when invoking a
    RemoteFunction, consider using values and observers.

    ```Lua hl_lines="3-10 13-14 24-26"
    local numCoins = Value(50)

    local isEnoughCoins = Value(nil)
    local function updateIsEnoughCoins()
        isEnoughCoins:set(nil) -- indicate that we're calculating the value
        wait(5) -- this is now ok
        isEnoughCoins:set(numCoins:get() > 25)
    end
    task.spawn(updateIsEnoughCoins)
    Observer(numCoins):onChange(updateIsEnoughCoins)

    local message = Computed(function()
        if isEnoughCoins:get() == nil then
            return "Loading..."
        elseif isEnoughCoins:get() then
            return numCoins:get() .. " is enough coins."
        else
            return numCoins:get() .. " is NOT enough coins."
        end
    end)

    print(message:get()) --> 50 is enough coins.
    numCoins:set(2)
    print(message:get()) --> Loading...
    wait(5)
    print(message:get()) --> 2 is NOT enough coins.
    ```