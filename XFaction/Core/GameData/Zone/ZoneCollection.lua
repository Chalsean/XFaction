local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ZoneCollection'

XFC.ZoneCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ZoneCollection:new()
    local object = XFC.ZoneCollection.parent.new(self)
	object.__name = ObjectName
	object.zoneByID = {}
    return object
end
--#endregion

--#region Hash
function XFC.ZoneCollection:AddZone(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local zone = XFC.Zone:new()
		zone:Initialize()
		zone:SetKey(inZoneName)
		zone:SetName(inZoneName)
		self:Add(zone)
		XF:Info(ObjectName, 'Initialized zone [%s]', zone:GetName())
	end
end
--#endregion