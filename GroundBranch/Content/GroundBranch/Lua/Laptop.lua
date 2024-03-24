-- default/test laptop lua script - simulates hacking and making pickup-able

local laptop = {
	CurrentTime = 0,
}

function laptop:ServerUseTimer(User, DeltaTime)
	self.CurrentTime = self.CurrentTime + DeltaTime
	--local SearchTime = gamemode.script.Settings.SearchTime.Value
	local SearchTime = 2.0
	self.CurrentTime = math.max(self.CurrentTime, 0)
	self.CurrentTime = math.min(self.CurrentTime, SearchTime)

	local Result = {}
	Result.Message = "Hello World"
	Result.Equip = false
	Result.Percentage = self.CurrentTime / SearchTime
	if Result.Percentage == 1.0 then
		Result.Message = "100 percent"
		Result.Equip = true
	elseif Result.Percentage == 0.0 then
		Result.Message = "0 percent"
	end
	return Result
end

function laptop:OnReset()
	self.CurrentTime = 0
end

function laptop:CarriedLaptopDestroyed()
end

return laptop