local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ZoneCollection'

XFC.ZoneCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ZoneCollection:new()
    local object = XFC.ZoneCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ZoneCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self:Add('?')
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Hash
function XFC.ZoneCollection:Add(inZoneName)
	assert(type(inZoneName) == 'string')
	if(not self:Contains(inZoneName)) then
		local zone = XFC.Zone:new()
		zone:Initialize()
		zone:SetKey(inZoneName)
		zone:SetName(inZoneName)		
		XF:Info(ObjectName, 'Initialized zone [%s]', zone:GetName())
		self.parent.Add(zone)
	end
end
--#endregion