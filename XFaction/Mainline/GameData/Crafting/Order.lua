local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function

--#region Methods
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
    local item = XFF.CraftingGetItem(self:RecipeID(), nil, nil, nil, self:Quality())
    if(item ~= nil) then return item.hyperlink end
    return nil
end
--#endregion