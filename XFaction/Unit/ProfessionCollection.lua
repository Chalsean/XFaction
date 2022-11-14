local XFG, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local GetAllProfessionIDs = C_TradeSkillUI.GetAllProfessionTradeSkillLines
local GetProfessionName = C_TradeSkillUI.GetTradeSkillDisplayName
local GetProfessionIcon = C_TradeSkillUI.GetTradeSkillTexture

ProfessionCollection = ObjectCollection:newChildConstructor()

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
			profession:SetID(ID)
			profession:SetIconID(GetProfessionIcon(ID))
			profession:SetName(GetProfessionName(ID))
			profession:SetKey(ID)
			self:Add(profession)
			XFG:Info(ObjectName, 'Initialized profession [%d:%s]', profession:GetID(), profession:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion