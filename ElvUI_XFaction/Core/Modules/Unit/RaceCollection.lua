local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'RaceCollection'
local LogCategory = 'UCRace'
local MaxRaces = 37

RaceCollection = {}

function RaceCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
		self._Key = nil
        self._Races = {}
		self._RaceCount = 0
		self._Initialized = false
    end

    return Object
end

function RaceCollection:Initialize()
	if(self._Initialized == false) then
		self._Key = math.GenerateUID()
		for i = 1, MaxRaces do
			local _RaceInfo = C_CreatureInfo.GetRaceInfo(i)

			local _NewRace = Race:new()
			_NewRace:SetKey(_RaceInfo.raceID)
			_NewRace:SetID(_RaceInfo.raceID)
			_NewRace:SetName(_RaceInfo.raceName)
			local _FactionInfo = C_CreatureInfo.GetFactionInfo(_NewRace:GetID())
			_NewRace:SetFaction(_FactionInfo.groupTag)

			self:AddRace(_NewRace)
		end
		self._Initialized = true
	end
end

function RaceCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _RaceCount (" .. type(self._RaceCount) .. "): ".. tostring(self._RaceCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Race in pairs (self._Races) do
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
	assert(type(inName) == 'string' and type(inFaction) == 'string')
	
	for _, _Race in pairs (self._Races) do
		if(_Race:GetName() == inName and _Race:GetFaction() == inFaction) then
			return _Race
		end
	end

    return nil
end

function RaceCollection:AddRace(inRace)
	assert(type(inRace) == 'table' and inRace.__name ~= nil and inRace.__name == 'Race', "argument must be Race object")
	if(self:Contains(inRace:GetKey()) == false) then
		self._RaceCount = self._RaceCount + 1
	end
	self._Races[inRace:GetKey()] = inRace
    return self:Contains(inRace:GetKey())
end