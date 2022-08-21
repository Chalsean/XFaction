local XFG, G = unpack(select(2, ...))
local ObjectName = 'FactionCollection'

FactionCollection = ObjectCollection:newChildConstructor()

function FactionCollection:new()
	local _Object = FactionCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i, _FactionName in pairs (XFG.Settings.Factions) do
			XFG:Debug(ObjectName, 'Initializing faction [%s]', _FactionName)
			local _Faction = Faction:new()
			_Faction:SetName(_FactionName)
			_Faction:Initialize()
			_Faction:SetKey(i)
			self:Add(_Faction)
		end
		self:IsInitialized(true)
	end
end

function FactionCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetName() == inName) then
			return _Faction
		end
	end
end

function FactionCollection:GetByID(inID)
	assert(type(inID) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetID() == inID) then
			return _Faction
		end
	end
end