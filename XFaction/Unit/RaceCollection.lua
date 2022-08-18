local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaceCollection'

RaceCollection = ObjectCollection:newChildConstructor()

function RaceCollection:new()
	local _Object = RaceCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function RaceCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		local _RaceLib = LibStub('LibRace')
		local _BabbleLib = LibStub('LibBabble-Race-3.0')
		local _LookupTable = _BabbleLib:GetUnstrictLookupTable()
		for _, _Race in _RaceLib:Iterator() do
			local _NewRace = Race:new()
			_NewRace:SetKey(_Race.ID)
			_NewRace:SetID(_Race.ID)
			_NewRace:SetName(_Race.Name)
			if(_LookupTable[_NewRace:GetName()] ~= nil) then
				_NewRace:SetLocaleName(_LookupTable[_NewRace:GetName()])
			else
				_NewRace:SetLocaleName(_NewRace:GetName())
			end
			_NewRace:SetFaction(XFG.Factions:GetFactionByName(_Race.Faction))
			self:AddObject(_NewRace)
			XFG:Info(ObjectName, 'Initialized race [%s]', _NewRace:GetName())
		end
		self:IsInitialized(true)
	end
end

function RaceCollection:GetRaceByName(inName, inFaction)
	assert(type(inName) == 'string' and type(inFaction) == 'table')	
	for _, _Race in pairs (self._Races) do
		if(_Race:GetName() == inName and inFaction:Equals(_Race:GetFaction())) then
			return _Race
		end
	end
end