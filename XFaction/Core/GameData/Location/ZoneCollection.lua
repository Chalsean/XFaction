local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ZoneCollection'

XFC.ZoneCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ZoneCollection:new()
    local object = XFC.ZoneCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.ZoneCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self:Add('?')
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.ZoneCollection:Add(inZone)
	assert(type(inZone) == 'table' and inZone.__name == 'Zone' or type(inZone) == 'string', 'argument must be Zone object or string')
	if(type(inZone) == 'string') then
		if(not self:Contains(inZone)) then
			local zone = XFC.Zone:new()
			zone:Initialize()
			zone:Key(inZone)
			zone:Name(inZone)
			XF:Info(self:ObjectName(), 'Initialized zone [%s]', zone:Name())
			self.parent.Add(self, zone)
		end
	elseif(not self:Contains(inZone:Key())) then
		self.parent.Add(self, inZone)
	end
	
end
--#endregion