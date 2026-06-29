-- Variables
local ui = {} -- Main module table
local __modules = {} -- Private cached modules table

-- Functions
local RegisterModule
local GetModule

-- Require modules from PRIVATE GitHub repository, you don't need it for an public repository though.
local function githubRequire(path: string, ignoreDefaultPath: boolean)
    -- Variables
    local OWNER = "foxzin-0635" -- My GitHub name
    local REPO = "rbx-in-luau" -- The current repository
    local FILE_PATH = path -- The path you've selected to load (not used btw)
    local TOKEN = __token -- The token (which has read-only access)
    local cleanPath = path:gsub("^%./", "") -- Cleans the given path for any bad characters (currently "./")
    if not cleanPath:find("%.lua$") then    
        cleanPath = cleanPath .. ".lua" -- Fix if no extension was given
    end
    if not ignoreDefaultPath then
      -- Change the path for your project's location
        cleanPath = "src/projects/ui-test-lib/"..cleanPath
    end

    -- Settings before requesting
    local url = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. cleanPath
    local headers = {
        ["Authorization"] = "token " .. TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw", -- Tells GitHub to return the raw file, not JSON
        ["User-Agent"] = "Roblox in Luau - Roblox API - Pure Luau"
    }

    -- Request for the raw file
    local response = request({
        Url = url,
        Method = "GET",
        Headers = headers
    })
    
    -- Good code :>
    if response.StatusCode == 200 then
        -- Load the module
        local m, sErr = loadstring(response.Body)
        if not m then error(sErr) end -- Checks for any errors inside the module
        
        local env = getfenv(m) -- Gets the module's environment
        
        -- Add global variables/functions to module's environment
        env.githubRequire = githubRequire
        env.getModule = GetModule
        env.__token = __token -- necessary
        
        -- Uncomment and change the match string for your project's configuration file
        -- if not cleanPath:match("src/config%.lua") then env.config = config end
        
        -- Apply the modified environment to the module
        setfenv(m, env)
        
        -- Executes the module and checks for any errors
        local s, res = pcall(m)
        
        -- Prints the errors if not succeeded
        -- (it is recursive!)
        if not s then error("Inside '"..cleanPath.."': "..tostring(res)) end
        
        -- Checks if the module didn't finished properly
        if not res then error("Module '"..cleanPath.."' compiled successfully, but no result was given. Did you forgot to add a 'return' statement?") end
        
        -- Returns the module
        return res
    else
        -- Fallback for module loading failures
        -- Known ones that needs to be checked:
        --  -> 200 = Success
        --  -> 404 = Not found
        --  -> 401 = Access Denied (mostly expired token)
        error("Failed to fetch file: Website gave code " .. tostring(response.StatusCode) .. ".")
    end
end

RegisterModule = function(path: string, name: string, ignoreDefaultPath: boolean)
  local module = githubRequire(path, ignoreDefaultPath)
  __modules[name] = module
end

GetModule = function(name: string)
  local module = __modules[name]
  if not module then error("Cannot get module '"..name.."' since it's non-existent.") end
  return module
end

--                   [-CONFIGURATION-]                   --
--> Here you can add the modules you want to cache
--> Example:
-- RegisterModule("src/scripts/HelloWorld.lua", "HelloWorld", false)

RegisterModule("src/utils/CreateRecursive.lua", "CreateRecursive", false)
RegisterModule("src/uis/test-code-autocomp.lua", "test-autoc", false)

--> Build module
ui.GetModule = GetModule
return ui