<div align="center">

# 🌸 Hineko Framework 🌸

*A Roblox framework inspired by [Flamework](https://flamework.firedevs.com/)* 🌷

[![Luau](https://img.shields.io/badge/Made%20with-Luau-blue?style=for-the-badge)](https://luau-lang.org/)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-red?style=for-the-badge)](https://www.roblox.com/)

</div>

---

## 🌺 What is Hineko Framework?

**Hineko Framework** is a cute yet powerful framework for Roblox, heavily inspired by the well-known **Flamework**. It brings the same familiar patterns — **Services**, **Controllers**, **Lifecycles**, and **Dependencies** — into a lightweight, easy to understand Luau package. 🌻

Like Flamework, Hineko structures your game code into organized singletons that are automatically loaded, initialized, and started — so you can focus on building your game instead of wiring everything together. 🌼


## 🌹 Features

- 🌸 **Automatic Module Loading** — Drop your modules into folders, add the path, and ignite. Hineko finds and loads everything for you.
- 🌷 **Lifecycle System** — Declare lifecycles like `OnPlayerAdded`, `OnTick`, `OnRender`, and more. Modules opt-in via `:implements()`.
- 🌻 **Priority Ordering** — Control initialization order with a simple `priority` field. Higher priority modules load first.
- 🌺 **Dependency Injection** — Retrieve loaded singletons with `:getDependency()` for clean cross-module communication.
- 🌼 **Event System** — Listen to framework events like `ignited`, `moduleLoaded`, `moduleError`, and `finished`.
- 🏵️ **Custom Lifecycles** — Create your own lifecycle modules (like `OnCharacterAdded`) just by adding them to a folder.
- 💮 **Debug Mode** — Toggle detailed logging to see exactly what the framework is doing under the hood.

## 🌷 Quick Start

### 1. Setup (Server)

```lua
-- setup.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])

HinekoFramework:debugMode(true) -- Optional: see what's happening
HinekoFramework:addPath(script.Parent.features) -- Add your modules folder (you can use this how many times you want!)
HinekoFramework:ignite() -- Start the magic!
```

### 2. Setup (Client)

```lua
-- setup.client.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])

HinekoFramework:debugMode(true)
HinekoFramework:addPath(script.Parent.features)
HinekoFramework:ignite()
```


## 🌻 Creating a Service/Controller

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local MyService = {}
MyService.__index = MyService
MyService.priority = 1  -- Higher = loads earlier

function MyService.new()
    return setmetatable({}, MyService)
end

function MyService:OnInit()
    print("MyService initialized!")
end

function MyService:OnStart()
    print("MyService started!")
end

function MyService:OnPlayerAdded(player)
    print("Welcome,", player.Name)
end

Loader:implements(MyService, "OnPlayerAdded")
return MyService
```

## 🌼 Getting Dependencies

Need to access another module? Use `:getDependency()` to retrieve it!

```lua
function MyOtherService.new()
    local self = setmetatable({}, MyOtherService)

    self.dependencies = {
        MyService = Loader:getDependency(script.Parent["my-service"]),
    }

    return self
end

function MyOtherService:OnStart()
    -- Use your dependency freely!
    self.dependencies.MyService:DoSomething()
end
```

## 🏵️ Listening to Framework Events

```lua
local ignitedEvent = HinekoFramework:getEvent("ignited")
local finishedEvent = HinekoFramework:getEvent("finished")
local moduleErrorEvent = HinekoFramework:getEvent("moduleError")
local moduleLoadedEvent = HinekoFramework:getEvent("moduleLoaded")

ignitedEvent:connect(function()
    print("Hineko has ignited!")
end)

finishedEvent:connect(function()
    print("All modules loaded and started!")
end)

moduleLoadedEvent:connect(function(data)
    print("Module loaded:", data.name)
end)

moduleErrorEvent:connect(function(data)
    warn("Error loading module:", data.name, data.error)
end)
```

## 🌺 Built-in Lifecycles

| Lifecycle | Description |
|-----------|-------------|
|  `OnPlayerAdded` | Fires when a player joins the game |
|  `OnPlayerRemoved` | Fires when a player leaves the game |
|  `OnTick` | Fires every heartbeat tick |
|  `OnPhysics` | Fires on physics step |
|  `OnRender` | Fires on render step (client only) |

You can also create **custom lifecycles** (like `OnCharacterAdded`) by adding lifecycle modules to any folder and registering it with `:addPath()`.

## 🌸 Module Lifecycle Flow

```
addPath() → ignite() → require modules → sort by priority → .new() → :OnInit() → :OnStart() → Done!
```

---

<div align="center">

*Made with love by Alice*
</div>