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

function XFC.SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		XFO.Events:Add({
			name = 'Spec', 
			event = 'ACTIVE_TALENT_GROUP_CHANGED', 
			callback = XFO.Specs.CallbackSpecChanged, 
			instance = true
		})
		self:IsInitialized(true)
	end
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
		local id, name, _, icon = XFF.SpecInfo(inSpec)
		local spec = XFC.Spec:new()
		spec:Initialize()
		spec:Key(id)
		spec:ID(id)
		spec:Name(name)
		spec:IconID(icon)
		spec:Class(XFO.Classes:Get(XFF.SpecClass(id)))
		self:Add(spec)
		XF:Info(self:ObjectName(), 'Initialized spec [%d:%s:%s]', spec:ID(), spec:Name(), spec:Class():Name())
	else
		self.parent.Add(self, inSpec)
	end
end

function XFC.SpecCollection:CallbackSpecChanged()
	local self = XFO.Specs
	try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
		XFO.Mailbox:SendDataMessage()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion