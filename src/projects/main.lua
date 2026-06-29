-- Variables
local rbx = {} -- The current module
local __projects = {} -- The private projects table

local __token = "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" -- use this instead of rewriting the same token across githubRequire functions.

-- Functions
local RegisterProject
local GetProject

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
        cleanPath = "src/projects/"..cleanPath
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
        env.getProject = GetProject
        env.__token = __token -- necessary
        
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

RegisterProject = function(path: string, name: string, ignoreDefaultPath: boolean)
    local project = githubRequire(path, ignoreDefaultPath)
    __projects[name] = project
end

GetProject = function(name: string)
    local project = __projects[name]
    if not project then error("Cannot get project '"..name.."' since it's non-existent.") end
    return poject
end

--                   [-CONFIGURATION-]                   --
--> Projects
RegisterProject("luau-in-luau/src/main.lua", "luau-in-luau", false) -- luau-lang/luau replica in pure Luau.
RegisterProject("rbx-api-luau/src/main.lua", "rbx-api-luau", false) -- replica of the official Roblox API in pure Luau.

rbx.GetProject = GetProject

return rbx