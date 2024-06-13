local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ZoneCollection'

ZoneCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function ZoneCollection:new()
    local object = ZoneCollection.parent.new(self)
	object.__name = ObjectName
	object.zoneByID = {}
    return object
end
--#endregion

--#region Initializers
function ZoneCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		local lib = LibStub('LibTourist-3.0')
		local zoneIDs = lib:GetMapIDLookupTable()
		local zoneLocale = lib:GetLookupTable()
		local alreadyAdded = {}

		for zoneID, zoneName in pairs (zoneIDs) do
			if(strlen(zoneName) > 0) then
				zoneID = tonumber(zoneID)
				local continentID = lib:GetContinentMapID(zoneID)

				if(not alreadyAdded[zoneName]) then
					if(continentID and tonumber(continentID) == zoneID) then
						continentID = tonumber(continentID)
						if(not XF.Continents:Contains(zoneName)) then
							local continent = Continent:new()
							continent:Initialize()
							continent:Key(zoneName)
							continent:AddID(zoneID)
							continent:Name(zoneName)
							if(zoneLocale[continent:Name()]) then
								continent:SetLocaleName(zoneLocale[continent:Name()])
							end
							XF.Continents:Add(continent)
							XF:Info(ObjectName, 'Initialized continent [%s]', continent:Name())
							alreadyAdded[continent:Name()] = true
						end

					elseif(not self:Contains(zoneName)) then
						local zone = Zone:new()
						zone:Initialize()
						zone:Key(zoneName)
						zone:AddID(zoneID)
						zone:Name(zoneName)
						if(zoneLocale[zone:Name()]) then
							zone:SetLocaleName(zoneLocale[zone:Name()])
						end
						self:Add(zone)
						alreadyAdded[zone:Name()] = true
					end
				elseif(XF.Continents:Contains(zoneName)) then
					XF.Continents:Get(zoneName):AddID(zoneID)
				else
					self:Get(zoneName):AddID(zoneID)
				end
			end
		end

		for _, zone in self:Iterator() do
			local continentID = lib:GetContinentMapID(zone:ID())
			if(continentID) then
				local continent = XF.Continents:GetByID(tonumber(continentID))
				if(continent) then
					zone:SetContinent(continent)
				end
			end
		end

		self:AddZone('?')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Hash
function ZoneCollection:ContainsByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID] ~= nil
end

function ZoneCollection:GetByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID]
end

function ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone', 'argument must be Zone object')
	self.parent.Add(self, inZone)
	for _, ID in inZone:IDIterator() do
		self.zoneByID[ID] = inZone
	end
end

function ZoneCollection:AddZone(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local zone = Zone:new()
		zone:Initialize()
		zone:Key(inZoneName)
		zone:Name(inZoneName)
		self:Add(zone)
		XF:Info(ObjectName, 'Initialized zone [%s]', zone:Name())
	end
end
--#endregion