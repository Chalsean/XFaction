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
--#endregion

--#region Initializers
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
							continent:SetKey(zoneName)
							continent:AddID(zoneID)
							continent:SetName(zoneName)
							if(zoneLocale[continent:GetName()]) then
								continent:SetLocaleName(zoneLocale[continent:GetName()])
							end
							XFO.Continents:Add(continent)
							XF:Info(self:GetObjectName(), 'Initialized continent [%s]', continent:GetName())
							alreadyAdded[continent:GetName()] = true
						end

					elseif(not self:Contains(zoneName)) then
						local zone = XFC.Zone:new()
						zone:Initialize()
						zone:SetKey(zoneName)
						zone:AddID(zoneID)
						zone:SetName(zoneName)
						if(zoneLocale[zone:GetName()]) then
							zone:SetLocaleName(zoneLocale[zone:GetName()])
						end
						self:Add(zone)
						alreadyAdded[zone:GetName()] = true
					end
				elseif(XFO.Continents:Contains(zoneName)) then
					XFO.Continents:Get(zoneName):AddID(zoneID)
				else
					self:Get(zoneName):AddID(zoneID)
				end
			end
		end

		for _, zone in self:Iterator() do
			local continentID = library:Execute('GetContinentMapID', zone:GetID())
			if(continentID) then
				local continent = XFO.Continents:GetByID(tonumber(continentID))
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
function XFC.ZoneCollection:ContainsByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID] ~= nil
end

function XFC.ZoneCollection:GetByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID]
end

function XFC.ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone', 'argument must be Zone object')
	self.parent.Add(self, inZone)
	for _, ID in inZone:IDIterator() do
		self.zoneByID[ID] = inZone
	end
end

function XFC.ZoneCollection:AddZone(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local zone = XFC.Zone:new()
		zone:Initialize()
		zone:SetKey(inZoneName)
		zone:SetName(inZoneName)
		self:Add(zone)
		XF:Info(self:GetObjectName(), 'Initialized zone [%s]', zone:GetName())
	end
end
--#endregion