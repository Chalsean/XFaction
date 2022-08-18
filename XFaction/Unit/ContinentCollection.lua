local XFG, G = unpack(select(2, ...))
local ObjectName = 'ContinentCollection'

ContinentCollection = ObjectCollection:newChildConstructor()

function ContinentCollection:new()
	local _Object = ContinentCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function ContinentCollection:GetContinentByID(inID)
	assert(type(inID) == 'number')
	for _, _Continent in self:Iterator() do
		if(_Continent:HasID(inID)) then
			return _Continent
		end
	end
end