local logger        = require("gbem.util.class.logger").create("ParamParser")
local sprintf       = require("gbem.util.ext.strings").sprintf
local trim          = require("gbem.util.ext.strings").trim
local count         = require("gbem.util.ext.tables").count
local contains      = require("gbem.util.ext.tables").contains


local function debugParams(params)
    local out = {}
    -- sort keys and iterate on them to have a predictable output
    local keys = {}
    for key, _ in pairs(params) do
        table.insert(keys, key)
    end
    table.sort(keys)
    for _, paramName in pairs(keys) do
        local paramValue = params[paramName]
        table.insert(out, string.format('%s=%s', paramName, paramValue))
    end
    return table.concat(out, ', ')
end

---@class ParamParser
---@field private _validators table
local ParamParser = {
    _validators = {}
}
ParamParser.__index = ParamParser

---------------
-- Functions --
---------------

--- Split a string in parameter name and value
 ---
 --- @param str string             The string to parse
 --- @return table? parsedParam    Dict of parameter value index by parameter name (or nil if parsing failed)
 ---
function ParamParser.splitStr(str)
    local _, _, paramName, paramValue = string.find(str, "(.+)=(.+)")

    -- soft fail (raise no error/exception) on nil
    if paramName == nil then return nil end
    if paramValue == nil then return nil end

    paramName = trim(paramName)
    paramValue = trim(paramValue)

    -- soft fail (raise no error/exception) on empty
    if paramName == '' then return nil end
    if paramValue == '' then return nil end

    return { name=paramName, value=paramValue }
end

--- Parse a list of strings to a list of parameters, enforce optional list of validators
 ---
 --- @param strList table      List of strings to parse
 --- @param validators? table  (optional) List of validators
 --- @return table params      Array of parameter value indexed by parameter name
 ---
function ParamParser.parse(strList, validators)
    local params = {}

    -- parse each string to an array of param value indexed by param name
    for _, str in ipairs(strList) do
        local param = ParamParser.splitStr(str)
        if param ~= nil then
            params[param.name] = param.value
        end
    end

    params = ParamParser.validate(params, validators)

    -- log parsing result
    local logMsg
    local paramsCount = count(params)
    if paramsCount <= 0 then
        logMsg = "No parameter found"
    else
        local paramsStr = debugParams(params)
        logMsg = sprintf("-> Parsed %s parameter(s): %s", paramsCount, paramsStr)
    end
    logger:debug(logMsg)

    return params
end

--- Validate a dict of parameters against given list of validators
 ---
 --- @param params table       Dict of parameter values by parameter name
 --- @param validators table   List of validators
 --- @return table             The list of parameters, potentially mutated
 --- @throw error              When a validator function returns nil
 ---
 --- @todo Make a copy to prevent mutation of the passed params array?
 ---
function ParamParser.validate(params, validators)
    for _, validator in ipairs(validators) do
        if validator.paramName then
            local initialParamValue = params[validator.paramName]
            if initialParamValue ~= nil then
                local finalParamValue = validator.validates(initialParamValue)

                if finalParamValue == nil then
                    local errorMsgTpl = "Invalid parameter value for '%s': %s"
                    if not validator.error then
                        error(sprintf(errorMsgTpl, validator.paramName, initialParamValue), 0)
                    else
                        local errorMsg = sprintf(validator.error, initialParamValue)
                        error(sprintf(errorMsgTpl, validator.paramName, errorMsg), 0)
                    end
                end
                params[validator.paramName] = finalParamValue
            end
        else
            local result = validator.validates(params)
            if result == nil then
                if not validator.error then
                    error("No error set for the validates function", 0)
                else
                    error(validator.error, 0)
                end
            end
            params = result
        end
    end
    return params
end

--------------
-- Instance --
--------------

--- Instantiate the ParamParser
 ---
 --- @param validators? table         List of validators to enforce when parsing
 --- @return ParamParser instance     New instance of the ParamParser
 ---
function ParamParser.create(validators)
    local instance = setmetatable({}, ParamParser)
    instance._validators = validators
    return instance
end

--- Parse a list of strings to a list of parameters, enforce instance validators
 ---
 --- @param strList table      List of strings to parse
 --- @return table params      Array of parameter value indexed by parameter name
 ---
function ParamParser:Parse(strList)
    return ParamParser.parse(strList, self._validators)
end

------------------
--- Validators ---
------------------

ParamParser.validators = {
    --- Function to parse a value to an integer if the value is a valid
    --- integer, optionally in the given range
     ---
     ---@param min? integer              (optional) Minimum accepted integer value
     ---@param max? integer              (optional) Maximum accepted integer value
     ---@return function validator      Validator function
     ---
    integer = function(min, max)
        return function(value)
            value = tonumber(value)
            if not value then return nil end
            if value ~= math.floor(value) then return nil end
            if min and value < min then return nil end
            if max and value > max then return nil end
            return value
        end
    end,

    --- Function to check if a value is present in the given list
     ---
     ---@param list table               List of accepted values
     ---@return function validator      Validator function
     ---
    inList = function(list)
        return function(value)
            if not contains(list, value) then return nil end
            return value
        end
    end,
}

return ParamParser
