local inteltarget = {
	CurrentTime = 0,
}

-- this script assumes the presence of variable LaptopTag in the game mode script
-- this script also assumes the presence of function TargetCaptured() in the game mode script (not clear if will throw an error if not found)

function inteltarget:ServerUseTimer(User, DeltaTime)
	self.CurrentTime = self.CurrentTime + DeltaTime
	local SearchTime = gamemode.script.Settings.SearchTime.Value
	self.CurrentTime = math.max(self.CurrentTime, 0)
	self.CurrentTime = math.min(self.CurrentTime, SearchTime)

	local Result = {}
	Result.Message = "Searching local disk (C:)"
	Result.Equip = false
	Result.Percentage = self.CurrentTime / SearchTime
	if Result.Percentage == 1.0 then
		if actor.HasTag(self.Object, gamemode.script.LaptopTag) then
			Result.Message = "1 file match found."
			Result.Equip = true
			gamemode.script:OnTargetCaptured()
		else
			Result.Message = "IntelNotFound"
		end
	end
	return Result
end

function inteltarget:OnReset()
	self.CurrentTime = 0
end

function inteltarget:LaptopPickedUp()
	gamemode.script:OnLaptopPickedUp()
end

function inteltarget:LaptopPlaced(NewLaptop)
	gamemode.script:OnLaptopPlaced(NewLaptop)
end


function inteltarget:CarriedLaptopDestroyed()
	if actor.HasTag(self.Object, gamemode.script.LaptopTag) then
		if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
			gamemode.BroadcastGameMessage("LaptopDestroyed", "Center", 10.0)
		end
	end
end

function inteltarget:GetLaptopInPlay()
	return gamemode.script:GetLaptopInPlay()
	-- returns laptop in play (if any)
end

return inteltarget