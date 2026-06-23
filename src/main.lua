-- Base hooks for the project.
local __modules = {}
local function githubRequire(path: string)
    local OWNER = "foxzin-0635"
    local REPO = "test"
    local FILE_PATH = path
    local TOKEN = "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" -- note: renew every 1 day.
    local cleanPath = path:gsub("^%./", "")
    if not cleanPath:find("%.lua$") then
        cleanPath = cleanPath .. ".lua"
    end

    if __modules[cleanPath] then
        return __modules[cleanPath]
    end

    local url = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. FILE_PATH
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
        
        local customEnv = setmetatable({}, {
            __index = function(_, key)
                if key == "githubRequire" then return githubRequire end
                return getfenv()[key]
            end
        })
        setfenv(m, customEnv)
        
        local s, res = pcall(m)
        
        if not s then error("Inside '"..cleanPath.."': "..tostring(res)) end
        
        if not res then error("Module '"..cleanPath.."' compiled successfully, but no result was given. Did you forgot to add a 'return' statement?") end
        
        __modules[cleanPath] = res
        return res
    else
        error("Failed to fetch file: Website gave code " .. tostring(response.StatusCode) .. ".")
    end
end

local function GetModule(path: string)
    return __modules[path:gsub("^%./", "")]
end

-- Classes
githubRequire("src/classes/Object.lua") -- Base class

-- Add helper method
__modules.GetModule = GetModule

-- Return the new modules table.
return __modules