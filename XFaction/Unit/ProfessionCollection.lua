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
		if(not XFG.Cache.UIReload or XFG.Cache.Professions == nil) then
			XFG.Cache.Professions = {}
			for _, ID in ipairs (GetAllProfessionIDs()) do
				XFG.Cache.Professions[#XFG.Cache.Professions + 1] = {
					ID = ID,
					Name = GetProfessionName(ID),
					Icon = GetProfessionIcon(ID),
				}
			end
		else
			XFG:Debug(ObjectName, 'Profession information found in cache')
		end

		for _, data in ipairs(XFG.Cache.Professions) do
			local profession = Profession:new()
			profession:SetID(data.ID)
			profession:SetIconID(data.Icon)
			profession:SetName(data.Name)
			profession:SetKey(data.ID)
			self:Add(profession)
			XFG:Info(ObjectName, 'Initialized profession [%d:%s]', profession:GetID(), profession:GetName())
		end	
	
		self:IsInitialized(true)
	end
end
--#endregion