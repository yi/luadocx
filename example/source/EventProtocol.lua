
--[[--

Events are the principal way in which you create interactive applications. They are a way of
triggering responses in your program. For example, you can turn any display object into an
interactive object.

]]
local M = {}

--[[--

Make an interactive object.

]]
function M.extend(object)
    object.listeners = {}

    --[[--

Adds a listener to the object’s list of listeners. When the named event occurs, the listener will be invoked and be supplied with a table representing the event.

### Example:

~~~
-- Create an object that listens to events
local player = Player.new()
qeeplay.api.EventProtocol.extend(player)

-- Setup listener
local function onPlayerDead(event)
    -- event.name   == "PLAYER_DEAD"
    -- event.object == player
end
player:addEventListener("PLAYER_DEAD", onPlayerDead)

-- Sometime later, create an event and dispatch it
player:dispatchEvent({name = "PLAYER_DEAD"})
~~~

<br />

### Parameters:

-   string **eventName** specifying the name of the event to listen for.
-   function **listener** If the event's event.name matches this string, listener will be invoked.

]]
    function object:addEventListener(eventName, listener)
        eventName = string.upper(eventName)
        if object.listeners[eventName] == nil then object.listeners[eventName] = {} end
        local t = object.listeners[eventName]
        t[#t + 1] = listener
    end

    --[[--

Dispatches event to object. The event parameter must be a table with a name property which is a
string identifying the type of event. Event include a object property to the event so that your listener can know which object
received the event.

### Parameters:

-   table **event** contains event properties

]]
    function object:dispatchEvent(event)
        event.name = string.upper(event.name)
        event.target = object
        local eventName = event.name
        if object.listeners[eventName] == nil then return end
        local t = object.listeners[eventName]
        for i = #t, 1, -1 do
            local listener = t[i]
            if listener(event) == false then break end
        end
    end

    return object
end

return M
