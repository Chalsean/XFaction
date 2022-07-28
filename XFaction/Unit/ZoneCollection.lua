local XFG, G = unpack(select(2, ...))
local ObjectName = 'ZoneCollection'
local LogCategory = 'UCZone'

ZoneCollection = {}

function ZoneCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Zones = {}
	self._ZoneByID = {}
	self._ZoneCount = 0
	self._Initialized = false
	self._Tourist = nil

    return Object
end

function ZoneCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())

		local _ZoneIDs = XFG.Lib.Tourist:GetMapIDLookupTable()
		self._Tourist = XFG.Lib.Tourist:GetLookupTable()
		local _AlreadyAdded = {}

		for _ZoneID, _ZoneName in pairs (_ZoneIDs) do
			if(strlen(_ZoneName) > 0) then
				_ZoneID = tonumber(_ZoneID)
				local _ContinentID = XFG.Lib.Tourist:GetContinentMapID(_ZoneID)

				if(not _AlreadyAdded[_ZoneName]) then
					if(_ContinentID and tonumber(_ContinentID) == _ZoneID) then
						_ContinentID = tonumber(_ContinentID)
						if(not XFG.Continents:Contains(_ZoneName)) then
							local _NewContinent = Continent:new()
							_NewContinent:Initialize()
							_NewContinent:SetKey(_ZoneName)
							_NewContinent:AddID(_ZoneID)
							_NewContinent:SetName(_ZoneName)
							if(self._Tourist[_NewContinent:GetName()]) then
								_NewContinent:SetLocaleName(self._Tourist[_NewContinent:GetName()])
							end
							XFG.Continents:AddContinent(_NewContinent)
							XFG:Info(LogCategory, 'Initialized continent [%s]', _NewContinent:GetName())
							_AlreadyAdded[_NewContinent:GetName()] = true
						end

					elseif(not self:Contains(_ZoneName)) then
						local _NewZone = Zone:new()
						_NewZone:Initialize()
						_NewZone:SetKey(_ZoneName)
						_NewZone:AddID(_ZoneID)
						_NewZone:SetName(_ZoneName)
						if(self._Tourist[_NewZone:GetName()]) then
							_NewZone:SetLocaleName(self._Tourist[_NewZone:GetName()])
						end
						self:AddZone(_NewZone)
						_AlreadyAdded[_NewZone:GetName()] = true
					end
				elseif(XFG.Continents:Contains(_ZoneName)) then
					XFG.Continents:GetContinent(_ZoneName):AddID(_ZoneID)
				else
					self:GetZone(_ZoneName):AddID(_ZoneID)
				end
			end
		end

		for _, _Zone in self:Iterator() do
			local _ContinentID = XFG.Lib.Tourist:GetContinentMapID(_Zone:GetID())
			if(_ContinentID) then
				local _Continent = XFG.Continents:GetContinentByID(tonumber(_ContinentID))
				if(_Continent) then
					_Zone:SetContinent(_Continent)
				end
			end			
			XFG:Info(LogCategory, 'Initialized zone [%s]', _Zone:GetName())
		end

		local _NewZone = Zone:new()
		_NewZone:Initialize()
		_NewZone:SetKey('?')
		_NewZone:SetName('?')
		self:AddZone(_NewZone)

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ZoneCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ZoneCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _ZoneCount (' .. type(self._ZoneCount) .. '): ' .. tostring(self._ZoneCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Zone in self:Iterator() do
		_Zone:Print()
	end
end

function ZoneCollection:GetKey()
    return self._Key
end

function ZoneCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ZoneCollection:Contains(inKey)
	assert(type(inKey) == 'string')
    return self._Zones[inKey] ~= nil
end

function ZoneCollection:ContainsByID(inID)
	assert(type(inID) == 'number')
	return self._ZoneByID[inID] ~= nil
end

function ZoneCollection:GetZone(inKey)
	assert(type(inKey) == 'string')
    return self._Zones[inKey]
end

function ZoneCollection:GetZoneByID(inID)
	assert(type(inID) == 'number')
	return self._ZoneByID[inID]
end

function ZoneCollection:AddZone(inZone)
    assert(type(inZone) == 'table' and inZone.__name ~= nil and inZone.__name == 'Zone', 'argument must be Zone object')
	if(not self:Contains(inZone:GetKey())) then
		self._ZoneCount = self._ZoneCount + 1
	end		
	self._Zones[inZone:GetKey()] = inZone
	for _, _ID in inZone:IDIterator() do
		self._ZoneByID[_ID] = inZone
	end
	return self:Contains(inZone:GetKey())
end

function ZoneCollection:AddZoneName(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local _NewZone = Zone:new()
		_NewZone:Initialize()
		_NewZone:SetKey(inZoneName)
		_NewZone:SetName(inZoneName)

		if(self._Tourist[_NewZone:GetName()]) then
			_NewZone:SetLocaleName(self._Tourist[_NewZone:GetName()])
		end

		self:AddZone(_NewZone)
		XFG:Info(LogCategory, 'Initialized zone [%s]', _NewZone:GetName())
	end
	return self:GetZone(inZoneName)
end

function ZoneCollection:Iterator()
	return next, self._Zones, nil
end