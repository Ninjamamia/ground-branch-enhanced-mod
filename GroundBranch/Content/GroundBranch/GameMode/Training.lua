local training = {
	StringTables = { "Training" },
	
	GameModeAuthor = "(c) BlackFoot Studios, 2021-2024",
	GameModeType = "TRAINING",
	
	---------------------------------------------
	----- Game Mode Properties ------------------
	---------------------------------------------

	UseReadyRoom = false,
	UseRounds = false,

	-- no gameplay effect, but allows players to indicate readiness, etc
	VolunteersAllowed = true,
	
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
	
	-- players that are in NoTeam (0) will be considered hostile to each other (overriding anything done in gamemode.SetTeamAttitude),
	-- so if you want things like friendly tags to work, you have to put everyone in a team.
	-- A further complication is that without a ready room, you will remain on team 0 by default.
	-- So we need to change player teams when they join.
	
	PlayerTeams = {
		BluFor = {
			TeamId = 1,
			Loadout = "NoTeam",
		},
	},
}

function training:PostInit()
	-- set round stage to new stage "NoTimer", which actually is just a very, very long timer (2 days)
	gamemode.SetRoundStage("NoTimer")
end

function training:PlayerEnteredPlayArea(PlayerState)
	-- force joining players to Team 1 to ensure a friendly team attitude (so can display friendly name tags and so on)
	actor.SetTeamId(PlayerState, self.PlayerTeams.BluFor.TeamId)

	-- players are not given lives until they 'properly' enter play area (?), but in Training the lack of lives messes with tablets and suchlike
	player.SetLives(PlayerState, 1)
end

return training
