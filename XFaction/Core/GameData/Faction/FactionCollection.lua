local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'FactionCollection'

XFC.FactionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Faction List
local FactionData =
{
	'Alliance', 
	'Horde', 
	'Neutral'
}
--#endregion

--#region Constructors
function XFC.FactionCollection:new()
	local object = XFC.FactionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, name in ipairs (FactionData) do
			local faction = XFC.Faction:new()
			faction:Name(name)
			faction:Initialize()
			faction:Key(id)
			self:Add(faction)
			XF:Info(self:ObjectName(), 'Initialized faction [%d:%s]', faction:Key(), faction:Name())
		end		
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.FactionCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number', 'argument must be string or number')
	if(type(inKey) == 'string') then
		for _, faction in self:Iterator() do
			if(faction:Name() == inKey) then
				return faction
			end
		end
	else
		self.parent.Get(self, inKey)
	end
end
--#endregion