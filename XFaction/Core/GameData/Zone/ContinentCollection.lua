local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ContinentCollection'

XFC.ContinentCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructor
function XFC.ContinentCollection:new()
	local object = XFC.ContinentCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.ContinentCollection:Get(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string')
	if(type(inKey) == 'number') then
		for _, continent in self:Iterator() do
			if(continent:ID(inID)) then
				return continent
			end
		end
	end
	return self.parent.Get(self, inKey)
end
--#endregion