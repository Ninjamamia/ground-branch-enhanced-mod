local hostagerescue = {
	StringTables = { "hostagerescue" },
	
	GameModeAuthor = "(c) BlackFoot Studios, 2023",
	GameModeType = "PVP",
	GameModeImage = "",

	-- Hostage Rescue is based on a role-played game mode
	-- that Unit ran on their server. Many thanks to all
	-- for unwittingly letting us benefit from your hard work.

	-- Also many thanks to our dedicated playtesters
	-- for chewing through loads of annoying bugs
	-- and helping us deliver the finished product.

	---------------------------------------------
	----- Game Mode Properties ------------------
	---------------------------------------------

	UseReadyRoom = true,
	UseRounds = true,
	VolunteersAllowed = true,	
	
	---------------------------------------------
	----- Default Game Rules --------------------
	---------------------------------------------

	AllowUnrestrictedRadio = false,
	AllowUnrestrictedVoice = false,
	SpectateForceFirstPerson = true,
	SpectateFreeCam = false,
	SpectateEnemies = false,
	
	---------------------------------------------
	------- Player Teams ------------------------
	---------------------------------------------

	PlayerTeams = {
		Blue = {
			TeamId = 1,
			Loadout = "Blue",
		},
		Red = {
			TeamId = 2,
			Loadout = "Red",
		},
	},
	
	---------------------------------------------
	---- Mission Settings -----------------------
	---------------------------------------------
	
	Settings = {
		RoundTime = {
			Min = 2,
			Max = 30,
			Value = 10,
			AdvancedSetting = false,
		},
		-- number of minutes in each round (default: 10)
		
		DefenderSetupTime = {
			Min = 5,
			Max = 30,
			Value = 15,
			AdvancedSetting = true,
		},
		-- number of seconds before flag is placed after hostage is assigned (default: 15)
		
		AutoSwap = {
			Min = 0,
			Max = 1,
			Value = 1,
			AdvancedSetting = true,
		},
		-- automatically swap teams around at end of round? (default: yes)

		ForceHostageRescue = {
			Min = 0,
			Max = 2,
			Value = 0,
			AdvancedSetting = false,
		},
		-- new: 0 = don't force game mode, 1 = force hostage rescue, 2 = force building assault
		
		BalanceTeams = {
			Min = 0,
			Max = 3,
			Value = 3,
			AdvancedSetting = false,
		},
		-- settings: 
		-- 0 - off
		-- 1 - light touch
		-- 2 - aggressive
		-- 3 - always
		-- move players around to even up teams. For autobalance 'always', if an odd number of players, give the 1 extra to the attackers each round
		-- (pick a random player to move but try to avoid moving the same person twice or more in a row)
		
		ExtractAnywhere = {
			Min = 0,
			Max = 1,
			Value = 1,
			AdvancedSetting = true,
		},
		-- if 1, all extraction points are enabled after attackers spawn in
		-- otherwise an extraction point is selected and displayed before round begins
		
		RestrictDefenders = {
			Min = 0,
			Max = 1,
			Value = 1,
			AdvancedSetting = true,
		},
		-- if 1, there is a physical block around the spawn building for defenders during defender setup time
		-- otherwise defenders can move buildings during setup time (though they will have spawn protection effects between buildings)
	},
	
--		RestrictNades = {
--			Min = 0,
--			Max = 1,
--			Value = 0,
--			AdvancedSetting = true,
--		},
--		-- if 1, purge nades from all loadouts (attackers and defenders)
--	},

	
	ServerSettings = {
	-- TODO this table is currently not used (by the GB infrastructure) - but maybe at some point these will be settable at the server configuration level
		
		BuildingAssaultSetupTime = {
			Min = 3,
			Max = 20,
			Value = 10,
		},
	},


	---------------------------------------------
	-- general game mode settings/variables -----
	---------------------------------------------

	CurrentHostageRescueGameMode = "HostageRescue",

	DefendingTeam = nil,
	AttackingTeam = nil,
	
	StartingDefendingTeamSize = nil,
	StartingAttackingTeamSize = nil,
	
	CompletedARound = false,
	AbandonedRound = false,
	-- used to determine whether to tell players that they swapped round

	AutoSwap = true,
	AutoSwapCount = 0,

	HighlightMovingTargetInterval = 0.15,
	-- how often to update the moving highlight on hostage for defenders

	MovingTarget = nil,
	-- the player/AI to target with the highlight
	
	AutoBalanceLightTouchSetting = 0.19,
	NumberOfPastTeamMovementsToTrack = 6,
	
	CurrentRoundNumber = 0,		
	
	MinPlayersForHostageRescue = 5,
	-- below this number of players, fall back to building assault (unless always hostage rescue is selected, though even that requires a minimum of 3)
	
	---------------------------------------------
	----- UI stuff ------------------------------
	---------------------------------------------
		
	ScreenPositionRoundInfo = "Lower",
	ScreenPositionScoring = "Lower",
	ScreenPositionError = "Upper",
	ScreenPositionAuxiliaryInfo = "Upper",
	ScreenPositionSetupStatus = "Engine",
	-- "Upper",
	-- TODO "Engine",
	
	TeamBalancingMessageDuration = 8.0,
	PreRoundWaitWelcomeCount = 0,	
	
	---------------------------------------------
	----- Hostage Rescue mode stuff -------------
	---------------------------------------------

	CurrentHostage = nil,
	-- the playerstate of the person or AI who is the currently selected hostage. Only relevant during HostageRescueSetup round

	HostageIsArmed = false,
	-- true if the hostage has picked up a gun or similar

	PastHostages = {},
	NumberOfPastHostagesToTrack = 4,
	-- this tracks previous selections of hostage to avoid (if possible) selecting the same person in consecutive rounds

	-- only apply the hostage loadout if this is true
	ApplyHostageLoadout = false,
	
	HostageHasEscaped = false,
	TeamExfilWarning = false,

	---------------------------------------------
	----- building assault stuff ----------------
	---------------------------------------------
	
	BuildingAssaultTimeMultiple = 0.7,
	-- this is the proportion of the normal round time to use for building assaults
	-- roundish number preferred because it messes up the time remaining countdown

	---------------------------------------------
	-- custom scoring stuff ---------------------
	---------------------------------------------
	
	-- player score types includes score types for both attacking and defending players
	PlayerScoreTypes = {
		SurvivedRound = {
			Score = 1,
			OneOff = true,
			Description = "Survived round",
		},
		WonRound = {
			Score = 5,
			OneOff = true,
			Description = "Team won the round",
		},
		Killed = {
			Score = 1,
			OneOff = false,
			Description = "Kills",
		},
		KilledHostage = {
			Score = -15,
			OneOff = true,
			Description = "Killed the hostage",
		},
		KilledArmedHostage = {
			Score = 15,
			OneOff = true,
			Description = "Killed an armed hostage",
		},
		KilledAsArmedHostage = {
			Score = -20,
			OneOff = true,
			Description = "Was killed while armed",
		},
		LastKill = {
			Score = 1,
			OneOff = true,
			Description = "Got last kill of the round",
		},		
		InRangeOfKill = {
			Score = 1,
			OneOff = false,
			Description = "In proximity of someone who killed",
		},
		TeamKill = {
			Score = -4,
			OneOff = false,
			Description = "Team killed!",
		},
		UnboundHostage = {
			Score = 2,
			OneOff = true,
			Description = "Freed the hostage",
		},
		RescuedHostage = {
			Score = 15,
			OneOff = true,
			Description = "Successfully extracted the hostage",
		},		
		-- now some building assault scoring
		ClearedBuilding = {
			Score = 2,
			OneOff = true,
			Description = "Cleared the building",
		},	
		SurvivingDefender = {
			Score = 10,
			OneOff = true,
			Description = "Survived the attack as building defender",
		},
		SurvivingDefenderByTime = {
			Score = 5,
			OneOff = true,
			Description = "Survived as building defender until round time-out",
		},
	},
		
	-- team score types includes scores for both attackers and defenders
	TeamScoreTypes = {
		WonRound = {
			Score = 2,
			OneOff = true,
			Description = "Team won the round",
		},
		DefenderTimeout = {
			Score = 6,
			OneOff = true,
			Description = "Defenders held hostage until end of time limit",
		},
		Killed = {
			Score = 1,
			OneOff = false,
			Description = "Kills by team",
		},
		InRangeOfKill = {
			Score = 1,
			OneOff = false,
			Description = "Team member in proximity of someone who killed",
		},		
		TeamKill = {
			Score = -4,
			OneOff = false,
			Description = "Team kills",
		},
		UnboundHostage = {
			Score = 3,
			OneOff = true,
			Description = "Team released the hostage",
		},
		RescuedHostage = {
			Score = 10,
			OneOff = true,
			Description = "Team rescued the hostage",
		},
		KilledHostage = {
			Score = -10,
			OneOff = true,
			Description = "Your team killed the hostage",
		},	
		KilledArmedHostage = {
			Score = 15,
			OneOff = true,
			Description = "Killed an armed hostage",
		},
		KilledAsArmedHostage = {
			Score = -20,
			OneOff = true,
			Description = "Allow hostage to be killed while armed",
		},
	-- now some building assault scoring
		DefenderKilled = {
			Score = 2,
			OneOff = true,
			Description = "Building Defender was killed",
		},
		DefenderSurvived = {
			Score = 2,
			OneOff = true,
			Description = "Building Defender survived",
		},
		DefenderSurvivedByTime = {
			Score = 2,
			OneOff = true,
			Description = "Building Defender survived until round time-out",
		},
	},
	
	
	ScoringKillProximity = 10,
	-- how near a player has to be to another to count as 'near' for a killing (in metres)
	-- was 7.5
	
	LastKiller = nil,
	-- playerstate of last player to kill someone
		
	---------------------------------------------
	------------- AI stuff ----------------------
	---------------------------------------------
	
	OpForTeamTag = "OpFor",
		
	---------------------------------------------
	------------- Hostage stuff -----------------
	---------------------------------------------
	
	
	-- extraction points
	AllExtractionPoints = {},
	AllExtractionPointMarkers = {},
	
	CurrentExtractionPoint = nil,
	ExtractionPointIndex = nil,

	-- insertion points
	AllInsertionPoints = {},
	
	DefenderInsertionPoints = {},
	DefenderInsertionPointNames = {},
	CurrentDefenderInsertionPointName = "",
	RandomDefenderInsertionPoint = nil,
	AttackerInsertionPoints = {},
	MissionLocationMarkers = {},

	-- hostage spawns
	AllHostageSpawns = {},
	
	CurrentHostageSpawn = nil,
	
	-- hostage escape triggers
	AllHostageTriggers = {},
	CurrentHostageExtractionPoint = nil,
	
	-- spawn protection volumes
	AllSpawnProtectionVolumes = {},
	
	JustSwitchedGameMode = false,

	-- defender blockers
	AllDefenderBlockers = {},

	-- AI spawn points
	AllAISpawns = {},

	DebugMode = false,
}





------------------ init functions ----------------

function hostagerescue:PreInit()

	gamemode.EnableExtraLogging()

	self.FinishedRoundProperly = false

	self:ResetAllScores()
	
	gamemode.SetTeamScoreTypes( self.TeamScoreTypes )
	gamemode.SetPlayerScoreTypes( self.PlayerScoreTypes )
	-- set up the score types in gamestate
	-- need this done only once at init
	gamemode.SetGameModeName('HostageRescue')
	self.CurrentHostageRescueGameMode = "HostageRescue"
	
	self.CurrentRoundNumber = 1
	-- this will be incremented by 1 at start of first round
	-- this is no longer needed - now tracked in AGBGameState as part of match stuff

	self.DefendingTeam = self.PlayerTeams.Blue
	self.AttackingTeam = self.PlayerTeams.Red
	
	self:SetupMissionObjects()
end


function hostagerescue:PostInit()
	gamemode.EnableExtraLogging()

	gamemode.ResetBalanceTeams(self.NumberOfPastTeamMovementsToTrack, self.AutoBalanceLightTouchSetting)
	-- call once

	self:SetGameObjectives_HostageRescue()
	-- now, we may end up playing Building Assault so these objectives will be bogus, but best have something up when round starts
end


function hostagerescue:SetGameObjectives_HostageRescue()
	gamemode.ClearGameObjectives()
	
	gamemode.AddGameObjective(self.DefendingTeam.TeamId, "DefendHostage", 1)
	gamemode.AddGameObjective(self.DefendingTeam.TeamId, "EliminateAttackers", 2)

	gamemode.AddGameObjective(self.AttackingTeam.TeamId, "ExtractHostage", 1)
	gamemode.AddGameObjective(self.AttackingTeam.TeamId, "EliminateDefenders", 2)
end


function hostagerescue:SetGameObjectives_BuildingAssault()
	gamemode.ClearGameObjectives()

	gamemode.AddGameObjective(self.DefendingTeam.TeamId, "SurviveRound", 1)
	gamemode.AddGameObjective(self.DefendingTeam.TeamId, "EliminateAttackers", 2)

	gamemode.AddGameObjective(self.AttackingTeam.TeamId, "EliminateDefenders", 1)
end


function hostagerescue:SetupMissionObjects()
	
	-- sort extractions
	
	self.AllExtractionPoints = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C')

	for i = 1, #self.AllExtractionPoints do
		local Location = actor.GetLocation(self.AllExtractionPoints[i])
		local ExtractionMarkerName = self:GetModifierTextForObjective( self.AllExtractionPoints[i] ) .. "EXTRACTION"
		-- allow the possibility of down chevrons, up chevrons, level numbers, etc
								
		actor.AddTag(self.AllExtractionPoints[i], "IsExtractionPoint")
		-- add this tag to all extraction points to simplify identification in GameTriggerBeginOverlap() and GameTriggerEndOverlap() functions
					
		-- make objective markers for both teams because teams switch role
		self.AllExtractionPointMarkers[i] = {}
		self.AllExtractionPointMarkers[i][self.PlayerTeams.Red.TeamId] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Red.TeamId, ExtractionMarkerName, "Extraction", false)
		self.AllExtractionPointMarkers[i][self.PlayerTeams.Blue.TeamId] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Blue.TeamId, ExtractionMarkerName, "Extraction", false)
		-- NB new penultimate parameter of MarkerType ("Extraction" or "MissionLocation", at present)
	end
	
	-- read in hostage spawns
	
	self.AllHostageSpawns = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_HostageSpawn.BP_HostageSpawn_C')

	-- read in insertion points

	local AllInsertionPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBInsertionPoint')
	self.MissionLocationMarkers = {}

	for i, InsertionPoint in ipairs(AllInsertionPoints) do
		if actor.HasTag(InsertionPoint, "Defenders") then
			local InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
			table.insert(self.DefenderInsertionPoints, InsertionPoint)
			table.insert(self.DefenderInsertionPointNames, InsertionPointName)	
			
			local MarkerName = self:GetModifierTextForObjective( InsertionPoint )
			--print("Setting up marker for [" .. InsertionPointName .. "][" .. self.PlayerTeams.Red.TeamId .. "]")

			local Location = actor.GetLocation(InsertionPoint)

			self.MissionLocationMarkers[InsertionPointName] = {}
			self.MissionLocationMarkers[InsertionPointName][self.PlayerTeams.Red.TeamId] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Red.TeamId, MarkerName, "MissionLocation", false)
			self.MissionLocationMarkers[InsertionPointName][self.PlayerTeams.Blue.TeamId] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Blue.TeamId, MarkerName, "MissionLocation", false)
			
		elseif actor.HasTag(InsertionPoint, "Attackers") then
			table.insert(self.AttackerInsertionPoints, InsertionPoint)
		end
	end
	
	-- read in spawn protection volumes

	self.AllSpawnProtectionVolumes = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBSpawnProtectionVolume')
	
	-- read in hostage triggers

	local AllGameTriggers = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBGameTrigger')
	self.AllHostageTriggers = {}
	
	for _, GameTrigger in ipairs(AllGameTriggers) do
		if actor.HasTag(GameTrigger, "HostageTrigger") then
			table.insert(self.AllHostageTriggers, GameTrigger)
		end
	end

	-- read in defender blockers
	
	local AllBlockers = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_MissionBlockingVolume.BP_MissionBlockingVolume_C')
	self.AllDefenderBlockers = {}
	
	for _, Blocker in ipairs(AllBlockers) do
		if actor.HasTag(Blocker, "HostageBlocker") then
			table.insert(self.AllDefenderBlockers, Blocker)
		end
	end
	
	-- read in AI spawns
	
	self.AllAISpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
end

----------------------- end init routines -----------------------



----------------------- handle starting round in ready room -----


function hostagerescue:PlayerReadyStatusChanged(PlayerState, ReadyStatus)
    if ReadyStatus == "DeclaredReady" then
		timer.Set("CheckReadyUp", self, self.CheckReadyUpTimer, 0.25, false);
	elseif ReadyStatus == "WaitingToReadyUp" or ReadyStatus == "NotReady" then
		timer.Set("CheckReadyDown", self, self.CheckReadyDownTimer, 0.1, false);
    end
end

-- this replaces PlayerInsertionPointChanged(), at least when no insertion points are enabled



function hostagerescue:CheckReadyUpTimer()
	if gamemode.GetRoundStage() == "WaitingForReady" or gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(false)
		local DefendersReady = ReadyPlayerTeamCounts[self.DefendingTeam.TeamId]
		local AttackersReady = ReadyPlayerTeamCounts[self.AttackingTeam.TeamId]

		-- ForceHostageRescue value 1 -> force hostage rescue
		-- all other settings permit building assault mode

		if self.Settings.ForceHostageRescue.Value ~= 1 then
			-- Building Assault mode is possible and we need only 1 player (plus AI), but if autobalance is turned off, they must be on the attacker team
			if (DefendersReady > 0 and self.Settings.BalanceTeams.Value ~= 0) or AttackersReady > 0 then
				if DefendersReady + AttackersReady >= gamemode.GetPlayerCount(true) then
					self:DoThingsAtEndOfReadyCountdown()
					gamemode.SetRoundStage("PreRoundWait")
				else
					gamemode.SetRoundStage("ReadyCountdown")
				end
			end
		else
			-- only Hostage Rescue is possible, and we need at least 5 players (or at least 3, if force hostage rescue is selected)
		
			if self:ThresholdMetForStartingHostageRescueGameMode(DefendersReady, AttackersReady, true) then
				-- true -> take team balancing into account (still possible)
				if DefendersReady + AttackersReady >= gamemode.GetPlayerCount(true) then
					self:DoThingsAtEndOfReadyCountdown()
					gamemode.SetRoundStage("PreRoundWait")
				else
					gamemode.SetRoundStage("ReadyCountdown")
				end
			end
		end
	end
end


function hostagerescue:ThresholdMetForStartingHostageRescueGameMode(NumDefenders, NumAttackers, bTakeTeamBalancingIntoAccount)
	if ((NumDefenders > 0 and NumAttackers > 0) and (NumDefenders + NumAttackers >= self.MinPlayersForHostageRescue)) 
	or ((NumDefenders > 0 and NumAttackers > 0) and (NumDefenders + NumAttackers >= 3) and (self.Settings.ForceHostageRescue.Value == 1)) 
	or ((NumDefenders > 0 or NumAttackers > 0) and self.DebugMode) then
		-- we have enough numbers to play, but (if there is no team balancing) do we have enough on each side?
		if (NumDefenders>=1 and NumAttackers>=2) or (bTakeTeamBalancingIntoAccount and self.Settings.BalanceTeams.Value ~= 0) then
			-- the assumption is that even light touch balancing will sort out having only 1 attacker (need 2 minimum)
			return true
		else
			return false
		end
	end

	return false
end


function hostagerescue:DoThingsAtEndOfReadyCountdown()
	--	called from OnRoundStageTimeElapsed() and CheckReadyUpTimer()

		print("DoThingsAtEndOfReadyCountdown() called")
	
		--if self.RandomDefenderInsertionPoint ~= nil then
		--	-- set defender insertion point true so PrepLatecomer() will work for defenders
		--	actor.SetActive(self.RandomDefenderInsertionPoint, true)
		--end
		self:ActivateDefenderInsertionPoints()
	
		self:GiveEveryoneReadiedUpStatus()
		-- do this before balancing teams
		
		self:SetGameMode()
					
		-- if game mode has switched, redo the setup:
					
		if self.JustSwitchedGameMode then
			if self.CurrentHostageRescueGameMode == "HostageRescue" then
				self:SetupRoundHostageRescue()
			else
				self:SetupRoundBuildingAssault()
			end
		end
		
		self:BalanceTeams()
		self:SelectHostage()
end


function hostagerescue:CheckReadyDownTimer()
	if gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
		local DefendersReady = ReadyPlayerTeamCounts[self.DefendingTeam.TeamId]
		local AttackersReady = ReadyPlayerTeamCounts[self.AttackingTeam.TeamId]
		
		if DefendersReady < 1 or AttackersReady < 1 then
			gamemode.SetRoundStage("WaitingForReady")
		end
	end
end

----------------------- end handle starting round in ready room ---




------------ round stage handling --------------------------------------


-- Game Round Stages:

-- WaitingForReady	-- players are in ready room at start of game/map/set of rounds
-- ReadyCountdown	-- at least one player has clicked on map
-- PreRoundWait		-- players have been spawned into the level but are frozen (to allow all other players to spawn in)
-- *BuildingAssaultSetup		-- all players are frozen and can't shoot, except Building Defender
-- *BuildingAssaultInProgress	-- Building Assault round is in progress
-- *HostageRescueSetup		-- attackers are frozen (including hostage) and can't shoot. Defenders are able to move around but not shoot.
-- *HostageRescueInProgress	-- HostageRescue round is in progress
-- PostRoundWait	-- round has ended, post round info is displayed
-- TimeLimitReached	-- round timed out
-- *RoundAbandoned   -- pause at end of round but do not switch teams after
--
-- * = custom round stages


function hostagerescue:OnRoundStageSet(RoundStage)

	if RoundStage == "WaitingForReady" then

		self:ResetRound()
		-- clears timers
	
		print("hostagerescue: ****RoundStage WaitingForReady")
		self:SetupRound()
		
		if self.CurrentHostageRescueGameMode == "HostageRescue" then
			self:SetupRoundHostageRescue()
		else
			self:SetupRoundBuildingAssault()
		end
				
	elseif RoundStage == "ReadyCountdown" then
		-- do nothing (extra)
			
	elseif RoundStage == "PreRoundWait" then
		print("hostagerescue: ****RoundStage PreRoundWait")
		-- default PreRoundWait round stage time is set in SetupRound() (12 seconds)
		
		self:ResetRoundScores()

		self:ShowAttackersDefendersMessage("PrepareToAttack", "PrepareToDefend", self.ScreenPositionRoundInfo, 3.0)
			
		self.PreRoundWaitWelcomeCount = 0
		timer.Set("PreRoundWaitWelcome", self, self.PreRoundWaitWelcomeTimer, 1.0, false)
			
		-- don't setup HostageRescue stuff yet because more players may join, and it's not clear if we'll have building assault instead
				
	elseif RoundStage == "BuildingAssaultSetup" then
		print("hostagerescue: ****RoundStage BuildingAssaultSetup")
		
		local DefenderSetupTime = self.ServerSettings.BuildingAssaultSetupTime.Value + 2.0
		gamemode.SetRoundStageTime(DefenderSetupTime)
		self:FreezeTeam(self.AttackingTeam.TeamId, DefenderSetupTime)
		
		self:DisableWeaponsForAll("SetupRound")
				
		gamemode.SetDefaultRoundStageTime("InProgress", math.ceil(self.Settings.RoundTime.Value * self.BuildingAssaultTimeMultiple) )
		-- need to update this as ops board setting may have changed - have to do this before RoundStage InProgress to be effective
		
	elseif RoundStage == "HostageRescueSetup" then
		print("hostagerescue: ****RoundStage HostageRescueSetup")

		self:TurnOnExtractionPointsAfterSpawn()
		
		self:EnsureHostageIsAtHostageSpawn()
		-- sometimes hostages are spawned with attackers, because GetSpawnInfo() is called before SelectHostage()?
	
		local DefenderSetupTime = self.Settings.DefenderSetupTime.Value + 2.0
		gamemode.SetRoundStageTime(DefenderSetupTime)
		self:FreezeTeam(self.AttackingTeam.TeamId, DefenderSetupTime)
		
		self:DisableWeaponsForAll("SetupRound")

		self:ShowHintsHostageRescueSetup()
		
		self:SetupHighlightMovingTargetTimer(self.CurrentHostage, "Hostage", self.DefendingTeam.TeamId)
				
		gamemode.SetDefaultRoundStageTime("InProgress", self.Settings.RoundTime.Value)
		-- need to update this as ops board setting may have changed - have to do this before RoundStage InProgress to be effective
			
	elseif RoundStage == "HostageRescueInProgress" then
		print("hostagerescue: ****RoundStage HostageRescueInProgress")
		self:ClearHighlightMovingTargetTimer()
		
		self:EnableWeaponsForAll("SetupRound")

		self.ApplyHostageLoadout = false
		
		self:DisableDefenderBlockers()
		-- let defenders leave building now, if they so desire

		gamemode.SetRoundStageTime(self.Settings.RoundTime.Value * 60)
		
	elseif RoundStage == "BuildingAssaultInProgress" then
		print("hostagerescue: ****RoundStage BuildingAssaultInProgress")
		self:ClearHighlightMovingTargetTimer()

		self:EnableWeaponsForAll("SetupRound")

		self:DisableDefenderBlockers()
		-- let defenders leave building now, if they so desire

		gamemode.SetRoundStageTime( math.ceil(self.Settings.RoundTime.Value * self.BuildingAssaultTimeMultiple) * 60)
		-- BuildingAssaultTimeMultiple messes up our time reminders. Never mind, try and set it to a round number?
		
		
	elseif RoundStage == "PostRoundWait" then
		print("hostagerescue: ****RoundStage PostRoundWait")

		self.CompletedARound = true
		self.AbandonedRound = false
		self.JustSwitchedGameMode = false
		
		self:EnableWeaponsForAll("SetupRound")
		self:DisableSpawnProtection()
		
		-- finalise scoring at end of PostRoundWait
		
		gamemode.SetRoundStageTime(5)
		
		
	elseif RoundStage == "RoundAbandoned" then
		print("hostagerescue: ****RoundStage RoundAbandoned")
		self:DisableWeaponsForAll("SetupRound")
	
		self.CompletedARound = false
	
		gamemode.SetRoundStageTime(5)	
		
	end
end


function hostagerescue:EnsureHostageIsAtHostageSpawn()
	-- sometimes hostages are spawned with attackers, because GetSpawnInfo() is called before SelectHostage()?
 	
	if self.CurrentHostage ~= nil and self.CurrentHostageSpawn ~= nil then
		local IntendedHostageSpawnLocation = actor.GetLocation(self.CurrentHostageSpawn)
		local HostageCharacter = player.GetCharacter(self.CurrentHostage)
		local CurrentHostageSpawnLocation = actor.GetLocation(HostageCharacter)
		
		local DifferenceVector = self:VectorSubtract( IntendedHostageSpawnLocation, CurrentHostageSpawnLocation )
		local SpawnDistance = vector.SizeSq(DifferenceVector)

		if SpawnDistance > 100*100 then
			-- more than 1m away from where they should be
			print("Hostage " .. player.GetName(self.CurrentHostage) .. " was spawned at distance " .. SpawnDistance .. " from hostage spawn - teleporting them to where they should be.")
			player.Teleport(self.CurrentHostage, IntendedHostageSpawnLocation, actor.GetRotation(self.CurrentHostageSpawn))
		else
			print("Hostage " .. player.GetName(self.CurrentHostage) .. " spawned at distance " .. SpawnDistance .. " from hostage spawn - deemed within range.")
		end
	else
		print("hostagerescue:EnsureHostageIsAtHostageSpawn(): current hostage was nil, or current hostage spawn was nil")
	end
end


function hostagerescue:OnWeaponAddedToInventory(Player, ItemType, ItemName)
	-- This is only called for PrimaryFirearm, Sidearm and Grenade types
	-- If you picked up a smoke grenade, tough luck
	
	--print("OnWeaponAddedToInventory() called with item type " .. ItemType .. " and item " .. ItemName)
	
	if gamemode.GetRoundStage() ~= "HostageRescueInProgress" then
		return
	end

	if not self.HostageIsArmed and self.CurrentHostage ~= nil and Player ~= nil and Player == self.CurrentHostage then
		player.ShowGameMessage(Player, "HostageIsArmed", "Center", 5.0)
		self.HostageIsArmed = true
	end
end


function hostagerescue:PreRoundWaitWelcomeTimer()
	-- this is a big faff but probably needed because players may join over the course of seconds and miss a single broadcast message

	self.PreRoundWaitWelcomeCount = self.PreRoundWaitWelcomeCount + 1
	
	if self.CurrentHostageRescueGameMode == 'HostageRescue' then
		self:ShowHostageRescueMessage("WaitForRoundStartAttacker", "WaitForRoundStartDefender", "WaitForRoundStartHostage", self.ScreenPositionRoundInfo, -1.5)
		-- negative time means flush last message
	else
		self:ShowAttackersDefendersMessage("WaitForRoundStartAttacker", "WaitForRoundStartDefender", self.ScreenPositionRoundInfo, -1.5)
	end
	
	if self.PreRoundWaitWelcomeCount == 3 then
		if self.AttackingTeam.TeamId == self.PlayerTeams.Red.TeamId then
			self:ShowAttackersDefendersMessage("YouAreAttackerRed", "YouAreDefenderBlue", self.ScreenPositionSetupStatus, math.max(3.0, self.Settings.DefenderSetupTime.Value))
		else
			self:ShowAttackersDefendersMessage("YouAreAttackerBlue", "YouAreDefenderRed", self.ScreenPositionSetupStatus, math.max(3.0, self.Settings.DefenderSetupTime.Value))
		end
	end
	
	if (self.PreRoundWaitWelcomeCount < 8) then
		timer.Set("PreRoundWaitWelcome", self, self.PreRoundWaitWelcomeTimer, 1.0, false)
	end
end


function hostagerescue:GiveEveryoneReadiedUpStatus()
	-- anyone who is waiting to ready up (in ops room) is assigned ReadiedUp status (just keep life simple)

	local EveryonePlayingList = gamemode.GetPlayerListByStatus(255, "WaitingToReadyUp", true)

	if #EveryonePlayingList > 0 then
		for _, Player in ipairs(EveryonePlayingList) do
			player.SetReadyStatus(Player, "DeclaredReady")
		end
	end

end


function hostagerescue:ShowHintsHostageRescueSetup()
	-- TODO - do same for building assault

	local Attackers = self:GetPlayerListIsPlaying(self.AttackingTeam.TeamId, true)
	local Defenders = self:GetPlayerListIsPlaying(self.DefendingTeam.TeamId, true)

	for _, Player in ipairs(Attackers) do
		player.ShowHint( Player, "HostageRescuePlacementPhaseAttacker", "WBP_HR_Attacker_Hint" )
	end

	for _, Player in ipairs(Defenders) do
		if self.CurrentHostage ~= nil then
			if self.CurrentHostage == Player then
				player.ShowHint( Player, "HostageRescuePlacementPhaseYourTurn", "WBP_HR_Hostage_Hint" )
			end
		else
			player.ShowHint( Player, "HostageRescuePlacementPhaseDefender", "WWBP_HR_Defender_Hint" )
		end
	end
end


function hostagerescue:HandleRestartRoundCommand()
	-- we have to handle all this ourselves
	
	local RoundStage = gamemode.GetRoundStage()

	if RoundStage == "WaitingForReady"
	or RoundStage == "ReadyCountdown"
	or RoundStage == "PostRoundWait"
	or RoundStage == "RoundAbandoned" then

		gamemode.BroadcastGameMessage("CantRestartRoundNow", self.ScreenPositionError, 5.0)

		return false
		-- don't take it
	else

		self:AbandonRound("RoundRestarted")
		
		return true
		-- don't override default handling
	
	end
end


function hostagerescue:BalanceTeams() 
	-- let the gamemode lua library handle this now, and also notifications (but need to make sure appropriate strings are in .csv file still)
	
	local IdealTeamSizeDifference

	if self.CurrentHostageRescueGameMode == "HostageRescue" then
		-- we want *two* more attackers than defenders, ideally (once hostage is chosen, the difference becomes one more attacker than defender)
		IdealTeamSizeDifference = 2
	else
		-- for building assault, +1 attacker advantage is fine
		IdealTeamSizeDifference = 1
	end
	
	gamemode.BalanceTeams(self.AttackingTeam.TeamId, self.DefendingTeam.TeamId, IdealTeamSizeDifference, self.Settings.BalanceTeams.Value)
	-- AttackingTeamId, DefendingTeamId, IdealTeamSizeDifference, BalancingAggression
end


function hostagerescue:GetPlayerListIsPlaying(TeamId, OnlyHumans)
	-- Status = "WaitingToReadyUp" or "DeclaredReady", and ignore "NotReady"
	-- anything else will just return an empty list

	local Result = {}
	
	local TeamList = gamemode.GetPlayerList(TeamId, OnlyHumans)
	
	local PlayerStatus
	
	for _,PlayerState in ipairs(TeamList) do
		PlayerStatus = player.GetReadyStatus(PlayerState)
		if PlayerStatus == "DeclaredReady" or PlayerStatus == "WaitingToReadyUp" then
			table.insert(Result, PlayerState)
		end
	end

	return Result
end


function hostagerescue:IsInList(Item, List)
	for _, CurrentItem in ipairs(List) do
		if CurrentItem == Item then
			return true
		end
	end
	
	return false
end


function hostagerescue:CheckEndRoundTimer()
	--print("CheckEndRoundTimer() called")

	if self.CurrentHostageRescueGameMode == "HostageRescue" then

		local LivingAttackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, true)
		local LivingDefenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, true)
		-- count human players
		
		self:PruneOutDeadPlayers(LivingAttackers)
		self:PruneOutDeadPlayers(LivingDefenders)
		-- temporary fix
		
		local OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, self.AttackingTeam.TeamId, 255)
		local NumLivingAttackers = #LivingAttackers + #OpForControllers
		OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, self.DefendingTeam.TeamId, 255)
		local NumLivingDefenders = #LivingDefenders + #OpForControllers
		
		if NumLivingAttackers < 2 then
		-- one of the surviving attackers will be the hostage (if hostage is killed, round is ended in the onkilled event)
			if NumLivingDefenders > 0 then
				gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
				gamemode.AddGameStat("Summary=AttackersEliminated")
				gamemode.AddGameStat("CompleteObjectives=DefendHostage,EliminateAttackers")
				gamemode.SetRoundStage("PostRoundWait")
					
				self:ScorePlayersAtEndOfRound( self.DefendingTeam.TeamId )
			else
				gamemode.AddGameStat("Result=None")
				gamemode.AddGameStat("Summary=BothEliminated")
				gamemode.SetRoundStage("PostRoundWait")
				
				self:ScorePlayersAtEndOfRound( -1 )
				-- winning team of -1 means no one won
			end
		end
		
		if NumLivingDefenders < 1 then
			-- I'd rather not end the match when defenders eliminated but it's hard coded so might as well roll with it rather than changing that stuff now
			gamemode.AddGameStat("Result=Team" .. tostring(self.AttackingTeam.TeamId))
			gamemode.AddGameStat("Summary=DefendersEliminated")
			gamemode.AddGameStat("CompleteObjectives=EliminateDefenders")
			gamemode.SetRoundStage("PostRoundWait")
		end
	else
		-- Building Assault
				
		local LivingAttackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, true)
		local LivingDefenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, true)
		-- count human players
		
		self:PruneOutDeadPlayers(LivingAttackers)
		self:PruneOutDeadPlayers(LivingDefenders)
		-- temporary fix
		
		local OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, self.AttackingTeam.TeamId, 255)
		local NumLivingAttackers = #LivingAttackers + #OpForControllers
		OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, self.DefendingTeam.TeamId, 255)
		local NumLivingDefenders = #LivingDefenders + #OpForControllers
		-- add in friendly AI players
		
		if NumLivingDefenders < 1 then
			if NumLivingAttackers < 1 then
				gamemode.AddGameStat("Result=None")
				gamemode.AddGameStat("Summary=BothEliminated")
				gamemode.SetRoundStage("PostRoundWait")
				
				self:ScorePlayersAtEndOfRound( -1 )
				-- -1 means no one won
			else
				gamemode.AddGameStat("Result=Team" .. tostring(self.AttackingTeam.TeamId))
				gamemode.AddGameStat("Summary=DefendersEliminated")
				gamemode.AddGameStat("CompleteObjectives=EliminateDefenders")
				gamemode.SetRoundStage("PostRoundWait")

				self:ScorePlayersAtEndOfRound( self.AttackingTeam.TeamId )
			end
		

		else
			if NumLivingAttackers < 1 then
				gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
				gamemode.AddGameStat("Summary=AttackersEliminated")
				gamemode.AddGameStat("CompleteObjectives=EliminateAttackers")
				gamemode.SetRoundStage("PostRoundWait")

				self:ScorePlayersAtEndOfRound( self.DefendingTeam.TeamId )
			end		
		end
	end
end


function hostagerescue:ScorePlayersAtEndOfRound( WinningTeam )

	-- WinningTeam = -1 means no one won
			
	if WinningTeam == self.DefendingTeam.TeamId then
		self:AwardTeamScore( self.DefendingTeam.TeamId, "WonRound" )
	elseif WinningTeam == self.AttackingTeam.TeamId then
		self:AwardTeamScore( self.AttackingTeam.TeamId, "WonRound" )
	end

	if self.LastKiller ~= nil then
		self:AwardPlayerScore( self.LastKiller, "LastKill" )
	end
	-- don't do a team score for this

	local DefenderList = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, false)
	-- get all alive players
	
	for _, Player in ipairs(DefenderList) do
	-- iterate through all living defenders
		self:AwardPlayerScore( Player, "SurvivedRound" )
		if self.DefendingTeam.TeamId == WinningTeam then
			self:AwardPlayerScore( Player, "WonRound" )
		end
	end
		
	local AttackerList = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, false)
	-- get all alive players
	
	for _, Player in ipairs(AttackerList) do
	-- iterate through all living defenders
		self:AwardPlayerScore( Player, "SurvivedRound" )
		if self.AttackingTeam.TeamId == WinningTeam then
			self:AwardPlayerScore( Player, "WonRound" )
		end
	end			
end


function hostagerescue:PruneOutDeadPlayers(PlayerList)
	for i = #PlayerList, 1, -1 do
	-- go backwards because shrinking list as we go
		if player.GetLives(PlayerList[i]) < 1 then
			table.remove(PlayerList, i)
		end
	end
end


function hostagerescue:GameTimerExpired()
-- TODO copy logic from EndRoundTimer

	if self.CurrentHostageRescueGameMode == "HostageRescue" then

		gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
		gamemode.AddGameStat("Summary=DefendedHostage")
		gamemode.AddGameStat("CompleteObjectives=DefendHostage")
		gamemode.SetRoundStage("PostRoundWait")
		
		self:AwardTeamScore(self.DefendingTeam.TeamId, "DefenderTimeout")
		
		self:ScorePlayersAtEndOfRound( self.DefendingTeam.TeamId )
	else
		-- Building Assault
		
		gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
		gamemode.AddGameStat("Summary=DefendersSurvived")
		gamemode.AddGameStat("CompleteObjectives=SurviveRound")
		gamemode.SetRoundStage("PostRoundWait")
				
		self:AwardPlayerScoreToTeam(self.DefendingTeam.TeamId, 1, "SurvivingDefenderByTime" )
		self:AwardTeamScore(self.DefendingTeam.TeamId, "DefenderSurvivedByTime")
		
		self:ScorePlayersAtEndOfRound( self.DefendingTeam.TeamId )
	end

end


function hostagerescue:SetupRound()
	-- called at start of WaitingForReady round stage, before HostageRescue/Building Assault mode is known
	-- does all the common init for both mods

	print("SetupRound()")

	if #self.AttackerInsertionPoints == nil then
		self:ReportError("Could not find any attacker insertion points")
		return
	end
	if #self.DefenderInsertionPoints == nil then
		self:ReportError("Could not find any defender insertion points")
		return
	end

	-- swap team roles (if needed)

	self:SwapTeamRoles()

	-- set up spawn protection volumes:

	-- put this on a timer to avoid the spawn protection warning flashing up momentarily at the end of the round
	timer.Clear("EnableSpawnProtection")
	timer.Set("EnableSpawnProtection", self, self.EnableSpawnProtectionVolumesTimer, 2.0, false)
	
	-- set up defender blockers 
	
	if self.Settings.RestrictDefenders.Value == 1 then
		self:EnableDefenderBlockers()
	else
		self:DisableDefenderBlockers()
	end
	
	-- pick a random defender spawn
	self:RandomiseRoundGeneral()	
	
	-- make hostage location markers visible only to attackers
	for i, InsertionPoint in ipairs(self.DefenderInsertionPoints) do
		local InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
		if self.MissionLocationMarkers[InsertionPointName] ~= nil then
			actor.SetActive(self.MissionLocationMarkers[InsertionPointName][self.DefendingTeam.TeamId], false)
			actor.SetActive(self.MissionLocationMarkers[InsertionPointName][self.AttackingTeam.TeamId], true)
		else
			print("Could not find objective marker for insertion point " .. InsertionPointName)
		end
	end
			
	-- reset stuff:
	
	self.LastKiller = nil
	
	self.CompletedARound = false
	self.AbandonedRound = false
	self.JustSwitchedGameMode = false
	self.CurrentHostageSpawn = nil
	self.CurrentHostageExtractionPoint = nil
	self.TeamExfilWarning = false
	self.HostageIsArmed = false
	-- need to set this after swapping teams (see above)
		
	--gamemode.SetGameModeName("HostageRescue")
	-- this is repeated in SetupRoundHostageRescue()
	-- want to avoid issues with building assault objectives
	-- we could dynamically update objectives depending on how many players clicked in, but that might be confusing on full servers
		
	gamemode.SetDefaultRoundStageTime("PreRoundWait", 12 )
	-- override the 5 second default (actually = 3 in practice -- take off 2 seconds any of these time limits to get actual duration)
end


function hostagerescue:RandomiseRoundGeneral()	
	-- attacker insertion points are set up in the HostageRescueSetup() and BuildingAssaultSetup() functions, because implementation varies between modes

	if #self.DefenderInsertionPoints == nil then
		self:ReportError("Could not find any defender insertion points")
		return
	end

	if #self.DefenderInsertionPoints > 1 then
		self.RandomDefenderInsertionPoint = self.DefenderInsertionPoints[umath.random(#self.DefenderInsertionPoints)]
	else
		self.RandomDefenderInsertionPoint = self.DefenderInsertionPoints[1]
	end
	
	print ("RandomiseRound(): Selected random defender insertion point " .. actor.GetName(self.RandomDefenderInsertionPoint))
	
	local CurrentDefenderInsertionPointName = gamemode.GetInsertionPointName(self.RandomDefenderInsertionPoint)
	if CurrentDefenderInsertionPointName == nil then
		self:ReportError("Insertion point name was unexpectedly nil")
		return
	end
	
	if self.Settings.BalanceTeams.Value == 0 then
	-- no team auto-balance so don't hide defender spawn
		self:ActivateDefenderInsertionPoints()
	else
		self:DeactivateDefenderInsertionPoints()	
	end
end


function hostagerescue:RandomiseRoundHostageRescue()
	-- pick a random extraction point and show it:
	
	if #self.AllExtractionPoints > 0 then
		self.ExtractionPointIndex = umath.random(#self.AllExtractionPoints)
		-- this is the current extraction point

		for i = 1, #self.AllExtractionPoints do
			local bActive = (self.Settings.ExtractAnywhere.Value == 0) and (i == self.ExtractionPointIndex)
			actor.SetActive(self.AllExtractionPointMarkers[i][self.AttackingTeam.TeamId], bActive)
			actor.SetActive(self.AllExtractionPointMarkers[i][self.DefendingTeam.TeamId], false)
			actor.SetActive(self.AllExtractionPoints[i], bActive)
			actor.SetTeamId(self.AllExtractionPoints[i], self.AttackingTeam.TeamId)
			-- set extraction marker to active and also turn on flare 
		end

		self.CurrentExtractionPoint = self.AllExtractionPoints[self.ExtractionPointIndex]
	else
		-- this will probably cause errors, but the game mode is fairly screwed without extraction points anyway...
		self.ExtractionPointIndex = nil
		self.CurrentExtractionPoint = nil
	end
	
	-- set up attacker insertion points:
	
	if self.Settings.ExtractAnywhere.Value == 0 then
		-- enable all insertion points except any being tagged with current extraction point name
		for i, InsertionPoint in ipairs(self.AttackerInsertionPoints) do
			local InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
			actor.SetTeamId(InsertionPoint, self.AttackingTeam.TeamId)
			actor.SetActive(InsertionPoint, not actor.HasTag(self.CurrentExtractionPoint, InsertionPointName))
		end
	else
		-- enable all insertion points
		for i, InsertionPoint in ipairs(self.AttackerInsertionPoints) do
			actor.SetTeamId(InsertionPoint, self.AttackingTeam.TeamId)
			actor.SetActive(InsertionPoint, true)
		end
	end
	
	-- set up hostage spawn:

	local InsertionPointName = gamemode.GetInsertionPointName(self.RandomDefenderInsertionPoint)
	
	for i, HostageSpawn in ipairs(self.AllHostageSpawns) do
		actor.SetTeamId(HostageSpawn, self.AttackingTeam.TeamId)

		if actor.HasTag(HostageSpawn, InsertionPointName) then
			--print("Hostage spawn " .. actor.GetName(HostageSpawn) .. " matches insertion point")
			if self.CurrentHostageSpawn == nil then
				actor.SetActive(HostageSpawn, true)
				self.CurrentHostageSpawn = HostageSpawn
			else
				self:ReportError("More than one hostage spawn has a tag corresponding to current insertion point " .. InsertionPointName)
			end
		else
			actor.SetActive(HostageSpawn, false)
		end
	end
	
	if self.CurrentHostageSpawn == nil then
		self:ReportError("Could not find a hostage spawn matching insertion point " .. InsertionPointName)
	end
end


function hostagerescue:EnableSpawnProtectionVolumesTimer()
	for i, SpawnProtectionVolume in ipairs(self.AllSpawnProtectionVolumes) do
		actor.SetTeamId(SpawnProtectionVolume, self.AttackingTeam.TeamId)
		actor.SetActive(SpawnProtectionVolume, true)
	end
end


function hostagerescue:SwapTeamRoles()
	if self.DefendingTeam == nil then
		-- level being run for first time, players probably all still in common area
		self.DefendingTeam = self.PlayerTeams.Blue
		self.AttackingTeam = self.PlayerTeams.Red
		
		gamemode.SetPlayerTeamRole(self.DefendingTeam.TeamId, "Defending")
		gamemode.SetPlayerTeamRole(self.AttackingTeam.TeamId, "Attacking")
	else
		
		if self.CompletedARound and self.Settings.AutoSwap.Value ~= 0 then
			if self.DefendingTeam == self.PlayerTeams.Blue then
				self.DefendingTeam = self.PlayerTeams.Red
				self.AttackingTeam = self.PlayerTeams.Blue
				print("hostagerescue:SetupRound(): team roles switched")
				print("Defenders are now team " .. self.DefendingTeam.TeamId)
			else
				self.DefendingTeam = self.PlayerTeams.Blue
				self.AttackingTeam = self.PlayerTeams.Red
				print("hostagerescue:SetupRound(): no change to team roles")
				print("Defenders are team " .. self.DefendingTeam.TeamId)
			end
			
			gamemode.SetPlayerTeamRole(self.DefendingTeam.TeamId, "Defending")
			gamemode.SetPlayerTeamRole(self.AttackingTeam.TeamId, "Attacking")
			
			-- Only show message after the first round, 
			-- at which point RandomDefenderInsertionPoint will no longer nil.
			
			local Attackers = gamemode.GetPlayerList(self.AttackingTeam.TeamId, true)
			for i = 1, #Attackers do
				player.ShowGameMessage(Attackers[i], "SwapAttacking", "Center", 3.0)
			end
			
			local Defenders = gamemode.GetPlayerList(self.DefendingTeam.TeamId, true)
			for i = 1, #Defenders do
				player.ShowGameMessage(Defenders[i], "SwapDefending", "Center", 3.0)
			end
		
		else
		
			if self.AbandonedRound then
				-- round being reset to waitingforready can happen as a result of all players readying down or leaving ops room
				-- (in this case we don't want to display these messages)
				
				local Attackers = gamemode.GetPlayerList(self.AttackingTeam.TeamId, true)
				for i = 1, #Attackers do
					player.ShowGameMessage(Attackers[i], "StillAttacking", "Center", 3.0)
				end
				
				local Defenders = gamemode.GetPlayerList(self.DefendingTeam.TeamId, true)
				for i = 1, #Defenders do
					player.ShowGameMessage(Defenders[i], "StillDefending", "Center", 3.0)
				end
			end			
		end
	end
end


function hostagerescue:ResetRound()
	self.CurrentHostage = nil
	self.CurrentHostageSpawn = nil
	self.ApplyHostageLoadout = true
	self.HostageHasEscaped = false
	
	StartingDefendingTeamSize = nil
	StartingAttackingTeamSize = nil

	if self.DefendingTeam ~= nil then
		ai.CleanUp(self.OpForTeamTag)
		ai.CleanUp(self.OpForTeamTag)
	end
	
	for i, InsertionPoint in ipairs(self.AllInsertionPoints) do
		actor.SetActive(InsertionPoint, false)
	end
	
	self.SpawnAttempts = {}
end


---- scoring stuff

function hostagerescue:ResetRoundScores()
	
	gamemode.ResetTeamScores()
	gamemode.ResetPlayerScores()

	LastKiller = nil

end


function hostagerescue:ResetAllScores()
	
	self:ResetRoundScores()
end


function hostagerescue:AwardPlayerScore( Player, ScoreType )
	-- Player must be a playerstate - use player.GetPlayerState ( ... ) if you need to when calling this

	if not actor.HasTag(player.GetCharacter(Player), self.OpForTeamTag) then
--		print("AwardPlayerScore: Not awarding any score to AI player")
--	else
		player.AwardPlayerScore( Player, ScoreType, 1 )		
	end
end 


function hostagerescue:AwardPlayerScoreToTeam( TeamId, MinLives, ScoreType )
	local TeamPlayers = gamemode.GetPlayerListByLives(TeamId, MinLives, true)
	-- only human players
	
	for _, Player in ipairs(TeamPlayers) do
		self:AwardPlayerScore( Player, ScoreType )
	end
end


function hostagerescue:AwardTeamScore( Team, ScoreType )
	gamemode.AwardTeamScore( Team, ScoreType, 1 )
	-- always award 1 x score (last parameter)			
end 

----------------- end scoring stuff


function hostagerescue:SetupRoundHostageRescue()
	-- set up game objectives
	-- (we might be doing this a second time - if building assault is selected, objectives might be whack)
	
	self:SetGameObjectives_HostageRescue()
		
	-- pick random extraction point and set them up
	self:RandomiseRoundHostageRescue()
		
	-- set up hostage triggers:
	
	for i, GameTrigger in ipairs(self.AllHostageTriggers) do
		actor.SetTeamId(GameTrigger, self.AttackingTeam.TeamId)
		actor.SetActive(GameTrigger, true)
	end
	

end


function hostagerescue:TurnOnExtractionPointsAfterSpawn()
	-- only if needed (extract anywhere mode)
	if self.Settings.ExtractAnywhere.Value == 1 then
		for i = 1, #self.AllExtractionPoints do
			actor.SetActive(self.AllExtractionPointMarkers[i][self.AttackingTeam.TeamId], true)
			actor.SetActive(self.AllExtractionPoints[i], true)
			-- set extraction marker to active and also turn on flare, for all extraction points
		end
	end
end


function hostagerescue:SetupRoundBuildingAssault()
	-- set up game objectives

	self:SetGameObjectives_BuildingAssault()

	-- set up insertion points
	
	for i, InsertionPoint in ipairs(self.AttackerInsertionPoints) do
		actor.SetActive(InsertionPoint, true)
		actor.SetTeamId(InsertionPoint, self.AttackingTeam.TeamId)
	end

	-- turn off all extraction points and markers

	for i = 1, #self.AllExtractionPoints do
		actor.SetActive(self.AllExtractionPointMarkers[i][self.AttackingTeam.TeamId], false)
		actor.SetActive(self.AllExtractionPointMarkers[i][self.DefendingTeam.TeamId], false)
		actor.SetActive(self.AllExtractionPoints[i], false)
	end	
end


function hostagerescue:ActorHasTagInList( CurrentActor, TagList ) 
	if CurrentActor == nil then
		print("hostagerescue:ActorHasTagInList(): CurrentActor unexpectedly nil")
		return false
	end
	if TagList == nil then
		print("hostagerescue:ActorHasTagInList(): TagList unexpectedly nil")
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

------------------------------------------------------------
--- freeze, unfreeze, disable and enable weapons
------------------------------------------------------------

function hostagerescue:FreezeTeam(TeamId, Duration)
	-- team are frozen to the spot

	local LivingPlayersInTeam = gamemode.GetPlayerListByLives(TeamId, 1, false)
	-- get all players in team including bots
	
	for _, Player in ipairs(LivingPlayersInTeam) do
		player.FreezePlayer(Player, Duration)
	end

end


function hostagerescue:UnFreezeTeam(TeamId)
	-- remove the freeze (set freeze duration = 0)
	self:FreezeTeam(TeamId, 0.0)
end


function hostagerescue:DisableWeaponsForAll(Reason)
-- everyone can move but not shoot

	local LivingPlayers = gamemode.GetPlayerListByLives(255, 1, false)
	-- get all players including bots (though that doesn't work atm)
	
	for _, Player in ipairs(LivingPlayers) do
		player.AddIgnoreUseInputReason(Player, Reason)
	end

end


function hostagerescue:DisableWeaponsForTeam(TeamId, Reason)
-- only this team can move AND shoot now

	local LivingPlayersInTeam = gamemode.GetPlayerListByLives(TeamId, 1, false)
	-- get all players in team including bots
	
	for _, Player in ipairs(LivingPlayersInTeam) do
		player.AddIgnoreUseInputReason(Player, Reason)
	end
end


function hostagerescue:EnableWeaponsForAll(Reason)
-- everyone can move AND shoot now

	local LivingPlayers = gamemode.GetPlayerListByLives(255, 1, false)
	-- get all players including bots (though that doesn't work atm)
	
	for _, Player in ipairs(LivingPlayers) do
		player.RemoveIgnoreUseInputReason(Player, Reason)
	end

end


function hostagerescue:EnableWeaponsForTeam(TeamId, Reason)
-- only this team can move AND shoot now

	local LivingPlayersInTeam = gamemode.GetPlayerListByLives(TeamId, 1, false)
	-- get all players in team including bots
	
	for _, Player in ipairs(LivingPlayersInTeam) do
		player.RemoveIgnoreUseInputReason(Player, Reason)
	end
end


function hostagerescue:DisableSpawnProtection()
	for i, SpawnProtectionVolume in ipairs(self.AllSpawnProtectionVolumes) do
		actor.SetActive(SpawnProtectionVolume, false)
	end
end


function hostagerescue:EnableDefenderBlockers()
	-- turn of defender blockers
	for i, Blocker in ipairs(self.AllDefenderBlockers) do
		actor.SetActive(Blocker, true)
	end
end


function hostagerescue:DisableDefenderBlockers()
	-- turn of defender blockers
	for i, Blocker in ipairs(self.AllDefenderBlockers) do
		actor.SetActive(Blocker, false)
	end
end


-------------------------------------------------------------------------
------------------------- hostage selection and inventory stuff ---------


function hostagerescue:SelectHostage()
	if self.CurrentHostageRescueGameMode ~= "HostageRescue" then
		return
	end

	local SelectedPlayer = nil

	if self.CurrentHostage ~= nil then
		print("Already have a hostage - aborting selection of a new one")
		return
	end

	local AttackerPlayers = gamemode.GetPlayerListByStatus(self.AttackingTeam.TeamId, "DeclaredReady", true)
	local VolunteerPlayers = gamemode.GetVolunteerListByStatus(self.AttackingTeam.TeamId, "DeclaredReady", true)

	print("Num attacker players = " .. #AttackerPlayers .. ":")
	for _, P in ipairs(AttackerPlayers) do
		print(player.GetName(P))
	end
		
	if #AttackerPlayers < 2 then
		if not self.DebugMode or #AttackerPlayers<1 then
			-- this round is invalid, need at least 1 hostage and 1 attacker
			print("Not enough attackers to have both a hostage and a rescuer")
			return
		else
			-- if there is one player (tester) then they will be selected as hostage
			SelectedPlayer = AttackerPlayers[1]
		end
	else	
		
		if #AttackerPlayers == 1 then
			SelectedPlayer = AttackerPlayers[1]
		elseif #VolunteerPlayers == 1 then
			SelectedPlayer = VolunteerPlayers[1]
		else
			for i = 1, #self.PastHostages do
				-- if only one player remains in the list, they have to be the hostage
				if #AttackerPlayers == 1 then
					SelectedPlayer = AttackerPlayers[1]
					break
				end
				
				for j = 1, #AttackerPlayers do
					-- find past hostage in current list of players, and remove it
					if self.PastHostages[i] == AttackerPlayers[j] then	
						table.remove(AttackerPlayers, j)
						break
					end
				end
			end

			if SelectedPlayer == nil then
				SelectedPlayer = AttackerPlayers[ umath.random(#AttackerPlayers) ]
			end
		end
	end

	if SelectedPlayer ~= nil then
		self.CurrentHostage = SelectedPlayer
		self.CurrentHostageIsAI = false

		self:RemoveValueFromTable(self.PastHostages, SelectedPlayer)
		-- avoid duplicates (may not exist)

		table.insert(self.PastHostages, 1, SelectedPlayer)
		
		if #self.PastHostages > self.NumberOfPastHostagesToTrack then
			table.remove (self.PastHostages)
			-- remove highest index item, everything will shuffle down an index
		end

		-- TODO let players request to be hostage or request not to be hostage (using console commands?)
		
		--self:SetupHighlightMovingTargetTimer(self.CurrentHostage, "Hostage", self.DefendingTeam.TeamId)
		print("Selected hostage = " .. player.GetName(SelectedPlayer))
	else
		self:ReportError("No player was selected for hostage")
	end
end


function hostagerescue:PostLoadoutCreated(PlayerState, LoadoutName)
	-- create a hostage loadout for everyone - this just happens passively in the background
    --print("hostagerescue:PostLoadoutCreated(): Player: " .. player.GetName(PlayerState) .. ", LoadoutName: " .. LoadoutName)
    
	
    --if LoadoutName == "NoTeam" then
	if not inventory.VerifyLoadoutExists(PlayerState, "Hostage") then
        self:CreateHostageLoadout(PlayerState, LoadoutName)
	end

	if not inventory.VerifyLoadoutExists(PlayerState, "Assault") then
		-- we need to test separately as in some cases a Hostage loadout might be made but an Assault loadout not
		self:CreateAssaultLoadout(PlayerState, LoadoutName)
	end
end


function hostagerescue:CreateHostageLoadout(PlayerState, LoadoutName)
	-- LoadoutName is the loadout just created, but when spawning into a level, all of NoTeam, Red and Blue are initially created I think 
	local SplitItemField = true
	local IgnoreRestrictions = true

	-- playerID , loadout name (if nil, use default), split item field
	Loadout = inventory.GetPlayerLoadoutAsTable(PlayerState, LoadoutName, SplitItemField)

	if Loadout == nil then
        self:ReportError("CreateHostageLoadout(): could not find NoTeam loadout")
	    return
	end
		
	-- we could just do a wholesale loadout replacement but we would lose patch info and possibly other things in future that we might want to keep

	-- remove all combat items and other inappropriate things:
	local ItemsToRemove = { "PrimaryFirearm", "Sidearm", "FaceWear", "Platform", "Belt", "HeadGear", "Holster", "EyeWear", "Gloves" }
	inventory.RemoveItemTypesFromLoadoutTable(ItemsToRemove, Loadout, SplitItemField)
	-- ItemsToRemove argument can be a single string instead of table to remove just one thing

	-- set hostage pants, boots and shirt from custom kit - replace kit defaults
	local ClothingKit = inventory.GetCustomKitAsTable("hostage", SplitItemField)
	-- this searches game CustomKit folder in current mod then base game
	
	if ClothingKit.ItemData ~= nil then
		-- v1034 - also replace head and hair (to force male hostage so people don't get weird with it)
		local MoreItemsToRemove = { "Pants", "Shirt", "Footwear", "Head", "HairMale", "HairFemale" }
		inventory.RemoveItemTypesFromLoadoutTable(MoreItemsToRemove, Loadout, SplitItemField)	
		inventory.AddCustomKitTableToLoadoutTable(ClothingKit, Loadout, SplitItemField)
	end
	
	-- now add flexcuffs:
	local Cuffs = { ItemType = "Equipment", ItemValue = "BP_Restraints_FlexCuffs" }
	table.insert(Loadout.ItemData, Cuffs)

	local Sack = { ItemType = "HeadGear", ItemValue = "BP_HostageSack" }
	table.insert(Loadout.ItemData, Sack)

	--self:DumpLoadout(Loadout, 0)

	inventory.CreateLoadoutFromTable(PlayerState, "Hostage", Loadout, SplitItemField)
end


function hostagerescue:CreateAssaultLoadout(PlayerState, LoadoutName)
	-- LoadoutName is the loadout just created, but when spawning into a level, all of NoTeam, Red and Blue are initially created I think 
	local SplitItemField = true
	local IgnoreRestrictions = true

	local PlayerTeam = actor.GetTeamId(PlayerState)

	local TeamLoadoutName = self:GetLoadoutNameForTeam(PlayerTeam)

	-- try reading the appropriate 'Red' or 'Blue' loadout depending on TeamId
	Loadout = inventory.GetPlayerLoadoutAsTable(PlayerState, TeamLoadoutName, SplitItemField)

	if Loadout == nil then
		-- it might just not exist yet
        print("CreateAssaultLoadout(): could not find loadout '" .. TeamLoadoutName .. "' for player " .. player.GetName(PlayerState))
	    return
	end

	-- remove all combat items and other inappropriate things:
	--local ItemsToRemove = { "PrimaryFirearm", "Sidearm", "FaceWear", "Platform", "Belt", "HeadGear", "Holster", "EyeWear", "Gloves" }
	--inventory.RemoveItemTypesFromLoadoutTable(ItemsToRemove, Loadout, SplitItemField)
	-- ItemsToRemove argument can be a single string instead of table to remove just one thing

	-- the LimitSupplies call acts on a json USERDATA object not a lua loadout table, so this needs adapting if needed (or just do it in lua instead - see the c++ code for what you have to search for)
	--inventory.LimitSupplies(Loadout, FragsLimit, SmokesLimit, FlashbangsLimit, BreachChargeLimit)

	inventory.CreateLoadoutFromTable(PlayerState, "Assault", Loadout, SplitItemField)
	--print("Created loadout 'Assault' for player " .. player.GetName(PlayerState))
end


function hostagerescue:GetLoadoutNameForTeam(TeamId)
	for _, TeamName in ipairs(self.PlayerTeams) do
		if TeamName.TeamId == TeamId then
			return TeamName.LoadoutName
		end
	end

	return "NoTeam"
end


function hostagerescue:GetPlayerLoadoutName(PlayerState)
    --print("hostagerescue:GetPlayerLoadoutName(): Player: " .. player.GetName(PlayerState) .. " and round stage = " .. gamemode.GetRoundStage())
    if self.CurrentHostage ~= nil and PlayerState == self.CurrentHostage and self.ApplyHostageLoadout then
	--and gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "HostageRescueSetup" then
        -- use loadout name 'hostage'
		self.ApplyHostageLoadout = false
        return "Hostage"
    end
    
	--if self.CurrentHostageRescueGameMode = "BuildingAssault" and ...
	-- apply building assault loadouts? Differentiate by attacker and defender, maybe have separate "AssaultAttacker" and "AssaultDefender" loadouts as needed?
	
    -- use team based loadout
    return nil
end


function hostagerescue:GetSpawnInfo(PlayerState)
	if PlayerState == nil then
		print("hostagerescue:GetSpawnInfo(): PlayerState was nil")
	end

	if self.CurrentHostageRescueGameMode == "HostageRescue" then

		local PlayerTeam = actor.GetTeamId(PlayerState)
		
		if PlayerTeam == self.DefendingTeam.TeamId then
			print("hostagerescue:GetSpawnInfo(): " .. player.GetName(PlayerState) .. " is defender, so returning insertion point " .. actor.GetName(self.RandomDefenderInsertionPoint) )
			return self.RandomDefenderInsertionPoint
			-- for defenders, return the random insertion point
			
		elseif PlayerTeam == self.AttackingTeam.TeamId then

			if self.CurrentHostage ~= nil and self.CurrentHostageSpawn ~= nil and PlayerState == self.CurrentHostage then
				local Result = {}
				Result.Rotation = actor.GetRotation(self.CurrentHostageSpawn)
				Result.Location = actor.GetLocation(self.CurrentHostageSpawn)

				print("hostagerescue:GetSpawnInfo(): " .. player.GetName(PlayerState) .. " is hostage..")

				return Result
			end
			
			print("hostagerescue:GetSpawnInfo(): " .. player.GetName(PlayerState) .. " is attacker.. returning nil for SpawnInfo (use default insertion point instead)")
			
		else
		
			print("hostagerescue:GetSpawnInfo(): Error: " .. player.GetName(PlayerState) .. " is not on the attacking or defending team! Team=" .. PlayerTeam)
			
		end
		
	else
	
		-- building assault
		local PlayerTeam = actor.GetTeamId(PlayerState)
		if PlayerTeam == self.DefendingTeam.TeamId then
			return self.RandomDefenderInsertionPoint
			-- for defenders, return the random insertion point
		end
		
	end
	
	return nil
end

-------------------------------------------------------------------------
------------------------- end hostage selection and inventory stuff -----

function hostagerescue:SetupHighlightMovingTargetTimer(Target, TargetDescription, TeamId)
	if Target ~= nil then
		--print("Setting up HighlightMovingTargetTimer for target description " .. TargetDescription .. " / team ID = " .. TeamId)
		timer.Clear("MovingTarget")
		self.MovingTarget = Target
		self.MovingTargetTeamId = TeamId
		-- the team that sees the highlighted player
		--self.MovingTargetTeamId = 255

		self.MovingTargetDescription = TargetDescription
		timer.Set("MovingTarget", self, self.HighlightMovingTargetTimer, self.HighlightMovingTargetInterval, true)
		self:HighlightMovingTargetTimer()
		
		-- set timer and also call immediately
	else
		print ("target to highlight was nil")
	end
end


function hostagerescue:ClearHighlightMovingTargetTimer()
	timer.Clear("MovingTarget")
	self.MovingTarget = nil
end


function hostagerescue:HighlightMovingTargetTimer()
	if self.MovingTarget ~= nil then

		local DisplayPlayers = gamemode.GetPlayerListByLives(self.MovingTargetTeamId, 1, true)
		-- thanks to TheCoder for the spot that this wasn't local (20 May 2022)
	
		for _, DisplayPlayer in ipairs(DisplayPlayers) do
			if DisplayPlayer ~= self.MovingTarget then
				local PlayerChar = player.GetCharacter(self.MovingTarget)
				if PlayerChar ~= nil then
					local TargetVector = actor.GetLocation(PlayerChar)
					
					--TargetVector.z = TargetVector.z + 100
					-- correct for height
					
					player.ShowWorldPrompt(DisplayPlayer, TargetVector, self.MovingTargetDescription, self.HighlightMovingTargetInterval + 0.0)
					-- show the hostage (attacker team) to players in other team (defenders)
				--else
				--	print("skipped moving target")
				end
			end
		end
	end
end


function hostagerescue:RemoveValueFromTable(TableToEdit, ValueToRemove)
	-- assumes continuous table without gaps

		for i = #TableToEdit, 1, -1 do
			-- if only one player remains in the list, they have to be the building defender
			if TableToEdit[i] == ValueToRemove then
				table.remove(TableToEdit, i)
			end
		end
end


------------ end round stage stuff  --------------------------------------


function hostagerescue:DumpVector(Vector)
	if Vector == nil or Vector["x"] == nil then
		print("hostagerescue: DumpVector: invalid vector")
		return
	end

	print("hostagerescue: DumpVector: x=" .. Vector.x .. ", y=" .. Vector.y .. ", z=" .. Vector.z) 
end


function hostagerescue:VectorSubtract( Vector1, Vector2 )
--	returns Vector1 - Vector2 as table { {"x", ...}, {"y",...}, {"z",...} }

	local Result = {}

	if Vector1 == nil or Vector2 == nil then
		print("hostagerescue: VectorSubtract(): passed nil vector, returning nil")
		return nil
	end

	local Result = {}

	Result.x = Vector1.x - Vector2.x
	Result.y = Vector1.y - Vector2.y
	Result.z = Vector1.z - Vector2.z

	return Result
end


------------ end find spawn points -----------------------------------



function hostagerescue:OnCharacterDied(Character, CharacterController, KillerController)
	-- TODO determine if this is an 'admin kill' and do not award a TK if so

	--print("OnCharacterDied() called")

	if gamemode.GetRoundStage() == "PreRoundWait" 
	or gamemode.GetRoundStage() == "HostageRescueSetup"
	or gamemode.GetRoundStage() == "HostageRescueInProgress"
	or gamemode.GetRoundStage() == "BuildingAssaultSetup" 
	or gamemode.GetRoundStage() == "BuildingAssaultInProgress" then
		if CharacterController ~= nil then
			local LivesLeft
			if not actor.HasTag(CharacterController, self.OpForTeamTag) then
				LivesLeft = math.max(0, player.GetLives(CharacterController) - 1)
				player.SetLives(CharacterController, LivesLeft)
				--print("Human died")
			else
				LivesLeft = 0
				actor.RemoveTag(CharacterController, self.OpForTeamTag)
				-- clear this AI from future consideration
				--print("AI died")
			end

			if gamemode.GetRoundStage() == "HostageRescueSetup" and 
			self.CurrentHostageIsAI == false and
			player.GetPlayerState(CharacterController)== self.CurrentHostage then
			
				self:AbandonRound("HostageDiedOrLeft")
				return

			end

			if gamemode.GetRoundStage() ~= "PostRoundWait" then
				-- don't want to do scoring once round is over
				
				local KilledTeam, KilledPlayerState
				local KillerTeam, KillerPlayerState
				
				-- if CharacterController or KillerController is (AI or nil), XXXTeam will be 0 (no team) and XXXPlayerState will be nil
				KilledTeam, KilledPlayerState = self:GetSafeTeamAndPlayerState( CharacterController )
				KillerTeam, KillerPlayerState = self:GetSafeTeamAndPlayerState( KillerController )
				
				-- do scoring stuff
				if KillerController ~= nil then
	
					if self.CurrentHostage ~= nil and KilledPlayerState == self.CurrentHostage then
						-- hostage was killed
						
						if KillerPlayerState == self.CurrentHostage then

								self:AwardPlayerScore( KillerPlayerState, "KilledHostage" )
								self:AwardTeamScore( KillerTeam, "KilledHostage" )

								-- hostage killed themeselves, big oops
								print("Hostage was killed with themselves listed as killer - suicide?")
								-- suicides count as TKs
								self:AwardPlayerScore( KilledPlayerState, "TeamKill" )
								self:AwardTeamScore( KilledTeam, "TeamKill" )
								gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
								gamemode.AddGameStat("Summary=HostageKilledHostage")
								gamemode.AddGameStat("CompleteObjectives=")
								-- no one gets a prize
						else

							if KillerTeam == self.AttackingTeam.TeamId then
								-- attackers killed the hostage, oops
								self:AwardPlayerScore( KillerPlayerState, "KilledHostage" )
								self:AwardTeamScore( KillerTeam, "KilledHostage" )

								gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
								gamemode.AddGameStat("Summary=AttackersKilledHostage")
								gamemode.AddGameStat("CompleteObjectives=DefendHostage")
							else
								-- defenders killed the hostage, oops
								if not self.HostageIsArmed then
									self:AwardPlayerScore( KillerPlayerState, "KilledHostage" )
									self:AwardTeamScore( KillerTeam, "KilledHostage" )
								
									gamemode.AddGameStat("Result=Team" .. tostring(self.AttackingTeam.TeamId))
									gamemode.AddGameStat("Summary=DefendersKilledHostage")
									-- no prizes for anyone
									gamemode.AddGameStat("CompleteObjectives=")
								else
									self:AwardPlayerScore( KillerPlayerState, "KilledArmedHostage" )
									self:AwardTeamScore( KillerTeam, "KilledArmedHostage" )
									self:AwardPlayerScore( KilledPlayerState, "KilledAsArmedHostage" )
									self:AwardTeamScore( KilledTeam, "KilledAsArmedHostage" )

									gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
									gamemode.AddGameStat("Summary=DefendersKilledArmedHostage")
									gamemode.AddGameStat("CompleteObjectives=")						
								end
							end
						end

						gamemode.SetRoundStage("PostRoundWait")
						return
					end
					
					if KillerTeam ~= KilledTeam then
						self:AwardPlayerScore( KillerPlayerState, "Killed" )
						self:AwardTeamScore( KillerTeam, "Killed" )
						
						-- award score to everyone in proximity of killer
						local KillerTeamList = gamemode.GetPlayerListByLives(KillerTeam, 1, true)
						-- list of player states
						
						local SomeoneWasInRange = false
						
						for _, Player in ipairs(KillerTeamList) do
							if Player ~= KillerPlayerState then
								if self:GetDistanceBetweenPlayers(Player, KillerPlayerState, false) <= self.ScoringKillProximity then
									self:AwardPlayerScore( Player, "InRangeOfKill" )
									SomeoneWasInRange = true
								end
							end
						end
						
						if SomeoneWasInRange then
							self:AwardTeamScore( KillerTeam, "InRangeOfKill" )
						end
						
						self.LastKiller = KillerPlayerState
					
					else
						-- suicides count as TKs
						self:AwardPlayerScore( KillerPlayerState, "TeamKill" )
						self:AwardTeamScore( KillerTeam, "TeamKill" )
						
					end
				else
					if self.CurrentHostage ~= nil and KilledPlayerState == self.CurrentHostage then
						-- hostage was killed, probably by suicide?
						print("Hostage was killed without a killer being specified - suicide?")
						-- hostage killed themeselves, big oops
						-- suicides count as TKs
						self:AwardPlayerScore( KilledPlayerState, "TeamKill" )
						self:AwardTeamScore( KilledTeam, "TeamKill" )
						gamemode.AddGameStat("Result=Team" .. tostring(self.DefendingTeam.TeamId))
						gamemode.AddGameStat("Summary=HostageKilledHostage")
						--gamemode.AddGameStat("CompleteObjectives=DefendHostage")
						-- no one gets a prize
					end
				end
			end

			local PlayersWithLives = gamemode.GetPlayerListByLives(255, 1, false)
			if #PlayersWithLives == 0 then
				self:CheckEndRoundTimer()
				-- call immediately because round is about to end and nothing more can happen
			else
				timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false);
			end

		end
	end
end


function hostagerescue:GetSafeTeamAndPlayerState(Controller)
	if Controller == nil or ai.IsAI(Controller) then
		return 0, nil
	end

	local Team = actor.GetTeamId(Controller)
	local PlayerState = player.GetPlayerState(Controller)
	
	return Team, PlayerState
end


function hostagerescue:GetDistanceBetweenPlayers(Player1, Player2, TwoDimensional)
-- returns distance in metres between the players

	if Player1 == nil or Player2 == nil then
		return 1000 * 100
	end
	
	local Character1 = player.GetCharacter(Player1)
	local Character2 = player.GetCharacter(Player2)

	if Character1 == nil or Character2 == nil then
		return 10000
	end
	
	local Location1 = actor.GetLocation( Character1 )
	local Location2 = actor.GetLocation( Character2 )
	
	local DifferenceVector = self:VectorSubtract( Location1, Location2 )
	
	if TwoDimensional then
		return vector.Size2D(DifferenceVector) / 100
	else
		return vector.Size(DifferenceVector) / 100
	end
end


function hostagerescue:ShouldCheckForTeamKills()
	if gamemode.GetRoundStage() == "HostageRescueInProgress" 
	or gamemode.GetRoundStage() == "HostageRescueSetup"
	or gamemode.GetRoundStage() == "BuildingAssaultInProgress"
	or gamemode.GetRoundStage() == "BuildingAssaultSetup" then
		return true
	end
	return false
end


function hostagerescue:PlayerCanEnterPlayArea(PlayerState)
	return true
end



-- Game Round Stages:

-- WaitingForReady	-- players are in ready room at start of game/map/set of rounds
-- ReadyCountdown	-- at least one player has clicked on map
-- PreRoundWait		-- players have been spawned into the level but are frozen (to allow all other players to spawn in)
-- BuildingAssaultSetup		-- all attackers are frozen and can't shoot 
-- BuildingAssaultInProgress	-- Building Assault round is in progress
-- BuildingAssaultTransitionToHostageRescue	-- Building Assault is about to transition to HostageRescue - this might be too complex? just end round?
-- HostageRescueSetup		-- both sides can move but neither can shoot. Defenders are finding place for flag
-- HostageRescueInProgress	-- HostageRescue round is in progress
-- PostRoundWait	-- round has ended, post round info is displayed
-- TimeLimitReached	-- round timed out    ** setting this stage will cause server to go to next map **


function hostagerescue:DetermineRoundType()
	
	local Defenders = self:GetPlayerListIsPlaying(self.DefendingTeam.TeamId, false)
	local Attackers = self:GetPlayerListIsPlaying(self.AttackingTeam.TeamId, false)
	-- we assume no one has died yet
	
	if self:ThresholdMetForStartingHostageRescueGameMode(#Defenders, #Attackers, false) then
		-- false -> don't take team balancing into account (too late)
		return "HostageRescue"
	else
		return "BuildingAssault"
	end
end


function hostagerescue:GetTotalPlayersOnTeamIncludingAI(TeamId)

		local LivingHumans = gamemode.GetPlayerListByLives(TeamId, 1, true)
		local OpForControllers = ai.GetControllers(nil, self.OpForTeamTag, TeamId, 255)
		-- new in v1034 - use nil for default AI controller class, currently tags aren't working but are ignored
		return #LivingHumans + #OpForControllers
end


function hostagerescue:OnRoundStageTimeElapsed(RoundStage)
	if RoundStage == "ReadyCountdown" then

		self:DoThingsAtEndOfReadyCountdown()

	elseif RoundStage == "PreRoundWait" then

		if self.CurrentHostageRescueGameMode == "HostageRescue" then
			gamemode.SetRoundStage("HostageRescueSetup")

			--gamemode.BroadcastGameMessage("HOSTAGE RESCUE ROUND " .. self.CurrentRoundNumber, self.ScreenPositionRoundInfo, math.max(3.0, self.Settings.DefenderSetupTime.Value))
			
			self:ShowHostageRescueMessage("HostageRescueBeginSetupAttack","HostageRescueBeginSetupDefend", "HostageRescueBeginSetupHostage", self.ScreenPositionRoundInfo, math.max(3.0, self.Settings.DefenderSetupTime.Value))

			if self.AttackingTeam.TeamId == self.PlayerTeams.Red.TeamId then
				self:ShowAttackersDefendersMessage("YouAreAttackerRed", "YouAreDefenderBlue", self.ScreenPositionSetupStatus, math.max(3.0, self.Settings.DefenderSetupTime.Value))
			else
				self:ShowAttackersDefendersMessage("YouAreAttackerBlue", "YouAreDefenderRed", self.ScreenPositionSetupStatus, math.max(3.0, self.Settings.DefenderSetupTime.Value))
			end
			
			timer.Set("FinaliseHostageRescueSetup", self, self.FinaliseHostageRescueSetup, 0.2, false)

		else
			gamemode.SetRoundStage("BuildingAssaultSetup")
			
			gamemode.SetRoundIsTemporaryGameMode(true)
			-- stops round counter being incremented or match scores being updated. Is reset by the game each round at WaitingForReady
			
			if self:GetTotalPlayersOnTeamIncludingAI(self.DefendingTeam.TeamId) > 1 then
				self:ShowAttackersDefendersMessage("BuildingAssaultSetupAttack","BuildingAssaultSetupDefend", self.ScreenPositionRoundInfo, math.max(3.0, self.ServerSettings.BuildingAssaultSetupTime.Value ))	
			else
				self:ShowAttackersDefendersMessage("BuildingAssaultSetupAttack","BuildingAssaultSetupDefend", self.ScreenPositionRoundInfo, math.max(3.0, self.ServerSettings.BuildingAssaultSetupTime.Value ))
			end
			
			if self.AttackingTeam.TeamId == self.PlayerTeams.Red.TeamId then
				self:ShowAttackersDefendersMessage("YouAreAttackerRed", "YouAreDefenderBlue", self.ScreenPositionSetupStatus, math.max(3.0, self.ServerSettings.BuildingAssaultSetupTime.Value))
			else
				self:ShowAttackersDefendersMessage("YouAreAttackerBlue", "YouAreDefenderRed", self.ScreenPositionSetupStatus, math.max(3.0, self.ServerSettings.BuildingAssaultSetupTime.Value))
			end
			
			timer.Set("FinaliseBuildingAssaultSetup", self, self.FinaliseBuildingAssaultSetup, 0.2, false)
		end
		
		--return true
		-- true for handled (otherwise apply default behaviour)
	end

	if RoundStage == "HostageRescueSetup" then
		self:ShowHostageRescueMessage("HostageRescueBeginAttack","HostageRescueBeginDefend", "HostageRescueBeginHostage", self.ScreenPositionRoundInfo, 3.0)	
		gamemode.SetRoundStage("HostageRescueInProgress")
		return true
	elseif RoundStage == "BuildingAssaultSetup" then
		self:ShowAttackersDefendersMessage("BuildingAssaultAttack","BuildingAssaultDefend", self.ScreenPositionRoundInfo, 3.0)			
		gamemode.SetRoundStage("BuildingAssaultInProgress")	
		return true
	end


	if RoundStage == "HostageRescueInProgress" or RoundStage == "BuildingAssaultInProgress" then
	
		self:GameTimerExpired()
		-- this will set the round stage to PostRoundWait
		
		--gamemode.SetRoundStage("TimeLimitReached")
		--do not set round stage to this! Will cause server to move on to next map
		return true
		-- handled
		
	elseif RoundStage == "RoundAbandoned" then
		
		timer.ClearAll()
		
		gamemode.SendEveryoneToReadyRoom()
		gamemode.SetRoundStage("WaitingForReady")
		return true
	
	elseif RoundStage == "PostRoundWait" then
			
		timer.ClearAll()
	end

	return false
end


function hostagerescue:SetGameMode()
	self:GiveEveryoneReadiedUpStatus()
	-- do this again in case we had late joiners
	
	local OldGameMode = self.CurrentHostageRescueGameMode
	
	self.CurrentHostageRescueGameMode = self:DetermineRoundType()
	if self.Settings.ForceHostageRescue.Value == 1 then
		self.CurrentHostageRescueGameMode = 'HostageRescue'
		--print("Overriding to HostageRescue mode")
	end
	if self.Settings.ForceHostageRescue.Value == 2 then
		self.CurrentHostageRescueGameMode = 'BuildingAssault'
		--print("Overriding to Building Assault mode")
	end

	if OldGameMode ~= self.CurrentHostageRescueGameMode then
		self.JustSwitchedGameMode = true
	end

	-- self.CurrentHostageRescueGameMode is now definitive
	gamemode.SetGameModeName(self.CurrentHostageRescueGameMode)
	-- this function allows us to tell the game that we are different game modes, as and when we wish
end


function hostagerescue:FinaliseHostageRescueSetup()
	local LivingAttackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, false)
	local LivingDefenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, false)

	gamemode.SetTeamAttitude(self.DefendingTeam.TeamId, self.AttackingTeam.TeamId, "hostile")
	gamemode.SetTeamAttitude(self.AttackingTeam.TeamId, self.DefendingTeam.TeamId, "hostile")

	if self.CurrentHostage == nil then
		self:ReportError("No hostage was selected")
	end

	self.StartingDefendingTeamSize = self:GetTotalPlayersOnTeamIncludingAI(self.DefendingTeam.TeamId)
	self.StartingAttackingTeamSize = self:GetTotalPlayersOnTeamIncludingAI(self.AttackingTeam.TeamId)
end


function hostagerescue:FinaliseBuildingAssaultSetup()
	local LivingAttackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, false)
	local LivingDefenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, false)

	-- spawn in AI if needed

	-- spawn in AI if needed
	if #LivingDefenders < 1 then
		print("Spawning in an AI defender")
		
		local AISpawn = nil
		local DefenderInsertionPointName = gamemode.GetInsertionPointName(self.RandomDefenderInsertionPoint)
		
		for _, AISpawnCandidate in ipairs(self.AllAISpawns) do
			if actor.HasTag(AISpawnCandidate, DefenderInsertionPointName) then
				print("Found AI spawn point matching insertion point: " .. actor.GetName(AISpawnCandidate))
				AISpawn = AISpawnCandidate
				break
			end
		end

		if AISpawn ~= nil then
			ai.Create(AISpawn, self.OpForTeamTag, 3.0)
		else
			self:ReportError("Could not find AI Spawn Point matching defender insertion point " .. DefenderInsertionPointName)
			self:AbandonRound("Could not spawn AI")
		end
	end

	gamemode.SetTeamAttitude(self.DefendingTeam.TeamId, self.AttackingTeam.TeamId, "hostile")
	gamemode.SetTeamAttitude(self.AttackingTeam.TeamId, self.DefendingTeam.TeamId, "hostile")

	self.StartingDefendingTeamSize = self:GetTotalPlayersOnTeamIncludingAI(self.DefendingTeam.TeamId)
	self.StartingAttackingTeamSize = self:GetTotalPlayersOnTeamIncludingAI(self.AttackingTeam.TeamId)

end


function hostagerescue:ShowAttackersDefendersMessage(AttackerMessage, DefenderMessage, Location, Duration)
	local Attackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, true)
	local Defenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, true)

	if Attackers ~= nil and Defenders ~= nil then
		
		for i = 1, #Attackers do
			player.ShowGameMessage(Attackers[i], AttackerMessage, Location, Duration)
		end
		
		for i = 1, #Defenders do
			player.ShowGameMessage(Defenders[i], DefenderMessage, Location, Duration)
		end

	end
end


function hostagerescue:ShowHostageRescueMessage(AttackerMessage, DefenderMessage, HostageMessage, Location, Duration)
	local Attackers = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1,  true)
	local Defenders = gamemode.GetPlayerListByLives(self.DefendingTeam.TeamId, 1, true)

	if Attackers ~= nil and Defenders ~= nil then
		for i = 1, #Defenders do
			player.ShowGameMessage(Defenders[i], DefenderMessage, Location, Duration)
		end
		
		for i = 1, #Attackers do
			if self.CurrentHostage ~= nil and Attackers[i] == self.CurrentHostage then
				player.ShowGameMessage(Attackers[i], HostageMessage, Location, Duration)
			else
				player.ShowGameMessage(Attackers[i], AttackerMessage, Location, Duration)
			end
		end
	end
end


function hostagerescue:PlayerEnteredPlayArea(PlayerState)

	local FreezeTime = gamemode.GetRoundStageTime()
	player.FreezePlayer(PlayerState, FreezeTime)
	
end


function hostagerescue:OnGameTriggerEndOverlap(GameTrigger, Character)
	local Player = player.GetPlayerState(Character)
	if self.CurrentHostage ~= nil and Player == self.CurrentHostage and actor.HasTag(GameTrigger, "IsExtractionPoint") then
		print("Hostage left extraction point area")
		self.CurrentHostageExtractionPoint = nil
		timer.Clear("CheckOpForExfil")
		self.TeamExfilWarning = false
	end
end


function hostagerescue:OnGameTriggerBeginOverlap(GameTrigger, Character)
	local Player = player.GetPlayerState(Character)

	--print("Trigger overlap called with player " .. player.GetName(Player) .. " against trigger " .. actor.GetName(GameTrigger))

	if self.CurrentHostageRescueGameMode ~= "HostageRescue" or self.CurrentHostage == nil or gamemode.GetRoundStage() ~= "HostageRescueInProgress" then
		return
	end
	
	-- we are in Hostage Rescue mode, and trigger could be extraction or it could be the hostage escape trigger(s)

	if (self.CurrentExtractionPoint ~= nil and GameTrigger == self.CurrentExtractionPoint) 
	or (self.Settings.ExtractAnywhere.Value == 1 and actor.HasTag(GameTrigger, "IsExtractionPoint")) then
		if self.CurrentHostage ~= nil and Player == self.CurrentHostage then
			self.CurrentHostageExtractionPoint = GameTrigger
			timer.Set("CheckOpForExfil", self, self.CheckOpForExfilTimer, 1.0, true)
			--print("Hostage entered extraction point " .. actor.GetName(GameTrigger) .. ", starting extraction check timer")
			return
		end
		-- hostage has extracted
	else
		if actor.HasTag(GameTrigger, "HostageTrigger") then
			-- another trigger, so will be a hostage trigger (other extraction points should be disabled)
			if not self.HostageHasEscaped and self.CurrentHostage ~= nil and Player == self.CurrentHostage then
				self:ActionHostageHasEscaped()
			end
		end
	end
end


function hostagerescue:CheckOpForExfilTimer()
	if self.CurrentHostageExtractionPoint == nil then
		timer.Clear("CheckOpForExfil")
		return
	end
	
	local Overlaps = actor.GetOverlaps(self.CurrentHostageExtractionPoint, 'GroundBranch.GBCharacter')
	local PlayersWithLives = gamemode.GetPlayerListByLives(self.AttackingTeam.TeamId, 1, false)
	
	local bExfiltrated = false

	for i = 1, #PlayersWithLives do
		local PlayerCharacter = player.GetCharacter(PlayersWithLives[i])
	
		-- May have lives, but no character, alive or otherwise.
		if PlayerCharacter ~= nil then
			for j = 1, #Overlaps do
				if Overlaps[j] == PlayerCharacter and self.CurrentHostage ~= nil and PlayersWithLives[i] ~= self.CurrentHostage then
					bExfiltrated = true
					break
				end
			end
		end
	end
	
	if bExfiltrated then
		timer.Clear("CheckOpForExfil")
		gamemode.AddGameStat("Result=Team" .. tostring(self.AttackingTeam.TeamId))
		gamemode.AddGameStat("Summary=ExtractedHostage")
		gamemode.AddGameStat("CompleteObjectives=ExtractHostage")
		gamemode.SetRoundStage("PostRoundWait")
	elseif self.TeamExfilWarning == false then
		player.ShowGameMessage(self.CurrentHostage, "TeamExfil", "Engine", 5.0)
		self.TeamExfilWarning = true
	end
end


function hostagerescue:ActionHostageHasEscaped()
	print("Hostage has escaped the building")
	-- allow defenders to roam freely
	if not player.HasGameplayTag(self.CurrentHostage, "BeingLeadAsHostage") then
		self:DisableSpawnProtection()		
		self.HostageHasEscaped = true
	else
		print("hostagerescue:ActionHostageHasEscaped(): did not disengage spawn protection volumes because hostage was being led outside")
	end
end


function hostagerescue:AbandonRound(Reason)
	self:ShowAttackersDefendersMessage(Reason, Reason, self.ScreenPositionError, 5.0)	
	self.AbandonedRound = true
	gamemode.SetRoundStage("RoundAbandoned")
end


function hostagerescue:PrunePlayerFromList(Player, List)
	-- basically a copy (with reversed arguments) of self:RemoveValueFromTable(TableToEdit, ValueToRemove)
	-- oh well

	for i = #List, 1, -1 do
	-- need to go backwards because list will shrink when we delete something
		if List[i] == Player then
			table.remove(List, i)
		end
	end
end


function hostagerescue:OnPreLoadoutChanged(Loadout)
	-- OnClientPreLoadoutChanged( Loadout )
	-- Gives local (client) mutators a chance to modify the inventory before it is applied
	-- FIXME this doesn't work if the client loadout remains unchanged
	-- hiding setting for now

	-- TODO need to force inventory refresh on enter playarea

--	if self.Settings.RestrictNades.Value == 1 then
--		inventory.LimitSupplies(Loadout, 0, -1, -1, -1)
--	end	
end


function hostagerescue:ActivateDefenderInsertionPoints()
	-- now make the insertion points live, so that PrepLatercomers() etc will work	
	for _, InsertionPoint in ipairs(self.DefenderInsertionPoints) do
		if InsertionPoint == self.RandomDefenderInsertionPoint then
			actor.SetActive(InsertionPoint, true)
			actor.SetTeamId(InsertionPoint, self.DefendingTeam.TeamId)
		else
			actor.SetActive(InsertionPoint, false)
			actor.SetTeamId(InsertionPoint, 255)
		end
	end
end


function hostagerescue:DeactivateDefenderInsertionPoints()
	for i, InsertionPoint in ipairs(self.DefenderInsertionPoints) do
		actor.SetActive(InsertionPoint, false)
		actor.SetTeamId(InsertionPoint, 255)
	end
end


function hostagerescue:OnRandomiseObjectives()
	-- new in v1034
	
	self:RandomiseRoundGeneral()
	
	if self.CurrentHostageRescueGameMode == "HostageRescue" then
		self:RandomiseRoundHostageRescue()
	end
	
end


function hostagerescue:CanRandomiseObjectives()
	-- new in v1034

	-- can randomise objectives if defender spawns are shown, or if randomising extraction zones
	return ( (self.Settings.BalanceTeams.Value == 0 and (#self.DefenderInsertionPoints >1) ) 
	or ( (self.Settings.ExtractAnywhere.Value == 0) and (#self.AllExtractionPoints > 1) ) )
	
end


function hostagerescue:OnMissionSettingsChanged(ChangedSettingsTable)
	-- NB this may be called before some things are initialised
	-- need to avoid infinite loops by setting new mission settings
	
	if gamemode.GetRoundStage() ~= 'WaitingForReady' then
		-- new thing 2023/3/1 because changing time during mission might cause this to be called (bad)
		print("hostagerescue:OnMissionSettingsChanged(): not called during WaitingForReady, so ignored")
		return
	end
	
	if ChangedSettingsTable['BalanceTeams'] ~= nil then
		-- show or hide spawns depending on whether we are balancing teams (0 = not)
		
		if self.Settings.BalanceTeams.Value == 0 then
			self:ActivateDefenderInsertionPoints()
		else
			self:DeactivateDefenderInsertionPoints()
		end
	end
	
	if ChangedSettingsTable['ForceHostageRescue'] ~= nil then
        print("OnMissionSettingsChanged(): Force Hostage Rescue value changed.")
		self:SetupRound()
		
		if self.Settings.ForceHostageRescue.Value == 1 then
			self.CurrentHostageRescueGameMode = "HostageRescue"
			self:SetupRoundHostageRescue()
		elseif self.Settings.ForceHostageRescue.Value == 2 then
			self.CurrentHostageRescueGameMode = "BuildingAssault"
			self:SetupRoundBuildingAssault()
		end
		
		gamemode.SetGameModeName(self.CurrentHostageRescueGameMode)
	end
end


function hostagerescue:GetModifierTextForObjective( TaggedActor )
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


function hostagerescue:ReportError(ErrorMessage)
	gamemode.BroadcastGameMessage("Error! " .. ErrorMessage, "Upper", 5.0)
	print("-- Hostage rescue game mode error!: " .. ErrorMessage)
end


function hostagerescue:LogOut(Exiting)
	-- TODO should HostageRescueSetup and BuildingAssaultSetup be in this list?
	-- TODO check if player is the building defender or hostage - reassign in both cases if in setup time
	
	if gamemode.GetRoundStage() == "PreRoundWait" 
	or gamemode.GetRoundStage() == "HostageRescueInProgress" 
	or gamemode.GetRoundStage() == "BuildingAssaultInProgress" then
		timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false);
	end
	
	local PlayerExiting = player.GetPlayerState(Exiting)
	
	-- remove player from any lists
	--print ("LogOut: a player has left the server. Checking/pruning player from lists...")
	
	-- clear hostage
	if self.CurrentHostage ~= nil and PlayerExiting ~= nil then
		if self.CurrentHostage == PlayerExiting then
			-- new behaviour:
			-- abandon round if hostage has left game before setup finished
			-- otherwise carry on
			
			self:AbandonRound("HostageLeftGame")
		end
	end

	self:PrunePlayerFromList(PlayerExiting, self.PastHostages)

end


function hostagerescue:DumpLoadout(Loadout, RecursionLevel)
	-- call with recursion level set to 0

	if Loadout == nil then
		return
	end

	-- Loadout is lua table encoding of loadout/item build
	for LoadoutKey, LoadoutValue in pairs(Loadout) do
		local OutputString = ""

		if RecursionLevel>0 then
			for i = 1, RecursionLevel do
				OutputString = OutputString .. "..."
			end
		end
		
		--print(LoadoutKey .. " " .. type(LoadoutValue) .. " ")
		
		if type(LoadoutValue) == "string" then
			print(OutputString .. LoadoutKey .. " = " .. LoadoutValue)
		elseif type(LoadoutValue) == "number" then
			print(OutputString .. LoadoutKey .. " = " .. LoadoutValue)
		elseif type(LoadoutValue) == "table" then
			print(OutputString .. LoadoutKey .. ">>")
			self:DumpLoadout(LoadoutValue, RecursionLevel+1)
			-- recurse
		end
	end
end
	

return hostagerescue
