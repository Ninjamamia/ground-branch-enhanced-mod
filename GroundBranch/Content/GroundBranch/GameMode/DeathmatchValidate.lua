local deathmatchvalidate = {
	}
	

function deathmatchvalidate:ValidateLevel()
	-- new feature to help mission editor validate levels

	local ErrorsFound = {}
	
	-- first deal with player starts
	
	local AllPlayerStarts = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBPlayerStart')
	if #AllPlayerStarts < 1 then
		table.insert(ErrorsFound, "No player starts were found. You need ideally 16 or so.")
	elseif #AllPlayerStarts < 16 then
		table.insert(ErrorsFound, "Only " .. #AllPlayerStarts .. " player starts were found. This is probably too few.")
	end

	-- new stand-alone collision check for player starts

	for i, TestActor in ipairs(AllPlayerStarts) do
		if actor.IsColliding(TestActor) then
			table.insert(ErrorsFound, "Warning: player start '@" .. actor.GetName(TestActor) .. "' may be colliding with the map")
		end
		if not ai.IsOnNavMesh(TestActor) then
			table.insert(ErrorsFound, "Warning: player start '@" .. actor.GetName(TestActor) .. "' does not appear to be contacting the navmesh")
		end
	end
	
	-- AI spawn points are now superseded

	return ErrorsFound
end


return deathmatchvalidate