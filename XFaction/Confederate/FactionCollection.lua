local XFG, G = unpack(select(2, ...))
local ObjectName = 'FactionCollection'

FactionCollection = ObjectCollection:newChildConstructor()

function FactionCollection:new()
	local object = FactionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i, factionName in pairs (XFG.Settings.Factions) do
			local faction = Faction:new()
			faction:SetName(factionName)
			faction:Initialize()
			faction:SetKey(i)
			self:Add(faction)
			XFG:Info(ObjectName, 'Initialized faction [%d:%s]', faction:GetKey(), faction:GetName())
		end		
		self:IsInitialized(true)
	end
end

function FactionCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, faction in self:Iterator() do
		if(faction:GetName() == inName) then
			return faction
		end
	end
end

function FactionCollection:GetByID(inID)
	assert(type(inID) == 'string')
	for _, faction in self:Iterator() do
		if(faction:GetID() == inID) then
			return faction
		end
	end
end