local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MCovenant'
local Initialized = false

local function CallbackCovenantChosen(event)
	if(CON:HasActiveCovenant()) then
		local Covenant = CON:GetActiveCovenant()
		local Broadcast = false
		if(DB.Player.Covenant.ID ~= Covenant.ID) then
			DB.Player.Covenant = Covenant
			Broadcast = true
		end
		if(CON:HasActiveSoulbind()) then
			local Soulbind = CON:GetActiveSoulbind()
			if(DB.Player.Soulbind.ID ~= Soulbind.ID) then
				DB.Player.Soulbind = Soulbind
				Broadcast = true
			end
		end
		if(Broadcast == true) then
			CON:BroadcastMessage(DB.Data.Player)
		end
	end
end

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching covenant information")
		for i = 1, table.getn(C_Covenants.GetCovenantIDs()) do
			DB.Covenant[i] = C_Covenants.GetCovenantData(i)
			-- Remove non-essential information
			table.RemoveKey(DB.Covenant[i], 'animaGemsFullSoundKit')
			table.RemoveKey(DB.Covenant[i], 'animaChannelSelectSoundKit')
			table.RemoveKey(DB.Covenant[i], 'textureKit')
			table.RemoveKey(DB.Covenant[i], 'renownFanfareSoundKitID')
			table.RemoveKey(DB.Covenant[i], 'beginResearchSoundKitID')
			table.RemoveKey(DB.Covenant[i], 'animaChannelActiveSoundKit')
			table.RemoveKey(DB.Covenant[i], 'celebrationSoundKit')
			table.RemoveKey(DB.Covenant[i], 'reservoirFullSoundKitID')
			table.RemoveKey(DB.Covenant[i], 'animaNewGemSoundKit')
			table.RemoveKey(DB.Covenant[i], 'animaReinforceSelectSoundKit')
			table.RemoveKey(DB.Covenant[i], 'upgradeTabSelectSoundKitID')
		end
		CON:RegisterEvent('COVENANT_CHOSEN', CallbackCovenantChosen)
		CON:RegisterEvent('SOULBIND_ACTIVATED', CallbackCovenantChosen)
		Initialized = true
	end
end

local function CheckCovenant()
	Initialize()
	local NewCovenantID = C_Covenants.GetActiveCovenantID()
	if(DB.Player.ActiveCovenantID ~= NewCovenantID) then
		DB.Player.ActiveCovenantID = NewCovenantID
	end
end

function CON:HasActiveCovenant()
	CheckCovenant()
	return DB.Player.ActiveCovenantID and DB.Player.ActiveCovenantID ~= nil and DB.Player.ActiveCovenantID ~= 0
end

function CON:GetCovenantCount()
	CheckCovenant()
	return table.getn(DB.Covenant)
end

function CON:GetCovenant(CovenantID)
	if(CovenantID == nil) then return nil end
	return DB.Covenant[CovenantID]
end

function CON:GetActiveCovenant()	
	CheckCovenant()
	return CON:GetCovenant(DB.Player.ActiveCovenantID)
end

function CON:GetActiveCovenantID()
	CheckCovenant()
	return DB.Player.ActiveCovenantID
end