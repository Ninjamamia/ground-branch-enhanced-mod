local bomb = {
	CurrentTime = 0.0,
}

function bomb:ServerUseTimer(User, DeltaTime)
	if gamemode.script == nil then
		return
	end
	
	-- User TeamID should not be 255 - it should be 1 or 2 for PVP, or 1 for PVE (conventionally)
	
	if (actor.GetTeamId(User) == 255) or (actor.GetTeamId(User) == gamemode.script.PlayerTeams.BluFor.TeamId) then
		self.CurrentTime = self.CurrentTime + DeltaTime
		
		local DefuseTime = gamemode.script.Settings.DefuseTime.Value
		self.CurrentTime = math.max(self.CurrentTime, 0.0)
		self.CurrentTime = math.min(self.CurrentTime, DefuseTime)

		local Percentage = self.CurrentTime / DefuseTime

		GetLuaComp(self.actor).SetPercentage(Percentage)

		if Percentage == 1.0 then
			-- actor != owner
			-- FIXME - this is shit.
			-- We should use the LuaComponent all the time!
			GetLuaComp(self.actor).SetDefused(true)
			gamemode.script:BombDefused(self.actor)
		end
	end
end

function bomb:ServerUseEnd()
	self.CurrentTime = 0.0
	GetLuaComp(self.actor).SetPercentage(0.0)
end

function bomb:OnReset()
	self.CurrentTime = 0.0
end

function bomb:OnBombDamaged(DamageAmount)
	if gamemode == nil or gamemode.script == nil then
		print("bomb:OnBombDamaged(): invalid gamemode or gamemode script")
		return
	end

	-- new in 1034, called when EITHER the barrel as a whole or the bomb on top is shot (50 damage) or naded (up to 1000 dmg?)
	if gamemode.script.OnBombDamaged ~= nil then
		gamemode.script:OnBombDamaged(self.actor, DamageAmount)
	else
		if gamemode.script.OnBombHit ~= nil then
			-- if script only provides OnBombHit(), send a hit even with nil controller
			gamemode.script:OnBombHit(self.actor, nil)
		end
	end
end
	
function bomb:OnBombHit(BombController)
	if gamemode == nil or gamemode.script == nil then
		print("bomb:OnBombHit(): invalid gamemode or gamemode script")
		return
	end

	if BombController == nil then
		print ("bomb:OnBombHit(): Error: Bomb controller was nil")
	end

	-- new in 1034, called when small packet on top of barrel is shot (not called with nade damage)
	if gamemode.script.OnBombHit ~= nil then
		gamemode.script:OnBombHit(self.actor, BombController)
	else
		if gamemode.script.OnBombDamaged ~= nil then
			-- if script only provides OnBombDamaged(), send a damage event with size 50
			gamemode.script:OnBombDamaged(self.actor, 50)
		end
	end
end
	
	
return bomb