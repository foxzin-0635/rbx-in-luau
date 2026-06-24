-- Base hooks for the project.
local rbx_api = {}
local config
local api_dump_latest
local __modules = {}
local __rbxClasses = {}
local dtypeof = typeof

-- Functions
local RegisterModule
local RegisterRbxClass
local GetModule
local GetRbxClass

local function typeof_hook(v: any)
    if dtypeof(v) == "table" then
        if v.gettype then return v.gettype() else return dtypeof(v) end
    end
    return dtypeof(v)
end

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

local function githubRequire(path: string)
    local OWNER = "foxzin-0635"
    local REPO = "rbx-api-luau"
    local FILE_PATH = path
    local TOKEN = "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" -- note: renew every 1 day.
    local cleanPath = path:gsub("^%./", "")
    if not cleanPath:find("%.lua$") then
        cleanPath = cleanPath .. ".lua"
    end

    local url = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. cleanPath
    local headers = {
        ["Authorization"] = "token " .. TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw", -- Tells GitHub to return the raw file, not JSON
        ["User-Agent"] = "Roblox API - Pure Luau"
    }

    local response = request({
        Url = url,
        Method = "GET",
        Headers = headers
    })

    if response.StatusCode == 200 then
        -- loadstring() compiles and runs the fetched Lua code
        
        local m, sErr = loadstring(response.Body)
        if not m then error(sErr) end
        
        local env = getfenv(m)
        
        env.githubRequire = githubRequire
        env.typeof = typeof_hook
        env.apidump = api_dump_latest
        env.autoGenerateMembersWithValues = AutoGenerateMembersWithValues
        env.getModule = GetModule
        env.getRbxClass = GetRbxClass
        
        if not cleanPath:match("src/config%.lua") then env.rbx_api_config = config end
        
        setfenv(m, env)
        
        local s, res = pcall(m)
        
        if not s then error("Inside '"..cleanPath.."': "..tostring(res)) end
        
        if not res then error("Module '"..cleanPath.."' compiled successfully, but no result was given. Did you forgot to add a 'return' statement?") end
        
        return res
    else
        error("Failed to fetch file: Website gave code " .. tostring(response.StatusCode) .. ".")
    end
end

RegisterModule = function(path: string, name: string)
    local module = githubRequire(path)
    __modules[name] = module
end
RegisterRbxClass = function(path: string, name: string)
    local class = githubRequire(path)
    __rbxClasses[name] = class
end

GetModule = function(name: string)
    local md = __modules[name]
    if not md then error("Cannot get module '"..name.."' since it's non-existent.") end
    return md
end
GetRbxClass = function(name: string)
    if config.CanImportAnyClass then return __rbxClasses[name] end
    local Runtime = GetModule("Runtime")
    
    if config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then
        local cur_idl = Runtime:GetIdentityLevel()
        Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
        
        local md = __rbxClasses[name]
        if not md then error("Cannot get module '"..name.."' since it's non-existent.") end
        local apidmp_class = md.getApiInfo()
        if apidmp_class then
            if table.find(apidmp_class.Tags, "NotReplicated") then
                Runtime:SetIdentityLevel(cur_idl)
                warn("Cannot get class '"..name.."' since it's an internal Roblox Class.")
                return nil
            end
        end
        Runtime:SetIdentityLevel(cur_idl)
        return md
    end
    
    local cur_idl = Runtime:GetIdentityLevel()
    config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = true
    Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
    
    local md = __rbxClasses[name]
    if not md then error("Cannot get module '"..name.."' since it's non-existent.") end
    local apidmp_class = md.getApiInfo()
    if apidmp_class then
        if table.find(apidmp_class.Tags, "NotReplicated") then
            config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
            Runtime:SetIdentityLevel(cur_idl)
            warn("Cannot get class '"..name.."' since it's an internal Roblox Class.")
            return nil
        end
    end
    config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
    Runtime:SetIdentityLevel(cur_idl)
    return md
end

config = githubRequire("src/config.lua", "rbx_api_config")
api_dump_latest = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json"))

-- Classes
RegisterRbxClass("src/classes/Object.lua", "rbx-classes/Object") -- Base class
RegisterRbxClass("src/classes/testClasses/Example.lua", "example/rbx-classes/Example") -- Example Class

-- src/utils
RegisterModule("src/utils/Runtime.lua", "Runtime")
RegisterModule("src/utils/Security.lua", "Security")
RegisterModule("src/utils/Range.lua", "Range")

-- Subprojects
RegisterModule("projects_using_this/client-studio/src/main.lua", "client-studio") -- client-studio subproject

-- Add stuff
rbx_api.__modules = __modules
rbx_api.__rbxClasses = __rbxClasses
rbx_api.api_dump = api_dump_latest
rbx_api.config = config
rbx_api.GetModule = GetModule
rbx_api.GetRbxClass = GetRbxClass

-- Return the new modules table.
return rbx_api