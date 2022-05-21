local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CRace'
local LogCategory = 'O' .. ObjectName
local MaxRaces = 37

RaceCollection = {}

function RaceCollection:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or 
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Races = {}
		self._RaceCount = 0
		self._Initialized = false
    end

    return Object
end

function RaceCollection:Initialize()
	if(self._Initialized == false) then
		for i = 1, MaxRaces do
			local _RaceInfo = C_CreatureInfo.GetRaceInfo(i)
			local _Race = Race:new()
			_Race:SetID(_RaceInfo.raceID)
			_Race:SetName(_RaceInfo.raceName)
			local _FactionInfo = C_CreatureInfo.GetFactionInfo(_Race:GetID())
			_Race:SetFaction(_FactionInfo.groupTag)

			self._Races[_Race:GetID()] = _Race
			self._RaceCount = self._RaceCount + 1
		end
		self._Initialized = true
	end
end

function RaceCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "RaceCollection Object")
	CON:Debug(LogCategory, "  _RaceCount (" .. type(self._RaceCount) .. "): ".. tostring(self._RaceCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Race in pairs (self._Races) do
		_Race:Print()
	end
end

function RaceCollection:GetRace(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number', "argument must be string or number")

	if(_typeof == 'string') then
		for i = 1, self._RaceCount do
			local _Race = self._Races[i]
			if(_Race:GetName() == _Argument) then
				return _Race
			end
		end
	end
	
    return self._Races[_Argument]
end