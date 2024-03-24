local defusevalidate = {

	PriorityTags = { "AISpawn_1", "AISpawn_2", "AISpawn_3", "AISpawn_4", "AISpawn_5",
		"AISpawn_6_10", "AISpawn_11_20", "AISpawn_21_30", "AISpawn_31_40", "AISpawn_41_50" },

	SpawnPriorityGroupIDs = { "AISpawn_11_20", "AISpawn_31_40" },
	-- these define the start of priority groups, e.g. group 1 = everything up to AISPawn_11_20 (i.e. from AISpawn_1 to AISpawn_6_10), group 2 = AISpawn_11_20 onwards, group 3 = AISpawn_31_40 onwards
	-- everything in the first group is spawned as before. Everything is spawned with 100% certainty until the T count is reached
	-- subsequent priority groups are capped, ensuring that some lower priority AI is spawned, and everything else is randomised as much as possible
	-- so overall the must-spawn AI will spawn (priority group 1) and a random mix of more important and (a few) less important AI will spawn fairly randomly

}


function defusevalidate:StripNumbersFromName(ObjectName)
	while string.len(ObjectName)>1 and ((string.sub(ObjectName, -1, -1)>='0' and string.sub(ObjectName, -1, -1)<='9') or string.sub(ObjectName, -1, -1)=='_') do
		ObjectName = string.sub(ObjectName, 1, -2)
	end
	
	return ObjectName
end


function defusevalidate:ValidateLevel()
	-- new feature to help mission editor validate levels

	local ErrorsFound = {}
	
	---- phase 1: check bombs and bomb tags
	
	local AllBombs = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_BigBomb.BP_BigBomb_C')
	local NumGroups = 0
	local GroupedBombs = {}

	if #AllBombs == 0 then
		table.insert(ErrorsFound, "No bombs found at all!")
	elseif #AllBombs < 4 then
		table.insert(ErrorsFound, "Warning: " .. #AllBombs .. " bombs might be too few")
	end

	-- group bombs by actor tag:
	
	for i, Bomb in ipairs(AllBombs) do
		local GroupTag = actor.GetTag(Bomb, 1)
		if GroupTag ~= nil then
			if GroupedBombs[GroupTag] == nil then
				NumGroups = NumGroups + 1
				GroupedBombs[GroupTag] = {}
			end
			table.insert(GroupedBombs[GroupTag], Bomb)
		else
			table.insert(ErrorsFound, "Warning: Bomb '@" .. actor.GetName(Bomb) .. "' did not have a (group) tag set")
		end
				
		GetLuaComp(Bomb).SetTeam(255)
	end

	-- new standalone check on collision for bombs

	local AtLeastOneBombCollided = false
	for i, Bomb in ipairs(AllBombs) do
		if actor.IsColliding(Bomb) then
			AtLeastOneBombCollided = true
			table.insert(ErrorsFound, "Warning: Bomb '@" .. actor.GetName(Bomb) .. "' may be colliding with the map")
		end
	end
	if AtLeastOneBombCollided then
		table.insert(ErrorsFound, "(Make sure to deselect all bombs before running validation as selected bombs may incorrectly register as colliding)")
	end

	-- treat each bomb as its own group if no tags were found:
	
	if NumGroups < 1 then
		NumGroups = #AllBombs
		for i, Bomb in ipairs(AllBombs) do
			GroupedBombs[i] = {}
			table.insert(GroupedBombs[i], Bomb)
		end
	else
		-- at this point, GroupedBombs{} has indices = bomb group name, and values = array containing references for bombs with that tag

		local AverageBombsPerGroup = #AllBombs / NumGroups
		
		for GroupName, BombsInGroup in pairs(GroupedBombs) do
			local BombNumberDeviation = math.abs( #BombsInGroup - AverageBombsPerGroup )
			local BombProportionDeviation = BombNumberDeviation / #AllBombs
			local avgint = tonumber(string.format("%.1f", AverageBombsPerGroup))
			
			if BombProportionDeviation > 0.07 and #BombsInGroup < AverageBombsPerGroup then
				table.insert(ErrorsFound, "Warning: Bomb group '" .. GroupName .. "' has relatively few bombs assigned to it (" .. #BombsInGroup .. ", compared to average of " .. avgint .. ")")
			elseif BombProportionDeviation > 0.06 and #BombsInGroup > AverageBombsPerGroup then
				table.insert(ErrorsFound, "Warning: Bomb group '" .. GroupName .. "' has relatively many bombs assigned to it (" .. #BombsInGroup .. ", compared to average of " .. avgint .. ")")
			end
		end		
	end

	------- phase 2 - check priority tags of the ai spawns, make sure they are allocated evenly

	local AllAISpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')


	if #AllAISpawns == 0 then
		table.insert(ErrorsFound, "No AI spawns found")
	else
		if #AllAISpawns < 30 then
			table.insert(ErrorsFound, "Only " .. #AllAISpawns .. " AI spawn points provided. This is a little low - aim for at least 30 and ideally 50+")
		end
		
		local CurrentPriorityGroup = 1
		local CurrentGroupTotal = 0
		local CurrentPriorityGroupSpawns = {}
		-- this needs to be outside the loop
	
		-- check the priorities of the ai spawns
		for i, PriorityTag in ipairs(self.PriorityTags) do
			if CurrentPriorityGroup <= #self.SpawnPriorityGroupIDs then
				if PriorityTag == self.SpawnPriorityGroupIDs[CurrentPriorityGroup] then
					-- we found the priority tag corresponding to the start of the next priority group
					
					local StartPriority
					local EndPriority
					if CurrentPriorityGroup == 1 then
						StartPriority = "AISpawn_1"
					else
						StartPriority = self.SpawnPriorityGroupIDs[CurrentPriorityGroup - 1]
					end
					EndPriority = self.SpawnPriorityGroupIDs[CurrentPriorityGroup]
					
					if CurrentGroupTotal == 0 then
						table.insert(ErrorsFound, "Warning: No spawns found within priority range " .. StartPriority .. " to " .. EndPriority)
					elseif CurrentPriorityGroup > 1 and CurrentGroupTotal < 0.15 * #AllAISpawns then
						-- it's ok if the first priority group is small
						local pcnumber = tonumber(string.format("%.0f", 100 * (CurrentGroupTotal / #AllAISpawns)))
						table.insert(ErrorsFound, "Warning: Relatively few spawns (" .. CurrentGroupTotal .. " of " .. #AllAISpawns ..", or " .. pcnumber.. "% of total) are assigned a priority within priority range " .. StartPriority .. " to " .. EndPriority)
					end

					CurrentPriorityGroup = CurrentPriorityGroup + 1
					CurrentGroupTotal = 0
				end
			end
		
			for j, SpawnPoint in ipairs(AllAISpawns) do
				if actor.HasTag(SpawnPoint, PriorityTag) then
					CurrentGroupTotal = CurrentGroupTotal + 1
				end
			end

		end
	end
	
	-- new stand-alone collision check for AI spawns

	for i, TestActor in ipairs(AllAISpawns) do
		if actor.IsColliding(TestActor) then
			table.insert(ErrorsFound, "Warning: AI spawn point '@" .. actor.GetName(TestActor) .. "' may be colliding with the map")
		end
		if not ai.IsOnNavMesh(TestActor) then
			table.insert(ErrorsFound, "Warning: AI spawn point '@" .. actor.GetName(TestActor) .. "' does not appear to be contacting the navmesh")
		end
	end
	
	-- now do a more straightforward iteration through spawn points
	
	local SquadsByName = {}
	local SquadsBySquadId = {}
	local SpawnInfo
	local SquadIdProblem = false
	local SquadNameProblem = false

	local GroupedBombSpawns = {}
	local NumGroupAI = 0

	for _, SpawnPoint in ipairs(AllAISpawns) do
		SpawnInfo = ai.GetSpawnPointInfo(SpawnPoint)
		
		local CurrentSquad
		local SpawnPointName = actor.GetName(SpawnPoint)
		CleanName = self:StripNumbersFromName(SpawnPointName)
		--print(SpawnPointName .. " -> " .. CleanName .. ", SquadID = " .. SpawnInfo.SquadId)
		
		if SquadsByName[CleanName] == nil then
			CurrentSquad = {}
			CurrentSquad.Count = 1
			CurrentSquad.WarnedSquadId = false
			CurrentSquad.WarnedSquadOrders = false
			CurrentSquad.WarnedNoOrders = false
			CurrentSquad.SquadId = SpawnInfo.SquadId
			CurrentSquad.SquadOrders = SpawnInfo.SquadOrders
			SquadsByName[CleanName] = CurrentSquad
		else
			CurrentSquad = SquadsByName[CleanName]
			CurrentSquad.Count = CurrentSquad.Count + 1
			if CurrentSquad.SquadId ~= SpawnInfo.SquadId and not CurrentSquad.WarnedSquadId then
				SquadIdProblem = true
				CurrentSquad.WarnedSquadId = true
				table.insert(ErrorsFound, "AI Spawn points '" .. CleanName .. "' have multiple squad IDs")
			end
			if CurrentSquad.SquadOrders ~= SpawnInfo.SquadOrders and not CurrentSquad.WarnedSquadOrders then
				CurrentSquad.WarnedSquadOrders = true
				table.insert(ErrorsFound, "AI Spawn points '" .. CleanName .. "' have multiple squad orders")
			end
			if SpawnInfo.SquadOrders == "None" and not CurrentSquad.WarnedNoOrders then
				CurrentSquad.WarnedNoOrders = true
				table.insert(ErrorsFound, "AI Spawn points '" .. CleanName .. "' have no squad orders" )
			end
		end
		
		if SquadsBySquadId[SpawnInfo.SquadId] == nil then
			CurrentSquad = {}
			CurrentSquad.Count = 1
			CurrentSquad.WarnedSquadName = false
			CurrentSquad.WarnedSquadOrders = false
			CurrentSquad.CleanName = CleanName
			CurrentSquad.SquadOrders = SpawnInfo.SquadOrders
			SquadsBySquadId[SpawnInfo.SquadId] = CurrentSquad
		else
			CurrentSquad = SquadsBySquadId[SpawnInfo.SquadId]
			CurrentSquad.Count = CurrentSquad.Count + 1
			if CurrentSquad.CleanName ~= CleanName and not CurrentSquad.WarnedSquadName then
				SquadNameProblem = true
				CurrentSquad.WarnedSquadName = true
				table.insert(ErrorsFound, "AI Spawn points for SquadID " .. SpawnInfo.SquadId .. " have multiple spawn point names")
			end
			if CurrentSquad.SquadOrders ~= SpawnInfo.SquadOrders and not CurrentSquad.WarnedSquadOrders then
				CurrentSquad.WarnedSquadOrders = true
				table.insert(ErrorsFound, "AI Spawn points for SquadID " .. SpawnInfo.SquadId .. " have multiple squad orders")
			end
		end
		
		-- now check bomb tags
				
		local SpawnPointTags = actor.GetTags(SpawnPoint)

		for _, BombGroupTag in ipairs(SpawnPointTags) do
			if BombGroupTag ~= "MissionActor" and string.sub(BombGroupTag, 1, 8) ~= "AISpawn_" then
				if GroupedBombs[BombGroupTag] == nil then
					table.insert(ErrorsFound, "Warning: spawn point '@" .. actor.GetName(SpawnPoint) .. "' has tag '" .. BombGroupTag .. "' that does not correspond to a bomb group")
				else
					if GroupedBombSpawns[BombGroupTag] == nil then
						GroupedBombSpawns[BombGroupTag] = 1
					else
						GroupedBombSpawns[BombGroupTag] = GroupedBombSpawns[BombGroupTag] + 1
					end
					
					NumGroupAI = NumGroupAI + 1
				end
			end
		end
	end

	if SquadIdProblem or SquadNameProblem then
		table.insert(ErrorsFound, "Squad IDs do not appear to match name sets. To fix: select all AI spawn points, and click Determine Squad Ids")
	end

	-- count squads guarding and patrolling for later tests
	local GuardSquadCount = 0
	local PatrolSquadCount = 0
	
	for _, CurrentSquad in pairs(SquadsBySquadId) do
		if CurrentSquad.SquadOrders == 'Guard' then
			GuardSquadCount = GuardSquadCount + 1
		elseif CurrentSquad.SquadOrders == 'Patrol' then
			PatrolSquadCount = PatrolSquadCount + 1
		end
	end
	
	-- now check spawn allocations to bomb groups
	
	if NumGroups > 0 then
		local AverageAIPerGroup = NumGroupAI / NumGroups
		
		for GroupName, _ in pairs(GroupedBombs) do
			if GroupedBombSpawns[GroupName] == nil then
				table.insert(ErrorsFound, "Warning: no AI spawn points associated with bomb group '" .. GroupName .. "'")
			else
				local AINumberDeviation = math.abs( GroupedBombSpawns[GroupName] - AverageAIPerGroup )
				local AIProportionDeviation = AINumberDeviation / NumGroupAI
				local avgint = tonumber(string.format("%.1f", AverageAIPerGroup))
				
				if AIProportionDeviation > 0.07 and GroupedBombSpawns[GroupName] < AverageAIPerGroup then
					table.insert(ErrorsFound, "Warning: Bomb group '" .. GroupName .. "' has relatively few AI spawns assigned to it (" .. GroupedBombSpawns[GroupName] .. ", compared to average of " .. avgint .. ")")
				elseif AIProportionDeviation > 0.06 and GroupedBombSpawns[GroupName] > AverageAIPerGroup then
					table.insert(ErrorsFound, "Warning: Bomb group '" .. GroupName .. "' has relatively many AI spawns assigned to it (" .. GroupedBombSpawns[GroupName] .. ", compared to average of " .. avgint .. ")")
				end
			end
		end	
	end	
	
	----- phase 3 check insertion points and player starts

	local AllInsertionPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBInsertionPoint')
	if #AllInsertionPoints == 0 then
		table.insert(ErrorsFound, "No insertion points found")
	else
		local AllPlayerStarts = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBPlayerStart')
		if #AllPlayerStarts == 0 then
			table.insert(ErrorsFound, "No player starts found - click Add Player Starts on insertion point(s) to create")
		else
			local InsertionPointHasBlankName = false
			local PlayerStartNoGroup = false
				
			for _, InsertionPoint in ipairs(AllInsertionPoints) do
				local PlayerStartCount = 0
			
				local InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
				if InsertionPointName == "" then
					InsertionPointHasBlankName = true
				end
				
				local InsertionPointTeam = actor.GetTeamId(InsertionPoint)
				if InsertionPointTeam ~= 1 then
					if InsertionPointName == "" then
						table.insert(ErrorsFound, "Unnamed insertion point should have team set to 1")
					else
						table.insert(ErrorsFound, "Insertion point '" .. InsertionPointName .. "' should have team set to 1")
					end
				end
			
				local PlayerStartCount = 0
				
				for __, PlayerStart in ipairs(AllPlayerStarts) do
					local AssociatedInsertionPointName = gamemode.GetInsertionPointName(PlayerStart)
					
					if AssociatedInsertionPointName == "" or  AssociatedInsertionPointName == "None" then
						PlayerStartNoGroup = true
					elseif InsertionPointName ~= "" and AssociatedInsertionPointName == InsertionPointName then	
					-- if playerstart is associated with InsertionPoint
						PlayerStartCount = PlayerStartCount + 1
					end
				end
								
				if PlayerStartCount == 0 then
					table.insert(ErrorsFound, "No player starts provided for insertion point '" .. InsertionPointName .. "'")
				elseif PlayerStartCount < 8 then
					table.insert(ErrorsFound, "Fewer than 8 player starts provided for insertion point '" .. InsertionPointName .. "'")
				elseif PlayerStartCount > 8 then
					table.insert(ErrorsFound, "More than 8 player starts provided for insertion point '" .. InsertionPointName .. "'")
				end
			end
			
			if InsertionPointHasBlankName then
				table.insert(ErrorsFound, "At least one insertion point has a blank name")
			end
			
			if PlayerStartNoGroup then
				table.insert(ErrorsFound, "At least one player start has a blank group name")
			end
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
	end

	--- phase 4 check guard groups
	
	local AllGuardPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAIGuardPoint')
	
	local GuardPointNames = {}
	local GuardPointName
	local GuardPointCount = 0
	
	for _,GuardPoint in ipairs(AllGuardPoints) do
		GuardPointName = ai.GetGuardPointName(GuardPoint)
		if GuardPointName == 'None' then
			table.insert(ErrorsFound, "AI guard point '@" .. actor.GetName(GuardPoint) .. "' has group name set to None")
		else
			if GuardPointNames[GuardPointName] == nil then
				GuardPointNames[GuardPointName] = false
				GuardPointCount = GuardPointCount + 1
			end	
		end
	end

	local DumpGuardPoints = false

	if #AllGuardPoints == 0 then
		table.insert(ErrorsFound, "Warning: no AI guard points found")
	elseif GuardPointCount < GuardSquadCount then
		table.insert(ErrorsFound, "There are fewer groups of guard points (" .. GuardPointCount.. ") than squads set to Guard (" .. GuardSquadCount .. "). Some will be unused. [Dumping guard points and guard squads to log.]")
		DumpGuardPoints = true
	elseif GuardPointCount > GuardSquadCount then
		table.insert(ErrorsFound, "There are more groups of guard points (" .. GuardPointCount.. ") than squads set to Guard (" .. GuardSquadCount .. "). You want a one to one correspondence. [Dumping guard points and guard squads to log.]")
		DumpGuardPoints = true
	end

	if DumpGuardPoints then
		local GuardPointList = {}

		print("GuardPoints")
		print("-----------")
		for GuardPointName, _ in pairs(GuardPointNames) do
			--print (GuardPointName)
			-- create an array where guard point names are the values, not the keys - then we can sort it
			table.insert(GuardPointList, GuardPointName)
		end
		
		local function reversesort_alphabetical(a, b)
		return a:lower() > b:lower()
		end
		table.sort(GuardPointList, reversesort_alphabetical)
	
		for _, GuardPointName in ipairs(GuardPointList) do
			print (GuardPointName)
		end

		print(" ")
		print("Guard squads")
		print("------------")
		for _, CurrentSquad in pairs(SquadsBySquadId) do
			if CurrentSquad.SquadOrders == 'Guard' then
				print(CurrentSquad.CleanName)
			end
		end
	end

	-- new stand-alone collision check for guardpoints

	for i, TestActor in ipairs(AllGuardPoints) do
		if actor.IsColliding(TestActor) then
			table.insert(ErrorsFound, "Warning: AI guard point '@" .. actor.GetName(TestActor) .. "' may be colliding with the map")
		end
		if not ai.IsOnNavMesh(TestActor) then
			table.insert(ErrorsFound, "Warning: AI guard point '@" .. actor.GetName(TestActor) .. "' does not appear to be contacting the navmesh")
		end
	end

	---- phase 5: check patrol routes
	local AllPatrolRoutes = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAIPatrolRoute')
	if #AllPatrolRoutes == 0 then
		table.insert(ErrorsFound, "Warning: no AI patrol routes found")
	end

	-- new stand-alone collision check for patrol routes

	for i, TestActor in ipairs(AllPatrolRoutes) do
		if actor.IsColliding(TestActor) then
			table.insert(ErrorsFound, "Warning: AI patrol route '@" .. actor.GetName(TestActor) .. "' may be colliding with the map")
		end
		if not ai.IsOnNavMesh(TestActor) then
			table.insert(ErrorsFound, "Warning: AI patrol route '@" .. actor.GetName(TestActor) .. "' does not appear to be contacting the navmesh")
		end
	end
	
	-- new!! check line of sight between (centre of) patrol route actors
	local PatrolRoutesChecked = {}
	local IgnoreActors = {}
	
	-- create ignore list containing all AI spawns and all AI patrol routes. Not going to be super efficient but necessary.
	-- (AI spawns are often placed near/between patrol points)
	for _, Actor in ipairs(AllAISpawns) do
		table.insert(IgnoreActors, Actor)
	end
	for _, Actor in ipairs(AllPatrolRoutes) do
		table.insert(IgnoreActors, Actor)
	end

	for _, PatrolRouteActor in ipairs(AllPatrolRoutes) do
		local LinkedPatrolRouteActors = gameplaystatics.GetPatrolRouteLinkedActors(PatrolRouteActor)
		--print("Checking " .. #LinkedPatrolRouteActors .. " connections for patrol route '" .. actor.GetName(PatrolRouteActor) .. "'")
		PatrolRoutesChecked[actor.GetName(PatrolRouteActor)] = true
		
		for __, LinkedPatrolRouteActor in ipairs(LinkedPatrolRouteActors) do
			if PatrolRoutesChecked[actor.GetName(LinkedPatrolRouteActor)] == nil then
				local VisibilityTrace = gameplaystatics.TraceVisible( actor.GetLocation(PatrolRouteActor), actor.GetLocation(LinkedPatrolRouteActor), IgnoreActors, true) 
				if VisibilityTrace ~= nil then
					table.insert(ErrorsFound, "AI patrol route '@" .. actor.GetName(PatrolRouteActor) .. "' appears not to have clear sight of patrol route '" .. actor.GetName(LinkedPatrolRouteActor) .. "'")
				end
			end
		end
	end

	return ErrorsFound
end



return defusevalidate