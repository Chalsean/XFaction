local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'OrderCollection'

local QueryMyOrdersFromServer = C_CraftingOrders.ListMyOrders
local GetMyOrdersFromServer = C_CraftingOrders.GetMyOrders
local GetRecipe = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility
local GetProfessionForSkill = C_TradeSkillUI.GetProfessionNameForSkillLineAbility
local CreateCallback = C_FunctionContainers.CreateCallback

--#region Initialize
function XFC.OrderCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = 'CraftOrder', 
            event = 'CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE', 
            callback = XFO.Orders.CraftOrder, 
            instance = false,
            start = true
        })
        XFO.Events:Add({
            name = 'CanRequestOrders', 
            event = 'CRAFTINGORDERS_CAN_REQUEST', 
            callback = XFO.Orders.RequestOrders, 
            instance = false,
            start = true
        })
        self:IsInitialized(true)
    end
end
--#endregion

--#region Callbacks
function QueryMyOrders()
    try(function ()        
        local request = {
            -- If you don't provide a sort, Blizz's API throws a Lua error
            primarySort = {
                sortType = Enum.CraftingOrderSortType.ItemName,
                reversed = false,
            },
            secondarySort = {
                sortType = Enum.CraftingOrderSortType.MaxTip,
                reversed = false,
            },
            offset = 0,
            callback = CreateCallback(function(inResultStatus, ...)
                if(inResultStatus == Enum.CraftingOrderResult.Ok) then
                    GetMyOrders()
                end
            end),
        }
        -- CraftOrder API is unusual, you can't just call a function to get a listing
        -- You have to make a server request and provide a callback for when the server feels like handling your query
        QueryMyOrdersFromServer(request)
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function GetMyOrders()
    local myOrders = GetMyOrdersFromServer()
    for _, myOrder in ipairs(myOrders) do
        local order = XFO.Orders:Pop()
        try(function ()
            order:SetKey(XF.Player.Unit:GetUnitName() .. ':' .. myOrder.orderID)   
            if((myOrder.orderState == Enum.CraftingOrderState.Creating or myOrder.orderState == Enum.CraftingOrderState.Created) and not XFO.Orders:Contains(order:GetKey())) then
                order:SetType(myOrder.orderType)
                order:SetID(myOrder.orderID)
                order:SetCustomerUnit(XF.Player.Unit)
                if(myOrder.crafterGuid ~= nil) then
                    order:SetCrafterGUID(myOrder.crafterGuid)
                    order:SetCrafterName(myOrder.crafterName)
                end

                local professionName = GetProfessionForSkill(myOrder.skillLineAbilityID)
                if(professionName ~= nil and type(professionName) == 'string') then
                    local profession = XF.Professions:GetByName(professionName)
                    if(profession ~= nil) then
                        order:SetProfession(profession)
                    end
                end

                local recipe = GetRecipe(myOrder.skillLineAbilityID)
                order:SetRecipeID(recipe.recipeID)

                if(recipe.supportsQualities and myOrder.minQuality > 0) then
                    order:SetQuality(recipe.qualityIDs[myOrder.minQuality])
                end

                -- This function is executed upon query of the player's orders, therefore we know the player is always the customer for IsPersonal
                if(order:IsGuild() or order:IsPersonal()) then
                    XFO.Orders:Add(order)
                    if(not self:IsFirstQuery()) then
                        order:Display()
                        order:Broadcast()
                    end
                end                
            else
                XFO.Orders:Push(order)
            end
        end).
        catch(function (err)
            XF:Warn(ObjectName, err)
            XFO.Orders:Push(order)
        end)
    end

    -- There is no submit datetime for orders, so have to get creative in determining which one is the new one
    if(self:IsFirstQuery()) then
        self:IsFirstQuery(false)
    end
end

function XFC.OrderCollection:CraftOrder() 
    local self = XFO.Orders
    try(function ()
        QueryMyOrders()
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)
end

function XFC.OrderCollection:RequestOrders() 
    local self = XFO.Orders
    try(function ()        
        QueryMyOrders()
        XFO.Events:Remove('CanRequestOrders')
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)
end
--#endregion