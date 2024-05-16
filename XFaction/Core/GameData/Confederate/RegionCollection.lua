local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RegionCollection'
local Regions = {
	'US', -- includes brazil, oceania
	'KR', 
	'EU', -- includes russia
	'TW', 
	'CN'
}

RegionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function RegionCollection:new()
	local object = RegionCollection.parent.new(self)
	object.__name = 'RegionCollection'
	object.current = nil
    return object
end
--#endregion

--#region Initializers
-- Region information comes from disk, so no need to stick in cache
function RegionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, name in ipairs(Regions) do
			local region = Region:new()
			region:Key(id)
			region:Name(name)
			self:Add(region)

			if(id == GetCurrentRegion()) then
				region:IsCurrent(true)
				self:SetCurrent(region)
				XF:Info(ObjectName, 'Initialized player region [%d:%s]', region:Key(), region:Name())
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function RegionCollection:GetCurrent()
	return self.current
end

function RegionCollection:SetCurrent(inRegion)
	assert(type(inRegion) == 'table' and inRegion.__name ~= nil and inRegion.__name == 'Region', 'argument must be Region object')
	self.current = inRegion
end
--#endregion