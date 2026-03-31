local XF, G = unpack(select(2, ...))
local XFF = XF.Function

-- M+
XFF.MythicGetKeyLevel = C_MythicPlus.GetOwnedKeystoneLevel
XFF.MythicGetKeyMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID

-- Crafting
XFF.CraftingQueryServer = C_CraftingOrders.ListMyOrders
XFF.CraftingGetOrders = C_CraftingOrders.GetMyOrders
XFF.CraftingGetRecipe = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility
XFF.CraftingGetSkillProfession = C_TradeSkillUI.GetProfessionNameForSkillLineAbility
XFF.CraftingGetItem = C_TooltipInfo.GetRecipeResultItem

-- Function
XFF.FunctionCreateCallback = C_FunctionContainers.CreateCallback