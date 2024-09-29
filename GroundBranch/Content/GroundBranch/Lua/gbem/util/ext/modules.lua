local modules = {}

local _require = require

---@param moduleName string       String to check
function modules.requireReload(moduleName)
	if package.loaded[moduleName] then
		print("[requireReload] Reloading module '" .. moduleName .. "'...")
		package.loaded[moduleName] = nil
	end
	return _require(moduleName)
end

return modules
