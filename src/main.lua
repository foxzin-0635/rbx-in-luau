-- Base hooks for the project.
local config
local api_dump_latest
local __modules = {}
local dtypeof = typeof

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

local function githubRequire(path: string, nameReplacement: string?)
    local OWNER = "foxzin-0635"
    local REPO = "rbx-api-luau"
    local FILE_PATH = path
    local TOKEN = "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" -- note: renew every 1 day.
    local cleanPath = path:gsub("^%./", "")
    if not cleanPath:find("%.lua$") then
        cleanPath = cleanPath .. ".lua"
    end

    if __modules[cleanPath] then
        return __modules[cleanPath]
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
        
        if not cleanPath:match("src/config%.lua") then env.rbx_api_config = config end
        
        setfenv(m, env)
        
        local s, res = pcall(m)
        
        if not s then error("Inside '"..cleanPath.."': "..tostring(res)) end
        
        if not res then error("Module '"..cleanPath.."' compiled successfully, but no result was given. Did you forgot to add a 'return' statement?") end
        
        if nameReplacement then __modules[nameReplacement] = res else __modules[cleanPath] = res end
        return res
    else
        error("Failed to fetch file: Website gave code " .. tostring(response.StatusCode) .. ".")
    end
end

local function GetModule(path: string)
    if config.CanImportAnyClass then return __modules[path:gsub("^%./", "")] end
    local Runtime = githubRequire("src/utils/Runtime.lua")
    
    if config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then
        local cur_idl = Runtime:GetIdentityLevel()
        Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
        
        local md = __modules[path:gsub("^%./", "")]
        if not md then error("Cannot get module '"..path.."' since it's non-existent.") end
        local apidmp_class = md.ApiEquivalent
        if apidmp_class then
            if table.find(apidmp_class.Tags, "NotReplicated") then
                Runtime:SetIdentityLevel(cur_idl)
                warn("Cannot get class '"..path.."' since it's an internal Roblox Class.")
                return nil
            end
        end
        Runtime:SetIdentityLevel(cur_idl)
        return md
    end
    
    local cur_idl = Runtime:GetIdentityLevel()
    config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = true
    Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
    
    local md = __modules[path:gsub("^%./", "")]
    if not md then error("Cannot get module '"..path.."' since it's non-existent.") end
    local apidmp_class = md.ApiEquivalent
    if apidmp_class then
        if table.find(apidmp_class.Tags, "NotReplicated") then
            config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
            Runtime:SetIdentityLevel(cur_idl)
            warn("Cannot get class '"..path.."' since it's an internal Roblox Class.")
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
githubRequire("src/classes/Object.lua", "rbx-classes/Object") -- Base class

-- Subprojects
githubRequire("projects_using_this/client-studio/src/main.lua", "client-studio") -- client-studio subproject

-- Add helper method
__modules.__api_dump = api_dump_latest
__modules.config = config
__modules.GetModule = GetModule

-- Return the new modules table.
return __modules