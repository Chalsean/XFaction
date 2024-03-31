local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ContinentCollection'

XFC.ContinentCollection = XFC.ObjectCollection:newChildConstructor()

function XFC.ContinentCollection:new()
	local object = XFC.ContinentCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.ContinentCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, continent in self:Iterator() do
		if(continent:HasID(inID)) then
			return continent
		end
	end
end