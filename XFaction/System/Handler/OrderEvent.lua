local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'OrderEvent'
local QueryMyOrdersFromServer = C_CraftingOrders.ListMyOrders
local GetMyOrdersFromServer = C_CraftingOrders.GetMyOrders
local GetRecipe = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility
local GetProfessionForSkill = C_TradeSkillUI.GetProfessionNameForSkillLineAbility
local CreateCallback = C_FunctionContainers.CreateCallback

XFC.OrderEvent = Object:newChildConstructor()

--#region Constructors
function XFC.OrderEvent:new()
    local object = XFC.OrderEvent.parent.new(self)
    object.__name = ObjectName
    object.firstQuery = true
    return object
end
--#endregion

--#region Initializers
function XFC.OrderEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XF.Events:Add({name = 'CraftOrder', 
                        event = 'CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE', 
                        callback = XF.Handlers.OrderEvent.CallbackCraftOrder, 
                        instance = false,
                        start = true})

        XF.Events:Add({name = 'CanRequestOrders', 
                        event = 'CRAFTINGORDERS_CAN_REQUEST', 
                        callback = XF.Handlers.OrderEvent.CallbackCanRequestOrders, 
                        instance = false,
                        start = true})
	end
end
--#endregion

--#region Accessors
function XFC.OrderEvent:IsFirstQuery(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.firstQuery = inBoolean
    end    
    return self.firstQuery
end
--#endregion

--#region Callbacks
function QueryMyOrders()
    local self = XF.Handlers.OrderEvent
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
    local self = XF.Handlers.OrderEvent
    local myOrders = GetMyOrdersFromServer()
    for _, myOrder in ipairs(myOrders) do
        local order = XFO.Orders:Pop()
        try(function ()
            order:SetKey(XF.Player.Unit:GetUnitName() .. ':' .. myOrder.orderID)   
            if((myOrder.orderState == Enum.CraftingOrderState.Creating or myOrder.orderState == Enum.CraftingOrderState.Created) and 
               (self:IsFirstQuery() or not XFO.Orders:Contains(order:GetKey()))) then
                order:SetType(myOrder.orderType)
                order:SetID(myOrder.orderID)
                order:SetCustomerUnit(XF.Player.Unit)

                -- Different crafting quality levels have different itemIDs
                local itemID = myOrder.itemID
                local recipe = GetRecipe(myOrder.skillLineAbilityID)                
                if(recipe.supportsQualities) then
                    local quality = myOrder.minQuality > 0 and myOrder.minQuality or 1
                    itemID = recipe.qualityItemIDs[quality]
                end

                XFO.Items:Cache(itemID)
                order:SetItem(XFO.Items:Get(itemID))

                local professionName = GetProfessionForSkill(myOrder.skillLineAbilityID)
                if(professionName ~= nil and type(professionName) == 'string') then
                    local profession = XF.Professions:GetByName(professionName)
                    if(profession ~= nil) then
                        order:SetProfession(profession)
                    end
                end

                if(self:IsFirstQuery()) then
                    order:HasCommunicated(true)
                    order:HasDisplayed(true)
                elseif(order:IsGuild()) then
                    order:Display()
                    order:Broadcast()
                elseif(order:IsPersonal()) then
                    order:HasDisplayed(true)
                    order:Broadcast()                    
                end
                XFO.Orders:Add(order)
            else
                XFO.Orders:Push(order)
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
            XFO.Orders:Push(order)
        end)
    end

    -- There is no submit datetime for orders, so have to get creative in determining which one is the new one
    if(self:IsFirstQuery()) then
        self:IsFirstQuery(false)
    end
end

function XFC.OrderEvent:CallbackCraftOrder(inEvent) 
    local self = XF.Handlers.OrderEvent
    try(function ()
        QueryMyOrders()
    end).
    catch(function (inErrorMessage)
        XF:Warn(self:GetObjectName(), inErrorMessage)
    end)
end

function XFC.OrderEvent:CallbackCanRequestOrders(inEvent) 
    local self = XF.Handlers.OrderEvent
    try(function ()        
        QueryMyOrders()
        XF.Events:Remove('CanRequestOrders')
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion