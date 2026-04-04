local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'LocationCollection'

XFC.LocationCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.LocationCollection:new()
    local object = XFC.LocationCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.LocationCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:Add('?')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.LocationCollection:Add(inLocation)
    assert(type(inLocation) == 'table' and inLocation.__name == 'Location' or type(inLocation) == 'string' or type(inLocation) == 'number')
	if(type(inLocation) == 'string') then
		if(not self:Contains(inLocation)) then
			local location = XFC.Location:new()
			location:Initialize()
			location:Key(inLocation)
			location:Name(inLocation)
			self.parent.Add(self, location)
			XF:Info(self:ObjectName(), 'Initialized location [%s]', location:Name())
		end
	elseif(type(inLocation) == 'number') then
		local info = XFF.LocationInfo(inLocation)
		if(info ~= nil) then
			local location = XFC.Location:new()
			location:Initialize()
			location:Key(inLocation)
			location:ID(info.mapID)
			location:Name(info.name)
			self.parent.Add(self, location)
			XF:Info(self:ObjectName(), 'Initialized location [%d:%s]', location:ID(), location:Name())
		end
	else
		self.parent.Add(self, inLocation)
	end
end

function XFC.LocationCollection:GetCurrentLocation()
	local id = XFF.PlayerLocationID("player")
	if(id ~= nil) then
		if(not self:Contains(id)) then
			self:Add(id)
		end
		return self:Get(id)
	end

	local zone = XFF.PlayerZone()
	if(zone ~= nil and not self:Contains(zone)) then
		self:Add(zone)
	end
	return self:Get(zone)
end
--#endregion