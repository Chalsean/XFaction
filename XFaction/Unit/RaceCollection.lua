local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaceCollection'
local LogCategory = 'UCRace'

RaceCollection = {}

function RaceCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Races = {}
	self._RaceCount = 0
	self._Initialized = false

    return Object
end

function RaceCollection:Initialize()
	if(self:IsInitialized() == false) then
		self._Key = math.GenerateUID()
		local _LookupTable = XFG.Lib.BabbleRace:GetUnstrictLookupTable()
		for _, _Race in XFG.Lib.Race:Iterator() do
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
			self:AddRace(_NewRace)
			XFG:Info(LogCategory, 'Initialized race [%s]', _NewRace:GetName())
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function RaceCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function RaceCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _RaceCount (' .. type(self._RaceCount) .. '): ' .. tostring(self._RaceCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Race in self:Iterator() do
		_Race:Print()
	end
end

function RaceCollection:Contains(inKey)
	assert(type(inKey) == 'number')
    return self._Races[inKey] ~= nil
end

function RaceCollection:GetRace(inKey)
	assert(type(inKey) == 'number')
    return self._Races[inKey]
end

function RaceCollection:GetRaceByName(inName, inFaction)
	assert(type(inName) == 'string' and type(inFaction) == 'table')
	
	for _, _Race in pairs (self._Races) do
		if(_Race:GetName() == inName and inFaction:Equals(_Race:GetFaction())) then
			return _Race
		end
	end

    return nil
end

function RaceCollection:AddRace(inRace)
	assert(type(inRace) == 'table' and inRace.__name ~= nil and inRace.__name == 'Race', 'argument must be Race object')
	if(self:Contains(inRace:GetKey()) == false) then
		self._RaceCount = self._RaceCount + 1
	end
	self._Races[inRace:GetKey()] = inRace
    return self:Contains(inRace:GetKey())
end

function RaceCollection:Iterator()
	return next, self._Races, nil
end