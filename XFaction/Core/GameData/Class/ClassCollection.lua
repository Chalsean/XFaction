local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ClassCollection'

XFC.ClassCollection = XFC.ObjectCollection:newChildConstructor()

--#region Class List
local ClassData = {
	[1] = "Warrior,WARRIOR,198,155,109,C69B6D",
	[2] = "Paladin,PALADIN,244,140,186,F48CBA",
	[3] = "Hunter,HUNTER,170,211,114,AAD372",
	[4] = "Rogue,ROGUE,255,244,104,FFF468",
	[5] = "Priest,PRIEST,255,255,255,FFFFFF",
	[6] = "Death Knight,DEATHKNIGHT,196,30,58,C41E3A",
	[7] = "Shaman,SHAMAN,0,112,221,0070DD",
	[8] = "Mage,MAGE,63,199,235,3FC7EB",
	[9] = "Warlock,WARLOCK,135,136,238,8788EE",
	[10] = "Monk,MONK,0,255,152,00FF98",
	[11] = "Druid,DRUID,255,124,10,FF7C0A",
	[12] = "Demon Hunter,DEMONHUNTER,163,48,201,A330C9",
	[13] = "Evoker,EVOKER,51,147,127,33937F",
}
--#endregion

--#region Constructors
function XFC.ClassCollection:new()
	local object = XFC.ClassCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ClassCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, data in pairs (ClassData) do
			local classData = string.Split(data, ',')
			local class = XFC.Class:new()
			class:Initialize()
			class:SetKey(tonumber(id))
			class:SetID(tonumber(id))
			class:SetName(classData[1])
			class:SetAPIName(classData[2])
			class:SetRGB(tonumber(classData[3]), tonumber(classData[4]), tonumber(classData[5]))
			class:SetHex(classData[6])
			self:Add(class)
			XF:Info(self:GetObjectName(), 'Initialized class [%d:%s]', class:GetID(), class:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion