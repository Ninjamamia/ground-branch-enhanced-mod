local training = {
	StringTables = { "Training" },
	
	GameModeAuthor = "(c) BlackFoot Studios, 2021-2024",
	GameModeType = "TRAINING",
}

function training:PostInit()
	-- set round stage to new stage "NoTimer", which actually is just a very, very long timer (2 days)
	gamemode.SetRoundStage("NoTimer")
end

function training:OnRoundStageSet(RoundStage)
	--print("TRAINING! New round stage: " .. RoundStage)
end

return training
