local XFG, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local GetProfessionByID = C_TradeSkillUI.GetTradeSkillLineInfoByID

ProfessionCollection = ObjectCollection:newChildConstructor()

function ProfessionCollection:new()
	local object = ProfessionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(not XFG.Cache.UIReload or XFG.Cache.Professions == nil) then
			XFG.Cache.Professions = {}
			local lib = LibStub('LibProfession')
			for _, profession in lib:Iterator() do
				XFG.Cache.Professions[#XFG.Cache.Professions + 1] = {
					ID = profession.ID,
					Name = profession.Name,
					Icon = profession.Icon,
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