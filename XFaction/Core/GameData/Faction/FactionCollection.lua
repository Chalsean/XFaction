local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'FactionCollection'

XFC.FactionCollection = ObjectCollection:newChildConstructor()

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
--#endregion

--#region Initializers
function XFC.FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, name in ipairs (FactionData) do
			local faction = XFC.Faction:new()
			faction:SetName(name)
			faction:Initialize()
			faction:SetKey(id)
			self:Add(faction)
			XF:Info(ObjectName, 'Initialized faction [%d:%s]', faction:GetKey(), faction:GetName())
		end		
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.FactionCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, faction in self:Iterator() do
		if(faction:GetName() == inName) then
			return faction
		end
	end
end

function XFC.FactionCollection:GetByID(inID)
	assert(type(inID) == 'string')
	for _, faction in self:Iterator() do
		if(faction:GetID() == inID) then
			return faction
		end
	end
end
--#endregion