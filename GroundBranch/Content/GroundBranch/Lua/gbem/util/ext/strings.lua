local strings = {}

strings.__index = strings

--- Check if the provided string start with the provided prefix
 ---@param str string       String to check
 ---@param prefix string    Prefix to check
 ---@return boolean         True if str starts with prefix, false otherwise
function strings.startsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

--- Check if the provided string end with the provided suffix
 ---@param str string       String to check
 ---@param suffix string    Prefix to check
 ---@return boolean         True if str end with suffix, false otherwise
function strings.endsWith(str, suffix)
    return string.sub(str, #suffix) == suffix
end

function strings.sprintf(...)
    return string.format(...)
end

function strings.printf(...)
    print(string.format(...))
end

--- Remove whitespaces at the start and end of the provided string
 ---@param str string       String to trim
 ---@return string          A new string with no whitespaces prefix or suffix
function strings.trim(str)
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

return strings
