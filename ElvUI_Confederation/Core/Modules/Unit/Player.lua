local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MClass'
local Initialized = false
local MaxClasses = GetNumClasses()

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching class information")

		if(DB.Classes == nil) then
			DB.Classes = {}
		end

		for i = 1, MaxClasses do
			local ClassInfo = C_CreatureInfo.GetClassInfo(i)
			DB.Classes[i] = ClassInfo
		end
		Initialized = true
	end
end

function CON:GetClassID(ClassName)
	Initialize()
	for i = 1, MaxClasses do
		if(DB.Classes[i].className == ClassName) then
			return DB.Classes[i].classID
		end
	end
end

function CON:GetClass(ID)
	Initialize()
	if(DB.Classes[ID] == nil) then
		return nil
	end
	return DB.Classes[ID].className
end