# 🌺 Hineko Framework

A lightweight Luau module-loading framework for Roblox, inspired by [Flamework](https://github.com/rbxts-flamework/core) (roblox-ts). Built for study purposes — contributions and suggestions are welcome!

> ⚠️ **Note:** This is an experimental project. It is not recommended for production use.

---

## ✨ Features

- **Module auto-loading** — point the loader at a folder and it handles the rest
- **Lifecycle hooks** — `OnInit` and `OnStart` run automatically on every module
- **Built-in lifecycles** — `OnPlayerAdded`, `OnPlayerRemoved`, `OnTick`, `OnPhysics`, `OnRender`
- **Dependency injection** — retrieve any loaded module by its `ModuleScript` reference
- **Loader events** — subscribe to `ignited`, `moduleLoaded`, `moduleError`, and `finished`
- **Debug mode** — verbose logging for development
- **Hot unloading** — remove a module from the registry at runtime

---

## 📁 Project structure

```
src/
├── client/
│   ├── features/          ← your controllers go here
│   └── setup.client.luau  ← client entry point
├── server/
│   ├── features/          ← your services go here
│   └── setup.server.luau  ← server entry point
└── shared/
    └── hineko-framework/  ← framework source
```

---

## 🚀 Getting started

### 1. Require the framework

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])
```

### 2. Register your module folders and ignite

```luau
HinekoFramework:addPath(script.Parent.features) -- folder containing your modules
HinekoFramework:ignite()                        -- load & start everything
```

That's it. Every `ModuleScript` inside `features` (and any sub-folders) is loaded automatically.

---

## 📦 Module anatomy

Every module must expose a `.new()` constructor. The framework instantiates it and calls lifecycle hooks in order.

```luau
local MyService = {}
MyService.__index = MyService

export type Self = typeof(setmetatable({}, MyService))

function MyService.new(): Self
    return setmetatable({}, MyService)
end

-- Called immediately after the module is required (blocking)
function MyService:OnInit()
    print("MyService initializing")
end

-- Called after ALL modules have been initialized (non-blocking order)
function MyService:OnStart()
    print("MyService started")
end

return MyService
```

### Implementing built-in lifecycles

Use `Loader:implements()` **before** returning the module to opt in to additional lifecycle events:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local MyService = {}
MyService.__index = MyService

function MyService.new()
    return setmetatable({}, MyService)
end

function MyService:OnPlayerAdded(player: Player)
    print(player.Name, "joined!")
end

function MyService:OnPlayerRemoved(player: Player)
    print(player.Name, "left!")
end

Loader:implements(MyService, "OnPlayerAdded", "OnPlayerRemoved")
return MyService
```

---

## 🔄 Built-in lifecycles

| Lifecycle | Method signature | Trigger |
|---|---|---|
| `OnInit` | `OnInit(self)` | Module loaded — runs before `OnStart` |
| `OnStart` | `OnStart(self)` | All modules loaded |
| `OnPlayerAdded` | `OnPlayerAdded(self, player: Player)` | A player joins the server |
| `OnPlayerRemoved` | `OnPlayerRemoved(self, player: Player)` | A player leaves the server |
| `OnTick` | `OnTick(self, deltaTime: number)` | `RunService.Heartbeat` |
| `OnPhysics` | `OnPhysics(self, deltaTime: number)` | `RunService.Stepped` |
| `OnRender` | `OnRender(self, deltaTime: number)` | `RunService.RenderStepped` (client only) |

`OnInit` and `OnStart` are built in and require no `implements()` call. All others must be declared with `Loader:implements()`.

---

## 🔌 Dependency injection

After ignition you can retrieve another module's class instance by its `ModuleScript`:

```luau
function MyService:OnStart()
    local otherService = Loader:getDependency(script.Parent["other-service"])
    print(otherService:Hello())
end
```

---

## 📡 Loader events

Subscribe to loader events before calling `:ignite()`:

```luau
local event = HinekoFramework:getEvent("moduleLoaded")
if event then
    event:connect(function(result)
        print("Loaded:", result.name)
    end)
end
```

| Event name | Payload |
|---|---|
| `ignited` | `{}` |
| `moduleLoaded` | `{ name: string, module: table }` |
| `moduleError` | `{ name: string, error: string }` |
| `finished` | `{}` |

---

## 🛠️ Full Loader API

| Method | Description |
|---|---|
| `Loader:addPath(folder: Folder)` | Register a folder to scan for modules (before ignition) |
| `Loader:ignite()` | Load all modules and run their lifecycle hooks |
| `Loader:debugMode(state: boolean)` | Toggle verbose debug logging |
| `Loader:isIgnited(): boolean` | Returns `true` if the loader has been ignited |
| `Loader:getDependency(module: ModuleScript): T?` | Retrieve a loaded module's class instance |
| `Loader:getModuleByClass(class: T): ModuleScript?` | Find a `ModuleScript` by its class instance |
| `Loader:getEvent(name: string): Event?` | Subscribe to a loader event |
| `Loader:getLifecycleManager(): LifecycleManager` | Access the lifecycle manager directly |
| `Loader:implements(class, ...lifecycles)` | Declare which lifecycles a module uses |
| `Loader:unload(module: ModuleScript)` | Remove a module from the registry at runtime |

---

## 🌷 Made with love by Alice

Suggestions and improvements are always welcome!
