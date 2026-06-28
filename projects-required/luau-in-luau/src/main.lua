-- Variables
local l_in_l = {}
local __modules = {}
local conf

-- Functions
local RegisterModule
local GetModule

local dtypeof = typeof -- typeof backup

-- Custom typeof(v) for printing custom table type names.
local function typeof_hook(v: any)
    if dtypeof(v) == "table" then
        if v.type then return v.type else return dtypeof(v) end
    end
    return dtypeof(v)
end

local function getNewContentsFromSpecifiedModule(name: string)
    assert(GetModule ~= nil, "GetModule function is nil!")
    local module = GetModule(name)
    assert(module ~= nil, "Module is non-existent.")
    local contents = {}
    
    if dtypeof(module) == "table" then
        if module.NewEnv and module.NewEnvItemsNames then
            contents.envContents = {}
            for _,v in pairs(module.NewEnvItemsNames) do
                contents.envContents[v] = module.NewEnv[v]
            end
        end
    end
    
    if next(contents) ~= nil then
        return contents
    end
    warn("No new content available.")
    return nil
end

local function pcallForNewContents()
    local function newCConcat(t1, t2)
        if t2.envContents then
            if not t1.envContents then t1.envContents = {} end
            for k,_ in pairs(t2.envContents) do
                if t1.envContents[k] then continue end
                t1.envContents[k] = t2.envContents[k]
            end
        end
        
        return t1
    end
    
    local res = {}
    
    local s0, res0 = pcall(function()
        local Common_contents = getNewContentsFromSpecifiedModule("Common/Common.lua")
        return Common_contents
    end)
    
    if not s0 then error("Failed to retrieve module's new content, module is: Common/Common.lua") end
    
    -- Join all
    if res0 then newCConcat(res, res0) end
    return res
end

-- Require modules from PRIVATE GitHub repository, you don't need it for an public repository though.
local function githubRequire(path: string)
    -- Variables
    local OWNER = "foxzin-0635" -- My GitHub name
    local REPO = "rbx-api-luau" -- The current repository
    local FILE_PATH = path -- The path you've selected to load
    local TOKEN = __token -- The token (which has read-only access)
    local cleanPath = path:gsub("^%./", "") -- Cleans the given path for any bad characters (currently "./")
    cleanPath = "projects-required/luau-in-luau/"..cleanPath:gsub("^projects%-required/luau%-in%-luau/", "") -- bruh
    if not cleanPath:find("%.lua$") then
        cleanPath = cleanPath .. ".lua" -- Fix if no extension was given
    end

    -- Settings before requesting
    local url = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. cleanPath
    local headers = {
        ["Authorization"] = "token " .. TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw", -- Tells GitHub to return the raw file, not JSON
        ["User-Agent"] = "Roblox API - Pure Luau - Luau in Luau"
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
        
        -- Not sure why i did this. :P
        if not cleanPath:match("src/conf%.lua") then
            env.conf = conf
            for k, _ in pairs(conf.RUNTIME_VARIABLES) do
                env[k] = conf.RUNTIME_VARIABLES[k]
            end
        end
        
        -- Add new content from other modules
        local newContent = pcallForNewContents()
        if next(newContent) ~= nil then
            if newContent.envContents then
                for k,v in pairs(newContent.envContents) do
                    env[k] = v
                end
            end
        end
        
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

RegisterModule = function(path: string, name: string)
    local module = githubRequire(path)
    __modules[name] = module
end

GetModule = function(name: string)
    local module = __modules[name]
    if not module then error("Cannot get module '"..name.."' since it's non-existent.") end
    return module
end

--                          [-CONFIGURATION-]                          --

--> Necessary files
conf = githubRequire("src/conf.lua")

--> Modules
RegisterModule("src/Common/Common.lua", "Common/Common.lua") -- [TEST] Common.h -> Common.lua

l_in_l.conf = conf
l_in_l.GetModule = GetModule

return l_in_l