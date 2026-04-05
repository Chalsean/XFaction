local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SpecCollection'

XFC.SpecCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.SpecCollection:new()
    local object = XFC.SpecCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.SpecCollection:Get(inID)
	assert(type(inID) == 'number')
	if (not self:Contains(inID)) then
		self:Add(inID)
	end
	return self.parent.Get(self, inID)
end

function XFC.SpecCollection:Add(inSpec)
	assert(type(inSpec) == 'table' and inSpec.__name == 'Spec' or type(inSpec) == 'number')
	if (type(inSpec) == 'number') then
		local id, name, _, icon = GetSpecializationInfoForSpecID(inSpec)
		local spec = XFC.Spec:new()
		spec:Initialize()
		spec:Key(id)
		spec:ID(id)
		spec:Name(name)
		spec:IconID(icon)
		spec:Class(XFO.Classes:Get(C_SpecializationInfo.GetClassIDFromSpecID(id)))
		self:Add(spec)
		XF:Info(self:ObjectName(), 'Initialized spec [%d:%s:%s]', spec:ID(), spec:Name(), spec:Class():Name())
	else
		self.parent.Add(self, inSpec)
	end
end
--#endregion