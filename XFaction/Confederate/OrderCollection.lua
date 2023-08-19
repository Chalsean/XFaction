local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderCollection'
local GetAllProfessionIDs = C_TradeSkillUI.GetAllProfessionTradeSkillLines
local GetProfessionName = C_TradeSkillUI.GetTradeSkillDisplayName
local GetProfessionIcon = C_TradeSkillUI.GetTradeSkillTexture

OrderCollection = Factory:newChildConstructor()

--#region Constructors
function OrderCollection:new()
	local object = OrderCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function OrderCollection:NewObject()
	return Order:new()
end
--#endregion

--#region Initializers
function OrderCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end
--#endregion