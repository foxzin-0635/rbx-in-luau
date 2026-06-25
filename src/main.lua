-- Base hooks for the project.
-- Variables
local rbx_api = {} -- Main module table
local config -- Module config
local api_dump_latest -- a luau table version of MaximumADHD's "API-Dump.json"
local __modules = {} -- holds general classes
local __rbxClasses = {} -- holds Roblox classes
local dtypeof = typeof -- typeof backup

-- Functions
-- Explanations further down
local RegisterModule
local RegisterRbxClass
local GetModule
local GetRbxClass

-- Custom typeof(v) for printing custom table type names.
local function typeof_hook(v: any)
    if dtypeof(v) == "table" then
        -- NOTE: gettype() is only accessible with elevated context ("NotAccessibleSecurity", which is simulated in the module)
        if v.gettype then return v.gettype() else return dtypeof(v) end
    end
    return dtypeof(v)
end

-- [DEPRECATED] A function to generate a usable version of the member table of an class.
local function AutoGenerateMembersWithValues(membersTable: {{class: number, member: number, presetValue: any}})
    local res = {}
    for _, t in ipairs(membersTable) do
        local class = __modules.__api_dump.Classes[t.class]
        local member = class.Members[t.member]
        res[member.Name] = {
            ApiEquivalent = member,
            Value = t.presetValue
        }
    end
    return res
end

-- Require modules from PRIVATE GitHub repository, you don't need it for an public repository though.
local function githubRequire(path: string)
    -- Variables
    local OWNER = "foxzin-0635" -- My GitHub name
    local REPO = "rbx-api-luau" -- The current repository
    local FILE_PATH = path -- The path you've selected to load
    local TOKEN = "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" -- The token (which has read-only access)
    local cleanPath = path:gsub("^%./", "") -- Cleans the given path for any bad characters (currently "./")
    if not cleanPath:find("%.lua$") then
        cleanPath = cleanPath .. ".lua" -- Fix if no extension was given
    end

    -- Settings before requesting
    local url = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. cleanPath
    local headers = {
        ["Authorization"] = "token " .. TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw", -- Tells GitHub to return the raw file, not JSON
        ["User-Agent"] = "Roblox API - Pure Luau"
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
        env.typeof = typeof_hook
        env.apidump = api_dump_latest
        env.autoGenerateMembersWithValues = AutoGenerateMembersWithValues
        env.getModule = GetModule
        env.getRbxClass = GetRbxClass
        
        -- Not sure why i did this. :P
        if not cleanPath:match("src/config%.lua") then env.rbx_api_config = config end
        
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

-- Load other modules for the project's "__modules" table. (AKA Old "rbx_api" main table)
RegisterModule = function(path: string, name: string)
    local module = githubRequire(path)
    __modules[name] = module
end
-- Load Roblox class modules for the project's "__rbxClasses" table.
RegisterRbxClass = function(path: string, name: string)
    local class = githubRequire(path)
    __rbxClasses[name] = class
end

-- Here you can get loaded modules from the "__modules" table.
GetModule = function(name: string)
    local md = __modules[name]
    if not md then error("Cannot get module '"..name.."' since it's non-existent.") end
    return md
end
-- Here you can get loaded Roblox classes from the "__rbxClasses" table.
GetRbxClass = function(name: string)
    if config.CanImportAnyClass then if __rbxClasses[name] then return __rbxClasses[name] else error("Cannot get class '"..name.."' since it's non-existent.") end end
    local Runtime = GetModule("Runtime")
    
    if config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then
        local cur_idl = Runtime:GetIdentityLevel()
        Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
        
        local md = __rbxClasses[name]
        if not md then error("Cannot get class '"..name.."' since it's non-existent.") end
        local apidmp_class = md.getApiInfo()
        if apidmp_class then
            if table.find(apidmp_class.Tags, "NotReplicated") then
                Runtime:SetIdentityLevel(cur_idl)
                error("Cannot get class '"..name.."' since it's an internal Roblox Class.")
            end
        end
        Runtime:SetIdentityLevel(cur_idl)
        error("Class '"..name.."' has no API info!")
    end
    
    local cur_idl = Runtime:GetIdentityLevel()
    config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = true
    Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
    
    local md = __rbxClasses[name]
    if not md then error("Cannot get class '"..name.."' since it's non-existent.") end
    local apidmp_class = md.getApiInfo()
    if apidmp_class then
        if table.find(apidmp_class.Tags, "NotReplicated") then
            config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
            Runtime:SetIdentityLevel(cur_idl)
            error("Cannot get class '"..name.."' since it's an internal Roblox Class.")
        end
    end
    config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
    Runtime:SetIdentityLevel(cur_idl)
    error("Class '"..name.."' has no API info!")
end

--                   [-CONFIGURATION-]                   --

--> Necessary files
config = githubRequire("src/config.lua", "rbx_api_config")
api_dump_latest = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")) -- Thanks to MaximumADHD for "API-Dump.json" <3

--> Modules from "src/utils"
RegisterModule("src/utils/Security.lua", "Security")
RegisterModule("src/utils/Runtime.lua", "Runtime")
RegisterModule("src/utils/Range.lua", "Range")

--> Roblox classes from "src/classes"
RegisterRbxClass("src/classes/Object.lua", "rbx-classes/Object") -- Base class
RegisterRbxClass("src/classes/testClasses/Example.lua", "example/rbx-classes/Example") -- Example Class

--> Subprojects using this project
RegisterModule("projects_using_this/client-studio/src/main.lua", "client-studio") -- client-studio subproject

--> Add stuff to the main module table
rbx_api.__modules = __modules
rbx_api.__rbxClasses = __rbxClasses
rbx_api.api_dump = api_dump_latest
rbx_api.config = config
rbx_api.GetModule = GetModule
rbx_api.GetRbxClass = GetRbxClass

--> Return the module table.
return rbx_api