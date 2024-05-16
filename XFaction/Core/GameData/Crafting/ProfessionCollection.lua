local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ProfessionCollection'
local GetAllProfessionIDs = C_TradeSkillUI.GetAllProfessionTradeSkillLines
local GetProfessionName = C_TradeSkillUI.GetTradeSkillDisplayName
local GetProfessionIcon = C_TradeSkillUI.GetTradeSkillTexture

ProfessionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function ProfessionCollection:new()
	local object = ProfessionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, ID in ipairs (GetAllProfessionIDs()) do
			local name = GetProfessionName(ID)
			local profession = Profession:new()
			profession:ID(ID)
			profession:SetIconID(GetProfessionIcon(ID))
			profession:Name(GetProfessionName(ID))
			profession:Key(ID)
			self:Add(profession)
			XF:Info(ObjectName, 'Initialized profession [%d:%s]', profession:ID(), profession:Name())
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function ProfessionCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, profession in self:Iterator() do
		if(profession:Name() == inName) then
			return profession
		end
	end
end
--#endregion