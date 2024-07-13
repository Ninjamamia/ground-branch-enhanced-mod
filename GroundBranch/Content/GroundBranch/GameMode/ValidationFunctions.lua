local validationfunctions = {

	-- strings  here should all be uppercase or they won't match
	-- recognised game mode types are defined via UGBFunctionLibrary::GetGameModeTypeFromName()
	ExpectedGameModeTags = {
		["PVP"] = { "PVP", "TEAM", },
		
		["PVE"] = { "COOP", },
		["COOP"] = { "COOP", },		
		["CO-OP"] = { "COOP", },
		
		["PVPFFA"] = { "PVP", },
		["PVP_FFA"] = { "PVP", },
		["PVP FFA"] = { "PVP", },
		["PVP FREEFORALL"] = { "PVP", },
				
		["TRAINING"] = { "TRAIN", },
	},
}
-- library of validation functions to simplify and future-proof game mode validation functions

function validationfunctions:PerformGenericValidations()
	local ErrorsFound = {}
	
	-- add entries to ErrorsFound as appropriate (table is passed by reference)
	self:CheckMissionTags(ErrorsFound)
	
	return ErrorsFound
end

function validationfunctions:CheckMissionTags(ErrorsFound)
	
	local MissionTags = gamemode.GetCurrentMissionTags()
		
	if gamemode.script == nil then
		table.insert(ErrorsFound, "validationfunctions:CheckMissionTags(): Unexpectedly could not find mission script")
		return ErrorsFound
	end
	
	local GameModeType = gamemode.script.GameModeType
	if GameModeType == nil then
		table.insert(ErrorsFound, "validationfunctions:CheckMissionTags(): Unexpectedly could not find game mode type")
		return ErrorsFound
	end
	
	local TagsToFind = self.ExpectedGameModeTags [ string.upper(GameModeType) ]
	
	if TagsToFind == nil then
		table.insert(ErrorsFound, "validationfunctions:CheckMissionTags(): Unexpectedly could not find game mode tags for that game mode type")
		return ErrorsFound
	end
	
	local TagsFound = {}
	local TagsNotFound = {}
	
	for _, CurrentTag in ipairs(TagsToFind) do
		if self:TagsListHasTag(MissionTags, CurrentTag) then
			table.insert(TagsFound, CurrentTag)
		else
			table.insert(TagsNotFound, CurrentTag)
		end
	end
	
	local bDumpTags = false
	
	if #TagsNotFound > 0 then
		table.insert(ErrorsFound, "Could not find all expected mission tags:")
		bDumpTags = true
	end

	if #MissionTags > (#TagsFound + #TagsNotFound) then
		table.insert(ErrorsFound, "Found unexpected mission tags:")
		bDumpTags = true
	end
		
	if bDumpTags then
		local ExpectedTagsText = ""
		local FoundTagsText = ""
		local bFoundOne
		
		-- (1) list expected tags
		
		bFoundOne = false
		
		for _, CurrentTag in ipairs(TagsToFind) do
			if not bFoundOne then
				ExpectedTagsText = string.upper(CurrentTag)
				bFoundOne = true
			else
				ExpectedTagsText = ExpectedTagsText .. ", " .. CurrentTag
			end
		end

		if not bFoundOne then
			ExpectedTagsText = "(None)"
		end
		
		-- (2) list provided tags
		
		bFoundOne = false
				
		for _, CurrentTag in ipairs(MissionTags) do
			if not bFoundOne then
				ProvidedTagsText = string.upper(CurrentTag)
				bFoundOne = true
			else
				ProvidedTagsText = ProvidedTagsText .. ", " .. string.upper(CurrentTag)
			end
		end

		if not bFoundOne then
			ProvidedTagsText = "(None)"
		end

		table.insert(ErrorsFound, "Expected tags for this game mode = " .. ExpectedTagsText .. "; Provided [SAVED] tags for this game mode = " .. ProvidedTagsText .. " (NB this applies to SAVED tags, and you may have correctly entered the tags in the editor already)")
	end
	
	return ErrorsFound
end

function validationfunctions:TagsListHasTag(MissionTags, CurrentTag)
	-- returns TRUE if CurrentTag is in list MissionTags
	-- will match CAPITAL LETTERS, so entries in MissionTags should all be uppercase
	
	for _, TestTag in ipairs(MissionTags) do
		if string.upper(TestTag) == string.upper(CurrentTag) then
			return true
		end
	end
	
	return false
end


return validationfunctions
