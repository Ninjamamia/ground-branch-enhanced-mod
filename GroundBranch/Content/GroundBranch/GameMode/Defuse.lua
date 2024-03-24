local defuse = {
	StringTables = { "Defuse" },
	
	GameModeAuthor = "(c) BlackFoot Studios, 2021-2023",
	GameModeType = "PVE",
	
	-- This is a semi-official mode used as a demonstration
	-- of the Ground Branch modding system. Based on the
	-- old PVP Defuse mode
	
	---------------------------------------------
	----- Game Mode Properties ------------------
	---------------------------------------------

	UseReadyRoom = true,
	UseRounds = true,
	VolunteersAllowed = false,
	
	---------------------------------------------
	----- Default Game Rules --------------------
	---------------------------------------------

	AllowUnrestrictedRadio = true,
	AllowUnrestrictedVoice = true,
	SpectateForceFirstPerson = false,
	SpectateFreeCam = true,
	SpectateEnemies = false,
		
	---------------------------------------------
	------- Player Teams ------------------------
	---------------------------------------------
	
	PlayerTeams = {
		BluFor = {
			TeamId = 1,
			Loadout = "NoTeam",
		},
	},
	
	---------------------------------------------
	---- Mission Settings -----------------------
	---------------------------------------------
	
	Settings = {
		OpForCount = {
			Min = 1,
			Max = 50,
			Value = 15,
			AdvancedSetting = false,
		},
		Difficulty = {
			Min = 0,
			Max = 4,
			Value = 2,
			AdvancedSetting = false,
		},
		RoundTime = {
			Min = 5,
			Max = 120,
			Value = 15,
			AdvancedSetting = false,
		},
		DefuseTime = {
			Min = 1,
			Max = 60,
			Value = 10,
			AdvancedSetting = true,
		},
		BombCount = {
			Min = 1,
			Max = 10,
			Value = 2,
			AdvancedSetting = false,
		},
		-- 1 to make watch display alert if in proximity
	},
	
	---------------------------------------------
	---- 'Global' Variables ---------------------
	---------------------------------------------
	
	OpForTeamTag = "OpFor",
	PriorityTags = { "AISpawn_1", "AISpawn_2", "AISpawn_3", "AISpawn_4", "AISpawn_5",
		"AISpawn_6_10", "AISpawn_11_20", "AISpawn_21_30", "AISpawn_31_40", "AISpawn_41_50" },
		
	SpawnPriorityGroupIDs = { "AISpawn_11_20", "AISpawn_31_40" },
	-- these define the start of priority groups, e.g. group 1 = everything up to AISPawn_11_20 (i.e. from AISpawn_1 to AISpawn_6_10), group 2 = AISpawn_11_20 onwards, group 3 = AISpawn_31_40 onwards
	-- everything in the first group is spawned as before. Everything is spawned with 100% certainty until the T count is reached
	-- subsequent priority groups are capped, ensuring that some lower priority AI is spawned, and everything else is randomised as much as possible
	-- so overall the must-spawn AI will spawn (priority group 1) and a random mix of more important and (a few) less important AI will spawn fairly randomly

	SpawnPriorityGroups = {},
	-- this stores the actual groups as separate tables of spawns indexed by priority group
	
	LastSpawnPriorityGroup = 0,
	-- the last priority group in which spawns were found
	
	ProportionOfPriorityGroupToSpawn = 0.7,
	-- after processing all group 1 spawns, a total of N spawns remain. Spawn 70% of those as group 2 , then 70% of the remaining number as group 3, ... (or 100% if no more groups exist) 
	
	TotalNumberOfSpawnsFound = 0,
	-- simple total of spawns placed in all priority groups
		
	AlwaysUseEveryPriorityOneSpawn = false,
	-- if true, priority one spawns will be used up entirely before considering lower priorities
	-- if false, behaviour differs depending on T count and number of P1 spawns. At least N% of spawns will be not P1 spawns, preventing all P1 spawns being used if need be
	MinimumProportionOfNonPriorityOneSpawns = 0.15,
	-- in which case, always use this proportion of non P1 spawns (15% by default), rounded down
		
	PriorityGroupedSpawns = {},
	-- used for old AI spawn method
	
	MissionLocationMarkers = {},
	-- for creating markers on ops board showing all possible bomb locations
	
	BombObjectiveMarkerName = "",
	-- text displayed on search location marker (currently none)
	
	CompletedARound = true,
	
	GroupedBombs = {},
	ActiveBombs = {},
	ShuffledGroupNames = {},
}


function defuse:DumbTableCopy(MyTable)
	local ReturnTable = {}
	
	for Key, TableEntry in ipairs(MyTable) do
		table.insert(ReturnTable, TableEntry)
	end
	
	return ReturnTable
end


function defuse:PreInit()
	local AllSpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
	local PriorityIndex = 1
	local TotalSpawns = 0

	local CurrentPriorityGroup = 1
	local CurrentGroupTotal = 0
	local CurrentPriorityGroupSpawns = {}
	-- this needs to be outside the loop
	
	self.SpawnPriorityGroups = {}

	-- Orders spawns by priority while allowing spawns of the same priority to be randomised.
	for i, PriorityTag in ipairs(self.PriorityTags) do
		local bFoundTag = false
		
		if CurrentPriorityGroup <= #self.SpawnPriorityGroupIDs then
			if PriorityTag == self.SpawnPriorityGroupIDs[CurrentPriorityGroup] then
				-- we found the priority tag corresponding to the start of the next priority group
				self.SpawnPriorityGroups[CurrentPriorityGroup] = self:DumbTableCopy(CurrentPriorityGroupSpawns)
				CurrentPriorityGroup = CurrentPriorityGroup + 1
				CurrentGroupTotal = 0
				CurrentPriorityGroupSpawns = {}
			end
		end

		for j, SpawnPoint in ipairs(AllSpawns) do
			if actor.HasTag(SpawnPoint, PriorityTag) then
				bFoundTag = true
				if self.PriorityGroupedSpawns[PriorityIndex] == nil then
					self.PriorityGroupedSpawns[PriorityIndex] = {}
				end
				-- Ensures we can't spawn more AI then this map can handle.

				TotalSpawns = TotalSpawns + 1 
				table.insert(self.PriorityGroupedSpawns[PriorityIndex], SpawnPoint)
				-- this is the table for the old method, which we may still want to use e.g. at low T counts

				table.insert(CurrentPriorityGroupSpawns, SpawnPoint)
				CurrentGroupTotal = CurrentGroupTotal + 1
				-- also store in the table of spawnpoints for the new method
			end
		end

		-- Ensures we don't create empty tables for unused priorities.
		if bFoundTag then
			PriorityIndex = PriorityIndex + 1
			self.LastSpawnPriorityGroup = CurrentPriorityGroup
		end
	end
	
	self.SpawnPriorityGroups[CurrentPriorityGroup] = CurrentPriorityGroupSpawns
	self.TotalNumberOfSpawnsFound = TotalSpawns
	
	TotalSpawns = math.min(ai.GetMaxCount(), TotalSpawns)
	self.Settings.OpForCount.Max = TotalSpawns
	self.Settings.OpForCount.Value = math.min(self.Settings.OpForCount.Value, TotalSpawns)
	
	-- find and group all bombs

	local AllBombs = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_BigBomb.BP_BigBomb_C')
	local NumGroups = 0

	-- group bombs by actor tag 1:
	
	for i, Bomb in ipairs(AllBombs) do
		local GroupTag = actor.GetTag(Bomb, 1)
		if GroupTag ~= nil then
			if self.GroupedBombs[GroupTag] == nil then
				NumGroups = NumGroups + 1
				self.GroupedBombs[GroupTag] = {}
			end
			table.insert(self.GroupedBombs[GroupTag], Bomb)
		end
		
		--GetLuaComp(Bomb).SetTeam(self.PlayerTeams.BluFor.TeamId)
		-- player team is being detected as 255 not 1, for some reason
		GetLuaComp(Bomb).SetTeam(255)

	end

	-- treat each bomb as its own group if no tags were found:
	
	if NumGroups < 1 then
		NumGroups = #AllBombs
		for i, Bomb in ipairs(AllBombs) do
			self.GroupedBombs[i] = {}
			table.insert(self.GroupedBombs[i], Bomb)
		end
	end

	-- set up shuffled group names, used to pick random bombs to enable
	
	self.ShuffledGroupNames = {}

	for Group, Bombs in pairs(self.GroupedBombs) do
		table.insert(self.ShuffledGroupNames, Group)
	end
		
	self:ShuffleBombs()

	-- now add bomb markers to ops board:

	if NumGroups < 1 then
		-- bombs are not grouped
		
		for i = 1, #self.GroupedBombs do
			local MarkerName = self.BombObjectiveMarkerName
			MarkerName = self:GetModifierTextForObjective( self.GroupedBombs[i] ) .. MarkerName
			-- this checks tags on the specified actor and produces a prefix if appropriate, for interpretation within the WBP_ObjectiveMarker widget

			gamemode.AddObjectiveMarker(actor.GetLocation( self.GroupedBombs[i] ), self.PlayerTeams.BluFor.TeamId, MarkerName, "MissionLocation", true)
		end
		
	else
		-- bombs are grouped
		-- rather than rely on more complex mission setup, just calculate geographical average location of all bombs in the group
		-- and use that to position the intel marker
	
		for Group, BombList in pairs(self.GroupedBombs) do

			local IntelMarkerLocation = {}
			local AverageLocation = {}

			if #BombList > 0 then

				AverageLocation.x = 0
				AverageLocation.y = 0
				AverageLocation.z = 0
				
				for j = 1, #BombList do
					local BombLocation = actor.GetLocation ( BombList[j] )

					AverageLocation.x = AverageLocation.x + BombLocation.x
					AverageLocation.y = AverageLocation.y + BombLocation.y
					AverageLocation.z = AverageLocation.z + BombLocation.z
				end
				
				IntelMarkerLocation.x = AverageLocation.x / #BombList
				IntelMarkerLocation.y = AverageLocation.y / #BombList
				IntelMarkerLocation.z = AverageLocation.z / #BombList
				
				-- now add the marker

				local MarkerName = self.BombObjectiveMarkerName
				MarkerName = self:GetModifierTextForObjective( BombList[1] ) .. MarkerName
				-- this checks tags on the first bomb in the group and produces a prefix if appropriate, for interpretation within the WBP_ObjectiveMarker widget

				gamemode.AddObjectiveMarker(IntelMarkerLocation, self.PlayerTeams.BluFor.TeamId, MarkerName, "MissionLocation", true)
			else
				self:ReportError("No bombs placed in level.")
			end
		end
	end
		
	self.Settings.BombCount.Max = NumGroups
	self.Settings.BombCount.Value = math.min(self.Settings.BombCount.Value, NumGroups)
	
	-- needs ShuffledGroupNames to be set up first (see above)
	self:AddSearchLocationList()
end


function defuse:PostInit()
	gamemode.AddGameObjective(self.PlayerTeams.BluFor.TeamId, "DefuseBombs", 1)
end


function defuse:PlayerInsertionPointChanged(PlayerState, InsertionPoint)
	if InsertionPoint == nil then
		timer.Set("CheckReadyDown", self, self.CheckReadyDownTimer, 0.1, false)
	else
		timer.Set("CheckReadyUp", self, self.CheckReadyUpTimer, 0.25, false)
	end
end


function defuse:PlayerReadyStatusChanged(PlayerState, ReadyStatus)
	if ReadyStatus ~= "DeclaredReady" then
		timer.Set("CheckReadyDown", self, self.CheckReadyDownTimer, 0.1, false)
	end
	
	if ReadyStatus == "WaitingToReadyUp" 
	and gamemode.GetRoundStage() == "PreRoundWait" 
	and gamemode.PrepLatecomer(PlayerState) then
		gamemode.EnterPlayArea(PlayerState)
	end
end


function defuse:CheckReadyUpTimer()
	if gamemode.GetRoundStage() == "WaitingForReady" or gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
	
		local BluForReady = ReadyPlayerTeamCounts[self.PlayerTeams.BluFor.TeamId]
	
		if BluForReady >= gamemode.GetPlayerCount(true) then
			gamemode.SetRoundStage("PreRoundWait")
		elseif BluForReady > 0 then
			gamemode.SetRoundStage("ReadyCountdown")
		end
	end
end


function defuse:CheckReadyDownTimer()
	if gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
	
		if ReadyPlayerTeamCounts[self.PlayerTeams.BluFor.TeamId] < 1 then
			gamemode.SetRoundStage("WaitingForReady")
		end
	end
end


function defuse:OnRoundStageSet(RoundStage)
	print("--defuse:OnRoundStageSet() - new round stage " .. RoundStage)

	if RoundStage == "WaitingForReady" then
		timer.ClearAll()
		ai.CleanUp(self.OpForTeamTag)
		
		if self.CompletedARound then
			self:RandomiseObjectives()
		end
		
		self.CompletedARound = false
			
	elseif RoundStage == "PreRoundWait" then
		self:SpawnOpFor()				
		gamemode.SetDefaultRoundStageTime("InProgress", self.Settings.RoundTime.Value)
		-- need to update this as ops board setting may have changed - have to do this before RoundStage InProgress to be effective
		
	elseif RoundStage == "InProgress" then
		self:ActivateBombs()
		
		--timer.Set("ExplodeBombs", self, self.ExplodeBombs, 3.0, false)
		
	elseif RoundStage == "PostRoundWait" then
		timer.Clear("ShowRemaining")
		self.CompletedARound = true

	end
end


function defuse:OnRoundStageTimeElapsed(RoundStage)
	if RoundStage == "InProgress" then

		local bExploded = false

		for i = 1, #self.ActiveBombs do
			GetLuaComp(self.ActiveBombs[i]).Explode()
			bExploded = true
		end
		
		if bExploded and gamemode.GetRoundStage() ~= 'PostRoundWait' then
			gamemode.AddGameStat("Result=None")
			gamemode.AddGameStat("Summary=BombsDetonated")
			gamemode.SetRoundStage("PostRoundWait")
			self:ExplodeBombs(nil)
			return true
			-- return true = don't do normal processing e.g. set out of time status
		end
	end
end

function defuse:ShuffleBombs()
	-- Shuffle the group names to prevent picking from the same group(s) each round.
	-- call before ActivateBombs()
	
	for i = #self.ShuffledGroupNames, 1, -1 do
		local j = umath.random(i)
		self.ShuffledGroupNames[i], self.ShuffledGroupNames[j] = self.ShuffledGroupNames[j], self.ShuffledGroupNames[i]
	end
end


function defuse:AddSearchLocationList()
	-- This should only need to be done once, after shuffled group names are set up
	
	gamemode.ClearSearchLocations()	
			
	if  #self.ShuffledGroupNames > 5 then
		-- just too many locations
		gamemode.AddSearchLocation(self.PlayerTeams.BluFor.TeamId, "The indicated areas", 1)
	else
		for _, BombGroupName in ipairs(self.ShuffledGroupNames) do
			gamemode.AddSearchLocation(self.PlayerTeams.BluFor.TeamId, BombGroupName, 1)
		end
	end
end

function defuse:ActivateBombs()
	-- ShuffleBombs() should have been called first, to set up self.ShuffledGroupNames
				
	self.ActiveBombs = {}

	local DetonationTime = GetTimeSeconds() + (self.Settings.RoundTime.Value * 60.0)

	for i, GroupName in ipairs(self.ShuffledGroupNames) do
		local ActiveIndex = -1
		
		-- Only require an active index for the number of bombs we want active.
		if i <= self.Settings.BombCount.Value then
			ActiveIndex = umath.random(#self.GroupedBombs[GroupName])
		end
		
		for j = 1, #self.GroupedBombs[GroupName] do
			local Bomb = self.GroupedBombs[GroupName][j]
			if (j == ActiveIndex) then
				table.insert(self.ActiveBombs, Bomb)
				GetLuaComp(Bomb).SetDetonationTime(DetonationTime)
				actor.SetActive(Bomb, true)
				print("Activating bomb '" .. actor.GetName(Bomb) .. "' for zone '" .. GroupName .. "'")
			else
				actor.SetActive(Bomb, false)
			end
		end
	end
	
	-- announce mission objective:
	
	local Message 	
	local FormatTable = {}
	
	FormatTable.FormatString = "DefuseXBombs"
	-- "FormatString" is a reserved and mandatory field name
	-- "format_XBombsRemain" in .csv file references token {NumberRemaining}:
	FormatTable.NumberRemaining = #self.ActiveBombs
	FormatTable.Minutes = self.Settings.RoundTime.Value
	-- important not to convert #OpForControllers to string so that it can be used by the plural() formatting function
	Message = gamemode.FormatString(FormatTable)
	
	gamemode.BroadcastGameMessage(Message, "Upper", 8.0)
	-- negative time causes previous messages to be flushed

end


function defuse:OnBombDamaged(BombActor, DamageAmount)
	-- this is called if anywhere on the bomb is shot or damaged by nades
	-- normally a bullet does 50 damage and a nade may do up to 1000 damage or so
	-- we could measure the cumulative amount of damage, but in this case we allow the barrel to be shot unlimited times
	-- (it is not triggered by bullets?) but any nade in the vicinity means game over
		
	if DamageAmount > 150 and gamemode.GetRoundStage() == 'InProgress' then
		gamemode.AddGameStat("Result=None")
		gamemode.AddGameStat("Summary=BombHit")
		gamemode.SetRoundStage("PostRoundWait")
		self:ExplodeBombs(BombActor)
	end
end


function defuse:OnBombHit(BombActor, BombController)
	-- this is called if the packet on top of the barrel is shot
	
	if BombController == nil then
		-- we should only validly reach this point if we didn't provide an OnBombDamaged() function (we would receive a Hit event instead with nil controller)
		print("BombController was nil")
	else
		if not ai.IsAI(BombController) and gamemode.GetRoundStage() == 'InProgress' then
			-- blow up the bomb that was hit
			-- (for now) we disregard shots by the AI

			gamemode.AddGameStat("Result=None")
			gamemode.AddGameStat("Summary=BombHit")
			gamemode.SetRoundStage("PostRoundWait")
			self:ExplodeBombs(BombActor)
		end
	end
end


function defuse:ExplodeBombs(BombActor)
	-- if BombActor is nil, blow up all bombs - else blow up only BombActor

	if gamemode.GetRoundStage() ~= "PostRoundWait" then
		return
	end

	if BombActor == nil then
		for i = #self.ActiveBombs, 1, -1 do
			local CurrentBomb = self.ActiveBombs[i]
			GetLuaComp(CurrentBomb).Explode()
			actor.SetActive(CurrentBomb, false)
			table.remove(self.ActiveBombs, i)
		end
		
		-- clear table
		--for k in next,tab do 
		--	self.ActiveBombs[k] = nil 
		--end
		self.ActiveBombs = {}
	else
		GetLuaComp(BombActor).Explode()
		actor.SetActive(BombActor, false)
		self:RemoveActiveBomb(BombActor)
	end

	-- blow up all players (ish)

	local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.BluFor.TeamId, 1, false)
	for _, Player in ipairs(PlayersWithLives) do
		player.SpawnEffectAtPlayer(Player, '/Game/GroundBranch/Inventory/Grenade/Explosions/BP_Explosion_StunLocal.BP_Explosion_StunLocal_C')
		--player.Kill(Player)
	end
	
	-- blow up AI (ish)
	
	local OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, 255, 255)
	-- v1034: class type of nil now uses default controller type (kythera now)
	
	for _, AIController in ipairs(OpForControllers) do
		ai.KillAI(AIController)
	end
	
	timer.Set("KillEveryLivePlayer", self, self.KillEveryLivePlayerTimer, 1.5, false)
end


function defuse:KillEveryLivePlayerTimer()
	-- defer killing players to give the stun effect some time to play out
	local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.BluFor.TeamId, 1, false)
	for _, Player in ipairs(PlayersWithLives) do
		player.Kill(Player)
	end
end


function defuse:RandomiseObjectives()
	-- called to reset and randomise the mission objectives

	-- first, select and initialise the active bombs
	self:ShuffleBombs()
end


function defuse:ReportError(ErrorMessage)
	gamemode.BroadcastGameMessage("Error! " .. ErrorMessage, "Upper", 5.0)
	print("-- Defuse game mode error!: " .. ErrorMessage)
end


function defuse:AddToTableIfNotAlreadyPresent( AllLocationNames, NewLocationName )
	if NewLocationName ~= nil then
		for _, LocationName in ipairs(AllLocationNames) do
			if LocationName == NewLocationName then
				return
			end
		end

		table.insert( AllLocationNames, NewLocationName )
	end
end


function defuse:IsItemInTable( TableToCheck, ItemToCheck )
	-- not actually used right now
	for _, TableItem in ipairs(TableToCheck) do
		if TableItem == ItemToCheck then
			return true
		end
	end
	return false
end


function defuse:SpawnOpFor()
	local OrderedSpawns = {}

	local RejectedSpawns = {}
	local Group 
	local AILeftToSpawn

	local ProcessAITagsOnFirstPass = {}
	-- tags to spawn on the first pass, which wouldn't normally spawn

	local IgnoreAITagsOnSecondPass = {}
	-- tags to ignore on the second pass (which will include all of ProcessAITagsOnFirstPass)
	
	-- first add bomb location names to the selected/excluded tags list (ProcessAITagsOnFirstPass, IgnoreAITagsOnSecondPass)
	if  #self.ShuffledGroupNames > 0 then
		for i = 1, #self.ShuffledGroupNames do
			if i <= self.Settings.BombCount.Value then
				table.insert(ProcessAITagsOnFirstPass, self.ShuffledGroupNames[i])	
			end

			table.insert(IgnoreAITagsOnSecondPass, self.ShuffledGroupNames[i])
		end
	end

	-- we're now setup to add optional/conditional AI for the selected bombs' zones only
	-- the optional AI is added on Pass 1 (to ensure all spawns). Normal spawning proceeds in Pass 2.

	for SpawnOpForPass = 1, 2 do
	-- pass 1: add AI with tag equal to current active bombs (>1 usually)
	-- pass 2: add everything else

		for CurrentPriorityGroup = 1, self.LastSpawnPriorityGroup do
		
			AILeftToSpawn =  math.max( 0, self.Settings.OpForCount.Value - #OrderedSpawns )
			-- this will be zero if the T count is already reached
			
			local CurrentAISpawnTarget 
			-- number of spawns to try and add from this priority group
			
			-- determine how many spawns we're aiming for:
			if AILeftToSpawn > 0 then
				if CurrentPriorityGroup == 1 then
					if self.AlwaysUseEveryPriorityOneSpawn then
						CurrentAISpawnTarget = AILeftToSpawn
					else
						CurrentAISpawnTarget = math.ceil( AILeftToSpawn * (1 - self.MinimumProportionOfNonPriorityOneSpawns) )
						-- leave a few slots spare for lower priorities (default 15%)
						-- if the number of priority 1 spawns is lower than this number, then all priority 1 spawns will be used
						-- (this only has an effect if there are lots of P1 spawns and not a big T count)
					end
					
				elseif CurrentPriorityGroup == self.LastSpawnPriorityGroup then
					CurrentAISpawnTarget = AILeftToSpawn
					-- if this is the first group, or the last group, then try spawn all of the AI
					
				else
					local CurrentNumberOfSpawns = #self.SpawnPriorityGroups[CurrentPriorityGroup]
					local RemainingSpawnsInLowerPriorities = math.max( 0, self.TotalNumberOfSpawnsFound - CurrentNumberOfSpawns - #OrderedSpawns)
					local CurrentProportionOfSpawnsLeft =  CurrentNumberOfSpawns / ( CurrentNumberOfSpawns + (RemainingSpawnsInLowerPriorities * self.ProportionOfPriorityGroupToSpawn) ) 
					-- spawn a suitable number of spawns in dependence on the number of spawns in this group vs number of spawns remaining in lower groups, but fudge it to be bigger than the actual proportion
					
					CurrentAISpawnTarget = math.ceil(AILeftToSpawn * CurrentProportionOfSpawnsLeft)
				end
			else
				CurrentAISpawnTarget = 0
				-- no AI left to spawn so don't bother spawning any - just dump straight into RejectedSpawns{}
			end

			-- now transfer the appropriate number of spawns (randomly picked) to the target list (OrderedSpawns)
			-- and dump the remainder in the RejectedSpawns table (to be added to the end of the target list once completed)
			
			Group = self.SpawnPriorityGroups[CurrentPriorityGroup]

			if Group == nil then
				print("SpawnOpFor(): Table entry for priority group " .. CurrentPriorityGroup.. " was unexpectedly nil")
			else

				if #Group > 0 then
					for i = #Group, 1, -1 do

						if SpawnOpForPass == 1 then
							-- only shuffle once, on pass 1
							-- this pass is to add conditional spawns for current bomb locations
							
							local j = umath.random(i)
							Group[i], Group[j] = Group[j], Group[i]
						
							if self:ActorHasTagInList( Group[i], ProcessAITagsOnFirstPass ) then
							-- add the spawns if they have the tag matching the current bomb zones
							
								if CurrentAISpawnTarget > 0 then
									table.insert(OrderedSpawns, Group[i])
									CurrentAISpawnTarget = CurrentAISpawnTarget - 1
								else
									table.insert(RejectedSpawns, Group[i])
								end
							
							end
						
						else
						-- opfor pass 2, for anything without an insertion point tag

							if not self:ActorHasTagInList( Group[i], IgnoreAITagsOnSecondPass ) then
							-- this pass for anything which wasn't associated with current bomb zones, and also excluding any other conditional spawns

								if CurrentAISpawnTarget > 0 then
									table.insert(OrderedSpawns, Group[i])
									CurrentAISpawnTarget = CurrentAISpawnTarget - 1
								else
									table.insert(RejectedSpawns, Group[i])
								end
			
							end
						end
						
					end
						
				else
					print("SpawnOpFor(): Priority group " .. CurrentPriorityGroup.. " was unexpectedly empty")
				end
				
			end
					
		end
					
	end
	
	-- now add all the rejected spawns onto the list, in case extra spawns are needed
	-- if we ran out of spawns in the above process, this will still provide a sensible selection of spawns
		
	for i = 1, #RejectedSpawns do
		table.insert(OrderedSpawns, RejectedSpawns[i])
	end

	ai.CreateOverDuration(4.0, math.min( self.Settings.OpForCount.Value, #OrderedSpawns), OrderedSpawns, self.OpForTeamTag)
	-- OrderedSpawns may be smaller than expected because of the conditional spawning, so just use the size of that list directly. It won't be bigger than self.Settings.OpForCount.Value.
end


function defuse:ActorHasTagInList( CurrentActor, TagList ) 
	if CurrentActor == nil then
		print("defuse:ActorHasTagInList(): CurrentActor unexpectedly nil")
		return false
	end
	if TagList == nil then
		print("defuse:ActorHasTagInList(): TagList unexpectedly nil")
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


function defuse:ValueIsInTable(Table, Value)
	if Table == nil then
		print("defuse:ValueIsInTable(): Table unexpectedly nil")
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


function defuse:OnCharacterDied(Character, CharacterController, KillerController)
	print("Defuse:OnCharacterDied()")
	
	if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
		if CharacterController ~= nil then
			if not ai.IsAI(CharacterController, self.OpForTeamTag) then
				player.SetLives(CharacterController, player.GetLives(CharacterController) - 1)
				
				local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.BluFor.TeamId, 1, false)
				if #PlayersWithLives == 0 then
					self:CheckBluForCountTimer()
					-- call immediately because round is about to end and nothing more can happen
				else
					timer.Set("CheckBluForCount", self, self.CheckBluForCountTimer, 1.0, false)
				end
			end
		end
	end
end


function defuse:CheckBluForCountTimer()
	local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.BluFor.TeamId, 1, false)
	if #PlayersWithLives == 0 and gamemode.GetRoundStage() ~= 'PostRoundWait' then
		gamemode.AddGameStat("Result=None")
		gamemode.AddGameStat("Summary=BluForEliminated")
		gamemode.SetRoundStage("PostRoundWait")
	end
end


function defuse:ShouldCheckForTeamKills()
	if gamemode.GetRoundStage() == "InProgress" then
		return true
	end
	return false
end


function defuse:PlayerCanEnterPlayArea(PlayerState)
	if player.GetInsertionPoint(PlayerState) ~= nil then
		return true
	end
	return false
end


function defuse:RemoveActiveBomb(Bomb)
	for i = #self.ActiveBombs, 1, -1 do
		if self.ActiveBombs[i] == Bomb then
			table.remove(self.ActiveBombs, i)
		end
	end
end


function defuse:BombDefused(Bomb)
	self:RemoveActiveBomb(Bomb)

	if #self.ActiveBombs < 1 then
		timer.Clear("ShowRemaining")
		gamemode.AddGameStat("Result=Team1")
		gamemode.AddGameStat("Summary=DefusedBombs")
		gamemode.AddGameStat("CompleteObjectives=DefuseBombs")
		gamemode.SetRoundStage("PostRoundWait")
	else
		timer.Set("ShowRemaining", self, self.ShowRemainingTimer, 2, false)
		
		local Message 	
		local FormatTable = {}
		
		FormatTable.FormatString = "BombDefusedXLeft"
		-- "FormatString" is a reserved and mandatory field name
		-- "format_BombDefusedXLeft" in .csv file references token {NumberRemaining}:
		FormatTable.NumberRemaining = #self.ActiveBombs
		-- important not to convert #OpForControllers to string so that it can be used by the plural() formatting function
		Message = gamemode.FormatString(FormatTable)
		gamemode.BroadcastGameMessage(Message, "Upper", 5.0)
		-- negative time causes previous messages to be flushed
		
		-- (this format process will be changed soon so that it localises)
	end
end


function defuse:ShowRemainingTimer()
	local Message 	
	local FormatTable = {}
	
	FormatTable.FormatString = "XBombsRemain"
	-- "FormatString" is a reserved and mandatory field name
	-- "format_XBombsRemain" in .csv file references token {NumberRemaining}:
	FormatTable.NumberRemaining = #self.ActiveBombs
	-- important not to convert #OpForControllers to string so that it can be used by the plural() formatting function
	Message = gamemode.FormatString(FormatTable)
	
	gamemode.BroadcastGameMessage(Message, "Engine", -10.0)
	-- negative time causes previous messages to be flushed
	
	-- (this format process will be changed soon so that it localises)
end


function defuse:OnMissionSettingsChanged(ChangedSettingsTable)
	-- NB this may be called before some things are initialised
	-- need to avoid infinite loops by setting new mission settings
	if ChangedSettingsTable['BombCount'] ~= nil then
		self:RandomiseObjectives()
	end
end


function defuse:LogOut(Exiting)
	if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
		timer.Set("CheckBluForCount", self, self.CheckBluForCountTimer, 1.0, false);
	end
end


function defuse:GetModifierTextForObjective( TaggedActor )
	-- consider moving to gamemode
			
	if actor.HasTag( TaggedActor, "AddUpArrow") then
		return "(U)" 
	elseif actor.HasTag( TaggedActor, "AddDownArrow") then
		return "(D)" 
	elseif actor.HasTag( TaggedActor, "AddUpStaircase") then
		return "(u)" 
	elseif actor.HasTag( TaggedActor, "AddDownStaircase") then
		return "(d)"
	elseif actor.HasTag( TaggedActor, "Add1") then
		return "(1)" 
	elseif actor.HasTag( TaggedActor, "Add2") then
		return "(2)" 
	elseif actor.HasTag( TaggedActor, "Add3") then
		return "(3)"
	elseif actor.HasTag( TaggedActor, "Add4") then
		return "(4)" 
	elseif actor.HasTag( TaggedActor, "Add5") then
		return "(5)" 
	elseif actor.HasTag( TaggedActor, "Add6") then
		return "(6)" 
	elseif actor.HasTag( TaggedActor, "Add7") then
		return "(7)" 
	elseif actor.HasTag( TaggedActor, "Add8") then
		return "(8)" 
	elseif actor.HasTag( TaggedActor, "Add9") then
		return "(9)" 
	elseif actor.HasTag( TaggedActor, "Add0") then
		return "(0)" 
	elseif actor.HasTag( TaggedActor, "Add-1") then
		return "(-)"
	elseif actor.HasTag( TaggedActor, "Add-2") then
		return "(=)"
	end
		
	return ""
end


return defuse