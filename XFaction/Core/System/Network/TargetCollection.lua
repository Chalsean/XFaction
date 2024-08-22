local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TargetCollection'

XFC.TargetCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TargetCollection:new()
	local object = XFC.TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XFO.Guilds:Iterator() do
			local target = XFC.Target:new()
			target:Initialize()
			target:Guild(guild)
			target:Key(guild:Key())
			target:ID(guild:Key())
			target:Name(guild:Name())
			self:Add(target)
			XF:Info(self:ObjectName(), 'Initializing target [%s]', target:Key())
			if(target:Guild():Equals(XF.Player.Guild)) then
				XF.Player.Target = target
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.TargetCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
	inMessage:FromUnit():Target():ChatRecipient(inMessage:FromUnit())
end
--#endregion