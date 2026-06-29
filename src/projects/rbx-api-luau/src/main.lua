-- Base hooks for the project.
-- Variables
local rbx_api = {} -- Main module table
local config -- Module config
local api_dump_latest -- a luau table version of MaximumADHD's "API-Dump.json"
local __modules = {} -- holds general classes
local __rbxClasses = {} -- holds Roblox classes
local _dtypeof = dtypeof or typeof -- typeof backup

local __idl = Instance.new("NumberValue")
__idl.Value = 2

-- Functions
-- Explanations further down
local RegisterModule
local RegisterRbxClass
local GetModule
local GetRbxClass

-- Custom typeof(v) for printing custom table type names.
local function typeof_hook(v: any)
    if _dtypeof(v) == "table" then
        -- NOTE: gettype() is only accessible with elevated context ("NotAccessibleSecurity", which is simulated in the module)
        if v.gettype then return v.gettype() else return _dtypeof(v) end
    end
    return _dtypeof(v)
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
        cleanPath = "src/projects/rbx-api-luau/"..cleanPath
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
    
    if config.debugOutputRequirePaths then
        print(cleanPath)
    end
    
    -- Good code :>
    if response.StatusCode == 200 then
        -- Load the module
        local m, sErr = loadstring(response.Body)
        if not m then error(sErr) end -- Checks for any errors inside the module
        
        local env = getfenv(m) -- Gets the module's environment
        
        -- Add global variables/functions to module's environment
        env.githubRequire = githubRequire
        env.typeof = typeof_hook
        env.dtypeof = dtypeof
        env.apidump = api_dump_latest
        env.autoGenerateMembersWithValues = AutoGenerateMembersWithValues
        env.getModule = GetModule
        env.getRbxClass = GetRbxClass
        env.thread_identity = __idl
        env.__token = __token -- necessary
        
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
RegisterModule = function(path: string, name: string, ignoreDefaultPath: boolean)
    local module = githubRequire(path, ignoreDefaultPath)
    __modules[name] = module
end
-- Load Roblox class modules for the project's "__rbxClasses" table.
RegisterRbxClass = function(path: string, name: string, ignoreDefaultPath: boolean)
    local class = githubRequire(path, ignoreDefaultPath)
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
    
    Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
    
    local md = __rbxClasses[name]
    if not md then error("Cannot get class '"..name.."' since it's non-existent.") end
    local apidmp_class = md.getApiInfo()
    if apidmp_class then
        if apidmp_class.Tags ~= nil then
            if table.find(apidmp_class.Tags, "NotReplicated") then
                Runtime:SetIdentityLevelByContext("None")
                error("Cannot get class '"..name.."' since it's an internal Roblox Class.")
            else
                Runtime:SetIdentityLevelByContext("None")
                return md
            end
        else
            if apidmp_class.Category and apidmp_class.Category == "DataType" then
                Runtime:SetIdentityLevelByContext("None")
                return md
            end
        end
    end
    Runtime:SetIdentityLevelByContext("None")
    error("Class '"..name.."' has no API info!")
end

--                   [-CONFIGURATION-]                   --

--> Necessary files
config = githubRequire("src/config.lua", false)
-- Reverted to original
api_dump_latest = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")) -- Thanks to MaximumADHD for "API-Dump.json" <3

--> Modules from "src/utils"
RegisterModule("src/utils/Security.lua", "Security", false)
RegisterModule("src/utils/Runtime.lua", "Runtime", false)
RegisterModule("src/utils/Range.lua", "Range", false)

--> Data Types
RegisterRbxClass("src/types/RBXScriptConnection.lua", "data-types/RBXScriptConnection", false) -- RBXScriptConnection
RegisterRbxClass("src/types/RBXScriptSignal.lua", "data-types/RBXScriptSignal", false) -- RBXScriptSignal

--> Roblox classes from "src/classes"
config.CanImportAnyClass = true -- Tweak before importing
RegisterRbxClass("src/classes/Object.lua", "rbx-classes/Object", false) -- Base class
RegisterRbxClass("src/classes/testClasses/Example.lua", "example/rbx-classes/Example", false) -- Example Class
config.CanImportAnyClass = false -- Disable Tweak

--> Add stuff to the main module table
-- rbx_api.__modules = __modules
-- rbx_api.__rbxClasses = __rbxClasses
rbx_api.api_dump = api_dump_latest
rbx_api.config = config
rbx_api.GetModule = GetModule
rbx_api.GetRbxClass = GetRbxClass

--> Return the module table.
return rbx_api