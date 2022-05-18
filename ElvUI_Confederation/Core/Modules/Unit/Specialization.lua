local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MSpec'
local Initialized = false

local SpecIDs = {
	250,
	251,
	252,
	577,
	581,
	102,
	103,
	104,
	105,
	253,
	254,
	255,
	62,
	63,
	64,
	268,
	269,
	270,
	65,
	66,
	70,
	256,
	257,
	258,
	259,
	260,
	261,
	262,
	263,
	264,
	265,
	266,
	267,
	71,
	72,
	73
}

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching spec information")
		if(DB.Spec == nil) then
			DB.Spec = {}
		end
		for i = 1, table.getn(SpecIDs) do
			local id, name, _, icon = GetSpecializationInfoByID(SpecIDs[i])
			DB.Spec[id] = {
				ID = id,
				Name = name,
				Icon = icon
			}
		end
		Initialized = true
	end
end

function CON:GetSpec(SpecID)
	Initialize()
	return DB.Spec[SpecID]
end

function CON:GetActiveSpec()
	Initialize()
	local SpecGroupID = GetSpecialization()
	local SpecID = GetSpecializationInfo(SpecGroupID)
	return DB.Spec[SpecID]
end