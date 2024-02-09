local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'RegionCollection'

XFC.RegionCollection = ObjectCollection:newChildConstructor()

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
--#endregion

--#region Initializers
-- Region information comes from disk, so no need to stick in cache
function XFC.RegionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, name in ipairs(RegionData) do
			local region = XFC.Region:new()
			region:SetKey(id)
			region:SetName(name)
			self:Add(region)

			if(id == GetCurrentRegion()) then
				region:IsCurrent(true)
				self:SetCurrent(region)
				XF:Info(ObjectName, 'Initialized player region [%d:%s]', region:GetKey(), region:GetName())
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.RegionCollection:GetCurrent()
	return self.current
end

function XFC.RegionCollection:SetCurrent(inRegion)
	assert(type(inRegion) == 'table' and inRegion.__name ~= nil and inRegion.__name == 'Region', 'argument must be Region object')
	self.current = inRegion
end
--#endregion