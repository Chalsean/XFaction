local XFG, G = unpack(select(2, ...))
local ObjectName = 'ZoneCollection'

ZoneCollection = ObjectCollection:newChildConstructor()

function ZoneCollection:new()
    local _Object = ZoneCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._ZoneByID = {}
    return _Object
end

function ZoneCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		local _Tourist = LibStub('LibTourist-3.0')

		local _ZoneIDs = _Tourist:GetMapIDLookupTable()
		local _ZoneLocale = _Tourist:GetLookupTable()
		local _AlreadyAdded = {}

		for _ZoneID, _ZoneName in pairs (_ZoneIDs) do
			if(strlen(_ZoneName) > 0) then
				_ZoneID = tonumber(_ZoneID)
				local _ContinentID = _Tourist:GetContinentMapID(_ZoneID)

				if(not _AlreadyAdded[_ZoneName]) then
					if(_ContinentID and tonumber(_ContinentID) == _ZoneID) then
						_ContinentID = tonumber(_ContinentID)
						if(not XFG.Continents:Contains(_ZoneName)) then
							local _NewContinent = Continent:new()
							_NewContinent:Initialize()
							_NewContinent:SetKey(_ZoneName)
							_NewContinent:AddID(_ZoneID)
							_NewContinent:SetName(_ZoneName)
							if(_ZoneLocale[_NewContinent:GetName()]) then
								_NewContinent:SetLocaleName(_ZoneLocale[_NewContinent:GetName()])
							end
							XFG.Continents:Add(_NewContinent)
							XFG:Info(ObjectName, 'Initialized continent [%s]', _NewContinent:GetName())
							_AlreadyAdded[_NewContinent:GetName()] = true
						end

					elseif(not self:Contains(_ZoneName)) then
						local _NewZone = Zone:new()
						_NewZone:Initialize()
						_NewZone:SetKey(_ZoneName)
						_NewZone:AddID(_ZoneID)
						_NewZone:SetName(_ZoneName)
						if(_ZoneLocale[_NewZone:GetName()]) then
							_NewZone:SetLocaleName(_ZoneLocale[_NewZone:GetName()])
						end
						self:Add(_NewZone)
						_AlreadyAdded[_NewZone:GetName()] = true
					end
				elseif(XFG.Continents:Contains(_ZoneName)) then
					XFG.Continents:Get(_ZoneName):AddID(_ZoneID)
				else
					self:Get(_ZoneName):AddID(_ZoneID)
				end
			end
		end

		for _, _Zone in self:Iterator() do
			local _ContinentID = _Tourist:GetContinentMapID(_Zone:GetID())
			if(_ContinentID) then
				local _Continent = XFG.Continents:GetByID(tonumber(_ContinentID))
				if(_Continent) then
					_Zone:SetContinent(_Continent)
				end
			end			
			--XFG:Info(ObjectName, 'Initialized zone [%s]', _Zone:GetName())
		end

		self:AddZone('?')
		self:IsInitialized(true)
	end
end

function ZoneCollection:ContainsByID(inID)
	assert(type(inID) == 'number')
	return self._ZoneByID[inID] ~= nil
end

function ZoneCollection:GetByID(inID)
	assert(type(inID) == 'number')
	return self._ZoneByID[inID]
end

function ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name ~= nil and inZone.__name == 'Zone', 'argument must be Zone object')
	self.parent.Add(self, inZone)
	for _, _ID in inZone:IDIterator() do
		self._ZoneByID[_ID] = inZone
	end
end

function ZoneCollection:AddZone(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local _NewZone = Zone:new()
		_NewZone:Initialize()
		_NewZone:SetKey(inZoneName)
		_NewZone:SetName(inZoneName)
		self:Add(_NewZone)
		if(XFG.DebugFlag) then
			XFG:Info(ObjectName, 'Initialized zone [%s]', _NewZone:GetName())
		end
	end
end