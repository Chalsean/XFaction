local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'FactionCollection'

XFC.FactionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Faction List
local FactionData =
{
	'Alliance,Common,2565243', 
	'Horde,Orcish,463451', 
	'Neutral,Common,132311'
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
		for id, data in ipairs (FactionData) do
			local factionData = string.Split(data, ',')
			local faction = XFC.Faction:new()			
			faction:Initialize()
			faction:Key(id)
			faction:ID(id)
			faction:Name(factionData[1])
			faction:Language(factionData[2])
			faction:IconID(tonumber(factionData[3]))
			self:Add(faction)
			XF:Info(self:ObjectName(), 'Initialized faction [%d:%s]', faction:Key(), faction:Name())
		end		
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.FactionCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number')
	if(type(inKey) == 'string') then
		if(inKey == 'A') then inKey = 'Alliance'
		elseif(inKey == 'H') then inKey = 'Horde'
		elseif(inKey == 'N') then inKey = 'Neutral' 
		end

		for _, faction in self:Iterator() do
			if(faction:Name() == inKey) then
				return faction
			end
		end
	else
		return self.parent.Get(self, inKey)
	end
end
--#endregion