local values = {}

--- Get a default value for a nil value
 ---
 ---@param value any          The value we want a default for
 ---@param defaultValue any   The value we want to default to
 ---@return any               The value if it is not nil, else the default value
 ---
function values.default(value, defaultValue)
    if value == nil then
        return defaultValue
    else
        return value
    end
end

--- Get a default value for a nil value
 ---
 ---@param condition any          The condition we want to evaluate
 ---@param returnIfTrue any       The value we want to return if condition evaluates to true
 ---@param returnIfFalse any      The value we want to return if condition evaluates to false
 ---@return any value             One of returnIfTrue or returnIfFalse
 ---
function values.fif(condition, returnIfTrue, returnIfFalse)
    if condition
        then return returnIfTrue
        else return returnIfFalse
    end
end

return values
