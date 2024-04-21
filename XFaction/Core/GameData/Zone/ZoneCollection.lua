local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ZoneCollection'

XFC.ZoneCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ZoneCollection:new()
    local object = XFC.ZoneCollection.parent.new(self)
	object.__name = ObjectName
	object.zoneByID = {}
    return object
end

function XFC.ZoneCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		-- Sandbox LibTourist to trick it into thinking its always retail
		-- After initialization, library is no longer needed, thus scope it for destruction
		local library = XFC.Library:new(); library:Initialize()
		library:Sandbox(LibStub:GetLibrary('LibTourist-3.0'))
		--library:Set('WOW_PROJECT_ID', WOW_PROJECT_MAINLINE)

		local zoneIDs = library:Execute('GetMapIDLookupTable')
		local zoneLocale = library:Execute('GetLookupTable')
		local alreadyAdded = {}

		for zoneID, zoneName in pairs (zoneIDs) do
			if(strlen(zoneName) > 0) then
				zoneID = tonumber(zoneID)
				local continentID = library:Execute('GetContinentMapID', zoneID)

				if(not alreadyAdded[zoneName]) then
					if(continentID and tonumber(continentID) == zoneID) then
						continentID = tonumber(continentID)
						if(not XFO.Continents:Contains(zoneName)) then
							local continent = XFC.Continent:new()
							continent:Initialize()
							continent:Key(zoneName)
							continent:ID(zoneID)
							continent:Name(zoneName)
							if(zoneLocale[continent:Name()]) then
								continent:LocaleName(zoneLocale[continent:Name()])
							end
							XFO.Continents:Add(continent)
							XF:Info(self:ObjectName(), 'Initialized continent [%s]', continent:Name())
							alreadyAdded[continent:Name()] = true
						end

					elseif(not self:Contains(zoneName)) then
						local zone = XFC.Zone:new()
						zone:Initialize()
						zone:Key(zoneName)
						zone:ID(zoneID)
						zone:Name(zoneName)
						if(zoneLocale[zone:Name()]) then
							zone:LocaleName(zoneLocale[zone:Name()])
						end
						self:Add(zone)
						alreadyAdded[zone:Name()] = true
					end
				elseif(XFO.Continents:Contains(zoneName)) then
					XFO.Continents:Get(zoneName):ID(zoneID)
				else
					self:Get(zoneName):ID(zoneID)
				end
			end
		end

		for _, zone in self:Iterator() do
			local continentID = library:Execute('GetContinentMapID', zone:ID())
			if(continentID) then
				local continent = XFO.Continents:Get(tonumber(continentID))
				if(continent) then
					zone:Continent(continent)
				end
			end
		end

		self:Add('?')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.ZoneCollection:Contains(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number', 'argument must be string or number')
	if(type(inKey) == 'number') then
		return self.zoneByID[inID] ~= nil
	end
	return self.parent.Contains(self, inKey)
end

function XFC.ZoneCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number', 'argument must be string or number')
	if(type(inKey) == 'number') then
		return self.zoneByID[inID]
	end
	return self.parent.Get(self, inKey)
end

function XFC.ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone' or type(inZone) == 'string', 'argument must be Zone object or string')
	if(type(inZone) == 'string') then
		if(not self:Contains(inZone)) then
			local zone = XFC.Zone:new()
			zone:Initialize()
			zone:Key(inZone)
			zone:Name(inZone)
			self.parent.Add(self, zone)
			XF:Info(self:ObjectName(), 'Initialized zone [%s]', zone:Name())
		end
	else
		self.parent.Add(self, inZone)
		if(inZone:ID() ~= nil) then
			self.zoneByID[inZone:ID()] = inZone
		end
	end
end
--#endregion