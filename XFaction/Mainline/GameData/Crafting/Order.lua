local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local GetRecipeResultItem = C_TooltipInfo.GetRecipeResultItem

--#region Accessors
function XFC.Order:IsPublic()
    return self.type == Enum.CraftingOrderType.Public
end

function XFC.Order:IsGuild()
    return self.type == Enum.CraftingOrderType.Guild
end

function XFC.Order:IsPersonal()
    return self.type == Enum.CraftingOrderType.Personal
end

function XFC.Order:GetLink()
    local item = GetRecipeResultItem(self:GetRecipeID(), nil, nil, nil, self:GetQuality())
    if(item ~= nil) then return item.hyperlink end
    return nil
end
--#endregion