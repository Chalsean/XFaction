local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ClassCollection'

XFC.ClassCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ClassCollection:new()
	local object = XFC.ClassCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.ClassCollection:Get(inID)
	assert(type(inID) == 'number')
	if (not self:Contains(inID)) then
		self:Add(inID)
	end
	return self.parent.Get(self, inID)
end

function XFC.ClassCollection:Add(inClass)
	assert(type(inClass) == 'table' and inClass.__name == 'Class' or type(inClass) == 'number')
	if (type(inClass) == 'number') then
		local info = XFF.ClassInfo(inClass)
		local r, g, b, hex = XFF.ClassColor(info.classFile)
		local class = XFC.Class:new()
		class:Initialize()
		class:Key(info.classID)
		class:ID(info.classID)
		class:Name(info.className)
		class:APIName(info.classFile)
		class:RGB(r, g, b)
		class:Hex(hex)
		self:Add(class)
		XF:Info(self:ObjectName(), 'Initialized class [%d:%s]', class:ID(), class:Name())
	else
		self.parent.Add(self, inClass)
	end
end
--#endregion