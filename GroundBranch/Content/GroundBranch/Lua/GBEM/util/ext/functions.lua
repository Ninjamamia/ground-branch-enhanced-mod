local functions = {}

function functions.pipe(funcList)
    return function(arg)
        for _, func in ipairs(funcList) do
            arg = func(arg)
        end
        return arg
    end
end

return functions
