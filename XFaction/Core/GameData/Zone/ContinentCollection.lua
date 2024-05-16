local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ContinentCollection'

ContinentCollection = XFC.ObjectCollection:newChildConstructor()

function ContinentCollection:new()
	local object = ContinentCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function ContinentCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, continent in self:Iterator() do
		if(continent:HasID(inID)) then
			return continent
		end
	end
end