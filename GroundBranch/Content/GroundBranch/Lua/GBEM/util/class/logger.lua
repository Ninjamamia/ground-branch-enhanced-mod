local default = require('GBEM.util.ext.values').default

local Logger = {}

Logger.levels = {
    OFF     = 0,
    ERROR   = 100,
    WARN    = 200,
    INFO    = 300,
    DEBUG   = 400,
}

-- Logger.levels.DEFAULT = Logger.levels.DEBUG
Logger.levels.DEFAULT = Logger.levels.INFO

-- hooks used for testing
Logger.toStringFunction = tostring
Logger.printFunction = print

-- default log level
Logger.level = Logger.levels.DEFAULT
Logger.includeTableAddress = false

-- cycle-aware object to string function
--- @todo probably better to move this function to another file (maybe something like util/strings.lua)
local function stringify_helper(cache, result, object, level, indent_string, tostring)
    local arrow = ' = '
    local tab = string.rep(indent_string, level)
    local tab_next = string.rep(indent_string, level + 1)

    if type(object) == 'table' or type(object) == 'function' then
        if cache[object] then
            table.insert(result, tostring(object))
            table.insert(result, ' -- (Cyclic)')
            return
        end
        cache[object] = true
    end

    if type(object) == 'table' then
        table.insert(result, '{')
        if Logger.includeTableAddress then
            table.insert(result, ' -- ')
            table.insert(result, tostring(object))
        end
        table.insert(result, '\n')

        local keys = {}
        for key, _ in pairs(object) do
            table.insert(keys, key)
        end
        table.sort(keys)

        for i = 1, #keys do
            local key = keys[i]
            local value = object[key]

            table.insert(result, tab_next)
            stringify_helper(cache, result, key, level + 1, indent_string, tostring)
            table.insert(result, arrow)

            stringify_helper(cache, result, value, level + 1, indent_string, tostring)
            table.insert(result, ',\n')
        end

        table.insert(result, tab)
        table.insert(result, '}')
    elseif type(object) == 'function' then
        local info = debug.getinfo(object)
        local info_condensed = {
            isvararg = info.isvararg,
            nparams = info.nparams
        }
        table.insert(result, tostring(object))
        table.insert(result, ' ')
        stringify_helper(cache, result, info_condensed, level, indent_string, tostring)
    elseif type(object) == 'userdata' then
        local mt = getmetatable(object)
        if mt == nil then
            table.insert(result, tostring(object))
            table.insert(result, ' with no Metatable')
        elseif mt.__tostring then
            table.insert(result, 'userdata ')
            table.insert(result, mt.__tostring(object))
        else
            table.insert(result, tostring(object))
            table.insert(result, ' with Metatable ')
            stringify_helper(cache, result, mt, level, indent_string, tostring)
        end
    elseif type(object) == 'string' then
        table.insert(result, '"')
        table.insert(result, object)
        table.insert(result, '"')
    else
        table.insert(result, tostring(object))
    end
end

--- Create a logger
 ---
 ---@param name string    Logger's name, will be prepended to each log message
 ---@param level? string   (optional) One of the keys of the Logger.levels dict, default to Logger.levels.DEFAULT
 ---
function Logger.create(name, level)
    local instance = setmetatable({}, {__index = Logger})
    instance.name = default(name, 'Unnamed logger')
    instance.level = level
    return instance
end

--- Log a message
 ---
 ---@param level string   One of the keys of the Logger.levels dict
 ---@param msg string     The message to log
 ---
function Logger:log(level, msg)
    -- when logLevel is not valid, default to ERROR logLevel
    if Logger.levels[level] == nil then
        level = "ERROR"
    end
    local logLevel = Logger.levels[level]

    -- short circuit when message logLevel is higher than the logger logLevel
    if logLevel > self.level then return end

    -- output message
    local out
    if type(msg) == 'table' then
        local result = {}
        stringify_helper({}, result, msg, 0,'    ', Logger.toStringFunction)
        msg = table.concat(result)
    end

    local debug_info = debug.getinfo(3, "fnSl")
    local location = ""

    if self.level > Logger.levels.DEBUG then
        if debug_info.namewhat == "method" then
            location = string.format("%s:%s()", self.name, debug_info.name)
        elseif debug_info.namewhat == "field" then
            location = string.format("%s.%s()", self.name, debug_info.name)
        else
            location = string.format("%s:%s", self.name, debug_info.currentline)
        end
        out = string.format("%-7s %-40s %s", level, location, msg)
    else
        out = string.format("%-7s %-24s %s", level, self.name, msg)
    end

    Logger.printFunction(out)
end

--- Log a message with the DEBUG level
 ---
 ---@param msg string     The message to log
 ---
function Logger:debug(msg)
    self:log("DEBUG", msg)
end

--- Log a message with the INFO level
 ---
 ---@param msg string     The message to log
 ---
function Logger:info(msg)
    self:log("INFO", msg)
end

--- Log a message with the WARN level
 ---
 ---@param msg string     The message to log
 ---
function Logger:warn(msg)
    self:log("WARN", msg)
end

--- Log a message with the ERROR level
 ---
 ---@param msg string     The message to log
 ---
function Logger:error(msg)
    self:log("ERROR", msg)
end

return Logger
