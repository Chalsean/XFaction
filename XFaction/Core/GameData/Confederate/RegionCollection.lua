local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RegionCollection'

XFC.RegionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Region List
local RegionData =
{
	'US', -- includes brazil, oceania
	'KR', 
	'EU', -- includes russia
	'TW', 
	'CN'
}
--#endregion

--#region Constructors
function XFC.RegionCollection:new()
	local object = XFC.RegionCollection.parent.new(self)
	object.__name = 'RegionCollection'
	object.current = nil
    return object
end

function XFC.RegionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, name in ipairs(RegionData) do

			local region = XFC.Region:new()
			region:Initialize()
			region:Key(id)
			region:ID(id)
			region:Name(name)
			self:Add(region)
			XF:Info(self:ObjectName(), 'Initialized region: [%d:%s]', region:ID(), region:Name())	

			if(region:ID() == XFF:RegionCurrent()) then
				self:Current(region)
				XF:Info(self:ObjectName(), 'Player region [%d:%s]', region:ID(), region:Name())
			end

			
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.RegionCollection:Current(inRegion)
	assert(type(inRegion) == 'table' and inRegion.__name == 'Region' or inRegion == nil, 'argument must be Region object or nil')
	if(inRegion ~= nil) then
		self.current = inRegion
	end
	return self.current
end
--#endregion