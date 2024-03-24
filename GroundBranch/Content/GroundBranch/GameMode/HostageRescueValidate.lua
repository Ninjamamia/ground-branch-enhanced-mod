local hostagerescuevalidate = {
}

-- (c) BlackFoot Studios, 2023


function hostagerescuevalidate:ActorHasTagInList( CurrentActor, TagList ) 
	if CurrentActor == nil then
		print("intelretrievalvalidate:ActorHasTagInList(): CurrentActor unexpectedly nil")
		return false
	end
	if TagList == nil then
		print("intelretrievalvalidate:ActorHasTagInList(): TagList unexpectedly nil")
		return false
	end

	local ActorTags = actor.GetTags ( CurrentActor )
	for _, Tag in ipairs ( ActorTags ) do
		if self:ValueIsInTable( TagList, Tag ) then
			return true
		end
	end
	return false
end							


function hostagerescuevalidate:ValueIsInTable(Table, Value)
	if Table == nil then
		print("intelretrievalvalidate:ValueIsInTable(): Table unexpectedly nil")
		return false
	end
	
	for _, val in ipairs(Table) do
		if Value == nil then
			if val == nil then
				return true
			end
		else
			if val == Value then
				return true
			end
		end
	end
	return false
end


function hostagerescuevalidate:ValidateLevel()
	-- new feature to help mission editor validate levels

	local ErrorsFound = {}
		
	----- phase 1 check insertion points and player starts

	local AllAttackerInsertionPointNames = {}
	local AllDefenderInsertionPointNames = {}
	local IsDefenderInsertionPoint = false
	local DefenderInsertionPointLookup = {}

	local AllInsertionPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBInsertionPoint')
	if #AllInsertionPoints == 0 then
		table.insert(ErrorsFound, "No insertion points found")
	else
		local AllPlayerStarts = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBPlayerStart')
		if #AllPlayerStarts == 0 then
			table.insert(ErrorsFound, "No player starts found - click Add Player Starts on insertion point(s) to create")
		else
					
			for _, InsertionPoint in ipairs(AllInsertionPoints) do
			
				local PlayerStartCount = 0
			
				local InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
				if InsertionPointName == "" then
						table.insert(ErrorsFound, "Insertion point '@" .. actor.GetName(InsertionPoint) .. "' has a blank name")
				else
										
					if actor.HasTag(InsertionPoint, "Attackers") then
						IsDefenderInsertionPoint = false
						table.insert(AllAttackerInsertionPointNames, InsertionPointName)
					elseif actor.HasTag(InsertionPoint, "Defenders") then
						IsDefenderInsertionPoint = true
						table.insert(AllDefenderInsertionPointNames, InsertionPointName)
						DefenderInsertionPointLookup[InsertionPointName] = 0
					else
						IsDefenderInsertionPoint = false
						table.insert(ErrorsFound, "Insertion point '@" .. actor.GetName(InsertionPoint) .. "' is not tagged as 'Attackers' or 'Defenders'")
					end
				end
			
				local PlayerStartCount = 0
				
				for __, PlayerStart in ipairs(AllPlayerStarts) do
					local AssociatedInsertionPointName = gamemode.GetInsertionPointName(PlayerStart)
					
					if AssociatedInsertionPointName == "" or  AssociatedInsertionPointName == "None" then
						table.insert(ErrorsFound, "Player start '@" .. actor.GetName(PlayerStart) .. "' has a blank group name")
					elseif InsertionPointName ~= "" and AssociatedInsertionPointName == InsertionPointName then	
					-- if playerstart is associated with InsertionPoint
						PlayerStartCount = PlayerStartCount + 1
					end
				end
					
				-- player insertion point
				if PlayerStartCount == 0 then
					table.insert(ErrorsFound, "No player starts provided for insertion point '" .. InsertionPointName .. "'")
				end
				
				if IsDefenderInsertionPoint then
					if PlayerStartCount < 16 then
						table.insert(ErrorsFound, "Fewer than 12 player starts provided for insertion point '" .. InsertionPointName .. "' (at least 12 is recommended for defender insertion points)")
					elseif PlayerStartCount > 16 then
						table.insert(ErrorsFound, "More than 16 player starts provided for insertion point '" .. InsertionPointName .. "'")
					end
				else
					if PlayerStartCount < 8 then
						table.insert(ErrorsFound, "Fewer than 8 player starts provided for insertion point '" .. InsertionPointName .. "' (at least 12 is recommended)")
					elseif PlayerStartCount > 8 then
						table.insert(ErrorsFound, "More than 8 player starts provided for insertion point '" .. InsertionPointName .. "'")
					end
				end
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
		
		if #AllAttackerInsertionPointNames == 0 then
			table.insert(ErrorsFound, "No insertion points provided for attacking team (-> add 'Attackers' tag to insertion point - team ID is disregarded)")
		end
		if #AllDefenderInsertionPointNames == 0 then
			table.insert(ErrorsFound, "No insertion points provided for defending team (-> add 'Defenders' tag to insertion point - team ID is disregarded)")
		end
	end
	
	--- phase 2 check hostage spawns

	local AllHostageSpawns = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_HostageSpawn.BP_HostageSpawn_C')

	for _, HostageSpawn in ipairs(AllHostageSpawns) do

		local FoundHostageSpawn = false
		
		local SpawnTags = actor.GetTags(HostageSpawn)
		for _, SpawnTag in ipairs(SpawnTags) do
			FoundHostageSpawn = true
			if DefenderInsertionPointLookup[SpawnTag] ~= nil then
				DefenderInsertionPointLookup[SpawnTag] = DefenderInsertionPointLookup[SpawnTag] + 1
			end
		end
		
		if not FoundHostageSpawn then
			table.insert(ErrorsFound, "Could not find matching insertion point for hostage spawn '@" .. actor.GetName(HostageSpawn) .. "'")
		end
	end
	
	for IPName, SpawnCount in pairs(DefenderInsertionPointLookup) do
		if SpawnCount == 0 then
			table.insert(ErrorsFound, "Could not find matching hostage spawn for insertion point " .. IPName)
		elseif SpawnCount > 1 then
			table.insert(ErrorsFound, "Found more than one hostage spawn (" .. SpawnCount .. ") for insertion point " .. IPName)
		end
		
		DefenderInsertionPointLookup[IPName] = 0
		-- reset the lookup table for later phases
	end
	
	-- new standalone check on collision for hostage spawns
	-- MF 2024/1/13 - collision check seems not to work?

	for i, TestActor in ipairs(AllHostageSpawns) do
		if actor.IsColliding(TestActor) then
			table.insert(ErrorsFound, "Warning: Hostage spawn '@" .. actor.GetName(TestActor) .. "' may be colliding with the map")
		end
		if not ai.IsOnNavMesh(TestActor) then
			table.insert(ErrorsFound, "Warning: Hostage spawn '@" .. actor.GetName(TestActor) .. "' does not appear to be contacting the navmesh")
		end
	end
	
	--- phase 3 check spawn protection volumes
	
	local AllSPV = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBSpawnProtectionVolume')
	if #AllSPV == 0 then
		table.insert(ErrorsFound, "No spawn protection volumes found (NB TeamID for volumes is disregarded - it is automatically set by game script each round)")
	end
	
	for _, SPV in ipairs(AllSPV) do
		if not gamemode.GetSpawnProtectionVolumeHasNoImmunity(SPV) then
			table.insert(ErrorsFound, "Spawn protection volume '@" .. actor.GetName(SPV) .. "' does not have property 'No Immunity to Enemy' set to true.")
		end
	end
		
	--- phase 4 check extraction points
	
	local AllExtractionPoints = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C')

	local AllExtractionMarkerNames = {}
	local ExtractionPointLookup = {}

	if #AllExtractionPoints == 0 then
		table.insert(ErrorsFound, "No extraction points defined")
	else
		for _,ExtractionPoint in ipairs(AllExtractionPoints) do
			local ExtractionPointTags = actor.GetTags( ExtractionPoint )
			
			local FoundAttackerInsertionPointName = false
			
			for __, Tag in ipairs(ExtractionPointTags) do
				if Tag == "None" then
					table.insert(ErrorsFound, "Extraction point '@" .. actor.GetName(ExtractionPoint) .. "' has a blank tag")
				elseif self:ValueIsInTable( AllAttackerInsertionPointNames, Tag) then
					FoundAttackerInsertionPointName = true
					ExtractionPointLookup[ Tag ] = true
				end
			end
			
			if not FoundAttackerInsertionPointName then
				table.insert(ErrorsFound, "Extraction point '@" .. actor.GetName(ExtractionPoint) .. "' is not associated with an attacker insertion point")
			end
		end
	end
	
	for _, InsertionPointName in ipairs(AllAttackerInsertionPointNames) do
		if InsertionPointName ~= nil and ExtractionPointLookup[ InsertionPointName ] == nil then
			table.insert(ErrorsFound, "Insertion point '" .. InsertionPointName .. "' has no associated extraction point")
		end
	end
	
	--- phase 5 check game triggers
	
	local AllGameTriggers = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBGameTrigger')
	local AllHostageTriggers = {}
	
	local HostageTriggerCount = 0
	local OtherTriggerCount = 0
	
	for _, GameTrigger in ipairs(AllGameTriggers) do
		if actor.HasTag(GameTrigger, "HostageTrigger") then
			table.insert(AllHostageTriggers, GameTrigger)
			HostageTriggerCount = HostageTriggerCount + 1
		else
			if not self:ValueIsInTable( AllExtractionPoints, GameTrigger) 
			and not self:ValueIsInTable( AllHostageSpawns, GameTrigger) then
				OtherTriggerCount = OtherTriggerCount + 1
				table.insert(ErrorsFound, "GameTrigger '@" .. actor.GetName(GameTrigger) .. "' has no 'HostageTrigger' tag")
			end
		end
	end
	
	if HostageTriggerCount == 0 then
		table.insert(ErrorsFound, "No hostage triggers (GameTrigger objects with 'HostageTrigger' tag) found")
	end

	if OtherTriggerCount > 0 then
		table.insert(ErrorsFound, "Found " .. OtherTriggerCount .. " GameTrigger objects without a 'HostageTrigger' tag")
	end
	
	--- phase 6 check defender blockers
	
	local AllBlockers = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_MissionBlockingVolume.BP_MissionBlockingVolume_C')
	AllDefenderBlockers = {}
	
	for _, Blocker in ipairs(AllBlockers) do
		if actor.HasTag(Blocker, "HostageBlocker") then
			table.insert(AllDefenderBlockers, Blocker)
		end
	end
	
	if #AllDefenderBlockers == 0 then
		table.insert(ErrorsFound, "No defender blockers (MissionBlockingVolume objects with 'HostageBlocker' tag) found")
	end
	
	if #AllBlockers > #AllDefenderBlockers then
		table.insert(ErrorsFound, "Warning: found " .. #AllBlockers - #AllDefenderBlockers .. " MissionBlockingVolume objects without a 'HostageBlocker' tag")
	end
	
	--- phase 7 check AI spawns
	
	local AllAISpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
	
	if #AllAISpawns == 0 then
		table.insert(ErrorsFound, "Could not find any AI spawns")
	end
		
	for _, AISpawn in ipairs(AllAISpawns) do

		local FoundAISpawn = false
		
		local SpawnTags = actor.GetTags(AISpawn)
		for _, SpawnTag in ipairs(SpawnTags) do
			FoundAISpawn = true
			if DefenderInsertionPointLookup[SpawnTag] ~= nil then
				DefenderInsertionPointLookup[SpawnTag] = DefenderInsertionPointLookup[SpawnTag] + 1
			end
		end
		
		if not FoundAISpawn then
			table.insert(ErrorsFound, "Could not find matching insertion point for AI spawn '@" .. actor.GetName(AISpawn) .. "'")
		end
	end
	
	for IPName, SpawnCount in pairs(DefenderInsertionPointLookup) do
		if SpawnCount == 0 then
			table.insert(ErrorsFound, "Could not find matching AI spawn point for insertion point " .. IPName)
		elseif SpawnCount > 1 then
			table.insert(ErrorsFound, "Found more than one AI spawn point (" .. SpawnCount .. ") for insertion point " .. IPName)
		end
		
		DefenderInsertionPointLookup[IPName] = 0
		-- reset the lookup table for later phases
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
	
	--- phase 8 check AI guard points
	
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

	if #AllGuardPoints == 0 then
		table.insert(ErrorsFound, "Warning: no AI guard points found")
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
	
	---- phase 9: check patrol routes
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

return hostagerescuevalidate