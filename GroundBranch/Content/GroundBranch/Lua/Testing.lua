local Testing = {
}

function Testing:PostRun()
	-- print("Testing:PostRun():")
	-- print("self: " .. tostring(self))

	-- print("Testing: " .. tostring(Testing))
	-- for key, value in pairs(Testing) do
	 	-- print("key: " .. tostring(key) .. ", value: " .. tostring(value))
	-- end

	-- print(self.script)
	
	-- SomeFunction()

	timer.Set(self, "Update", 1, true)
end

function Testing:Update()
	print("Testing:Update():")
	local i = 1
	
	local bActive = (i == 1)
	print("bActive: " .. tostring(bActive))
	-- print("self: " .. tostring(self))

	-- print("Testing: " .. tostring(Testing))
	-- for key, value in pairs(Testing) do
	 	-- print("key: " .. tostring(key) .. ", value: " .. tostring(value))
	-- end

	-- self:SomeFunction()

	 local SpawnProtectionVolumes = gameplaystatics.GetAllActorsOfClass('/Game/GBCore/Engine/BP_SpawnProtectionVolume')
	--Testing.SomeFunction()
	
	for i, SpawnProtectionVolume in ipairs(SpawnProtectionVolumes) do
		print("> SpawnProtectionVolume: " .. tostring(SpawnProtectionVolume))
		GetLuaComp(SpawnProtectionVolume).SetProtectedTeam(1)
		-- print()
		-- for key, value in pairs(SpawnProtectionVolume) do
		-- 	print("key: " .. tostring(key) .. ", value: " .. tostring(value))
		-- end
		-- SpawnProtectionVolume:SomeFunction(1)
		-- print(SpawnProtectionVolume.self)
	end
end

return Testing