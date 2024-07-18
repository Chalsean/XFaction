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
			local continentID = lib:GetContinentMapID(zone:ID())
			if(continentID) then
				local continent = XFO.Continents:Get(tonumber(continentID))
				if(continent) then
					zone:Continent(continent)
				end
			end
		end

		self:Add('?')

		XF.Events:Add({
			name = 'Zone',
			event = 'ZONE_CHANGED_NEW_AREA', 
			callback = XFO.Zones.CallbackZoneChanged
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.ZoneCollection:Contains(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number', 'argument must be string or number')
	if(type(inKey) == 'number') then
		return self.zoneByID[inKey] ~= nil
	end
	return self.parent.Contains(self, inKey)
end

function XFC.ZoneCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number', 'argument must be string or number')
	if(type(inKey) == 'number') then
		return self.zoneByID[inKey]
	end
	return self.parent.Get(self, inKey)
end

function XFC.ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone' or type(inZone) == 'string')
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

-- Zone changes are kinda funky, during a zone change C_Club.GetMemberInfo returns a lot of nils
-- So use a different API, detect zone text change, only update that information and broadcast
function XFC.ZoneCollection:CallbackZoneChanged()
	local self = XFO.Zones
    if(XF.Initialized) then 
        try(function ()
            local zoneName = XFF.PlayerZone()
            if(zoneName ~= nil and zoneName ~= XF.Player.Unit:Zone():Name()) then
                if(not self:Contains(zoneName)) then
                    self:Add(zoneName)
                end
                XF.Player.Unit:Zone(self:Get(zoneName))
				--XF.Player.Unit:Broadcast()
            end
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
end
--#endregion