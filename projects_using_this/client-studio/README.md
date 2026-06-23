# client-studio
An project for executors that will recreate the environment of Roblox Studio in the Client.

Of course it won't be accurate since you only have access to client-side, but I'll make it nearly perfect to the original by using some _**tricks**_.

## How to activate it?
The rbx-api-luau will automatically create an module for it and configure, so that you can import it using `GetModule()`.

```luau
-- Assuming you've imported rbx-api-luau and saved in a variable (e.g: rbx_api)...
local client_studio = rbx_api.GetModule("projects_using_this/client-studio/src/main.lua") -- The main file and module that will run anything.
client_studio:Init() -- Start the module.
```

## Why _'executor only'_?
Because i have more control and it makes easier to code, not because of making it an _exploit_.

_I've tried doing an Roblox Studio legit version of the `rbx-api-luau`, but it wasn't that great to be honest.._