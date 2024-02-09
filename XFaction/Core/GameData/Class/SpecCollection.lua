local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'SpecCollection'

XFC.SpecCollection = ObjectCollection:newChildConstructor()

--#region Spec List
local SpecData =
{
	-- [SpecID] = "EnglishName,IconID"
	[62] = "Arcane,135932",
	[63] = "Fire,135810",
	[64] = "Frost,135846",
	[65] = "Holy,135920",
	[66] = "Protection,236264",
	[70] = "Retribution,135873",
	[71] = "Arms,132355",
	[72] = "Fury,132347",
	[73] = "Protection,132341",
	[102] = "Balance,136096",
	[103] = "Feral,132115",
	[104] = "Guardian,132276",
	[105] = "Restoration,136041",
	[250] = "Blood,135770",
	[251] = "Frost,135773",
	[252] = "Unholy,135775",
	[253] = "Beast Mastery,461112",
	[254] = "Marksmanship,3",
	[255] = "Survival,461113",
	[256] = "Discipline,135940",
	[257] = "Holy,237542",
	[258] = "Shadow,136207",
	[259] = "Assassination,236270",
	[260] = "Outlaw,236286",
	[261] = "Subtlety,132320",
	[262] = "Elemental,136048",
	[263] = "Enhancement,237581",
	[264] = "Restoration,136052",
	[265] = "Affliction,136145",
	[266] = "Demonology,136172",
	[267] = "Destruction,136186",
	[268] = "Brewmaster,608951",
	[269] = "Windwalker,608953",
	[270] = "Mistweaver,608952",	
	[577] = "Havoc,1247264",
	[581] = "Vengeance,1247265",
	[1467] = "Devastation,4511811",
	[1468] = "Preservation,4511812",
	[1473] = "Augmentation,5198700",
}
--#endregion

--#region Constructors
function XFC.SpecCollection:new()
    local object = XFC.SpecCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, data in pairs (SpecData) do
			local specData = string.Split(data, ',')
			local spec = XFC.Spec:new()
			spec:Initialize()
			spec:SetKey(tonumber(id))
			spec:SetID(tonumber(id))
			spec:SetName(specData[1])
			spec:SetIconID(tonumber(specData[2]))
			self:Add(spec)
			XF:Info(ObjectName, 'Initialized spec [%d:%s]', spec:GetID(), spec:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion