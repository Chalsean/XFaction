local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MProfession'
local Initialized = false

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching profession information")
		if(DB.Profession == nil) then
			DB.Profession = {}
		end
		Initialized = true
	end
end

function CON:GetProfession(ProfessionID)
	Initialize()
	if(DB.Profession[ProfessionID] == nil) then
		local name, icon, _, _, _, _, skillLine = GetProfessionInfo(ProfessionID)
		DB.Profession[ProfessionID] = {
			ID = ProfessionID,
			Name = name,
			Icon = icon,
			SkillLineID = skillLine
		}
	end
	return DB.Profession[ProfessionID]
end