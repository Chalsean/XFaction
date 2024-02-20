local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ProfessionCollection'

XFC.ProfessionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Profession List
local ProfessionData =
{
	-- [SkillLineID] = "EnglishName,IconID"
	[164] = "Blacksmithing,4620670",
	[165] = "Leatherworking,4620678",
	[171] = "Alchemy,4620669",
	[182] = "Herbalism,4620675",
	[186] = "Mining,4620679",
	[197] = "Tailoring,4620681",
	[202] = "Engineering,4620673",
	[333] = "Enchanting,4620672",
	[393] = "Skinning,4620680",
	[755] = "Jewelcrafting,4620677",
	[773] = "Inscription,4620676",
}
--#endregion

--#region Constructors
function XFC.ProfessionCollection:new()
	local object = XFC.ProfessionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, data in pairs (ProfessionData) do
			local professionData = string.Split(data, ',')
			local profession = XFC.Profession:new()
			profession:SetID(tonumber(id))
			profession:SetIconID(tonumber(professionData[2]))
			profession:SetName(professionData[1])
			profession:SetKey(tonumber(id))
			profession:IsInitialized(true)
			self:Add(profession)
			XF:Info(self:GetObjectName(), 'Initialized profession [%d:%s]', profession:GetID(), profession:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion