local XFG, G = unpack(select(2, ...))

FactionCollection = ObjectCollection:newChildConstructor()

function FactionCollection:new()
	local _Object = FactionCollection.parent.new(self)
	_Object.__name = 'FactionCollection'
    return _Object
end

function FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i, _FactionName in pairs (XFG.Settings.Factions) do
			XFG:Debug(self:GetObjectName(), 'Initializing faction [%s]', _FactionName)
			local _NewFaction = Faction:new()
			_NewFaction:SetName(_FactionName)
			_NewFaction:Initialize()
			_NewFaction:SetKey(i)
			self:AddObject(_NewFaction)
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function FactionCollection:GetFactionByName(inName)
	assert(type(inName) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetName() == inName) then
			return _Faction
		end
	end
end

function FactionCollection:GetFactionByID(inID)
	assert(type(inID) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetID() == inID) then
			return _Faction
		end
	end
end