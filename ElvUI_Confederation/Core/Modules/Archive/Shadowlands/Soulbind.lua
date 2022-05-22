local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MSoulbind'
local Initialized = false

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching soulbind information")
		for i = 1, CON:GetCovenantCount() do
			local Covenant = CON:GetCovenant(i)
			for j = 1, table.getn(Covenant.soulbindIDs) do
				local SoulbindID = Covenant.soulbindIDs[j]
				DB.Soulbind[SoulbindID] = C_Soulbinds.GetSoulbindData(SoulbindID)
				-- Remove non-essential information
				table.RemoveKey(DB.Soulbind[SoulbindID], 'tree')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'activationSoundKitID')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'description')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'playerConditionReason')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'textureKit')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'modelSceneData')
				table.RemoveKey(DB.Soulbind[SoulbindID], 'cvarIndex')
			end
		end
		Initialized = true
	end
end

local function CheckSoulbind()
	Initialize()
	local NewSoulbindID = C_Soulbinds.GetActiveSoulbindID()
	if(DB.Player.ActiveSoulbindID ~= NewSoulbindID) then 
		DB.Player.ActiveSoulbindID = NewSoulbindID
	end
end

function CON:HasActiveSoulbind()
	CheckSoulbind()
	return DB.Player.ActiveSoulbindID and DB.Player.ActiveSoulbindID ~= nil and DB.Player.ActiveSoulbindID ~= 0
end

function CON:GetSoulbindCount()
	CheckSoulbind()
	return table.getn(DB.Soulbind)
end

function CON:GetSoulbind(SoulbindID)
	if(SoulbindID == nil) then return nil end
	return DB.Soulbind[SoulbindID]
end

function CON:GetActiveSoulbind()
	CheckSoulbind()
	return CON:GetSoulbind(DB.Player.ActiveSoulbindID)
end

function CON:GetActiveSoulbindID()
	CheckSoulbind()
	return DB.Player.ActiveSoulbindID
end