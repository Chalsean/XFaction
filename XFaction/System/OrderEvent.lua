local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderEvent'
local ListMyOrders = C_CraftingOrders.ListMyOrders
local GetMyOrders = C_CraftingOrders.GetMyOrders
local GetRecipe = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility
local IsItemCached = C_Item.IsItemDataCachedByID
local RequestItemCached = C_Item.RequestLoadItemDataByID
local CreateCallback = C_FunctionContainers.CreateCallback

OrderEvent = Object:newChildConstructor()

--#region Constructors
function OrderEvent:new()
    local object = OrderEvent.parent.new(self)
    object.__name = ObjectName
    object.firstQuery = true
    return object
end
--#endregion

--#region Initializers
function OrderEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XFG.Events:Add({name = 'CraftOrder', 
                        event = 'CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE', 
                        callback = XFG.Handlers.OrderEvent.CallbackCraftOrder, 
                        instance = false,
                        start = true})

        XFG.Events:Add({name = 'CanRequestOrders', 
                        event = 'CRAFTINGORDERS_CAN_REQUEST', 
                        callback = XFG.Handlers.OrderEvent.CallbackCanRequestOrders, 
                        instance = false,
                        start = true})

        XFG.Events:Add({name = 'ItemLoaded', 
                        event = 'ITEM_DATA_LOAD_RESULT', 
                        callback = XFG.Handlers.OrderEvent.CallbackItemLoaded, 
                        instance = true,
                        start = false})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function OrderEvent:IsFirstQuery(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.firstQuery = inBoolean
    end    
    return self.firstQuery
end
--#endregion

--#region Callbacks
function QueryOrders()
    local self = XFG.Handlers.OrderEvent
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
                    GetOrders()
                end
            end),
        }
        -- CraftOrder API is unusual, you can't just call a function to get a listing
        -- You have to make a server request and provide a callback for when the server feels like handling your query
        ListMyOrders(request)
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function GetOrders()
    local self = XFG.Handlers.OrderEvent
    local myOrders = GetMyOrders()
    for _, myOrder in ipairs(myOrders) do
        local order = XFG.Orders:Pop()
        try(function ()
            order:SetKey(XFG.Player.Unit:GetUnitName() .. ':' .. myOrder.orderID)            
            if(self:IsFirstQuery() or not XFG.Orders:Contains(order:GetKey())) then
                order:SetType(myOrder.orderType)
                order:SetID(myOrder.orderID)
                order:SetCustomerUnit(XFG.Player.Unit)
                order:SetQuality(myOrder.minQuality or 1)
                order:SetSkillLineAbilityID(myOrder.skillLineAbilityID) 

                -- Different crafting quality levels have different itemIDs
                local recipe = GetRecipe(order:GetSkillLineAbilityID())
                if(recipe.supportsQualities) then
                    order:SetItemID(recipe.qualityItemIDs[order:GetQuality()])
                else
                    order:SetItemID(myOrder.itemID)
                end

                if(IsItemCached(order:GetItemID())) then
                    local item = Item:CreateFromItemID(order:GetItemID())
                    order:SetItemLink(item:GetItemLink())
                    order:SetItemIcon(item:GetItemIcon())
                else
                    XFG:Debug(ObjectName, 'Requesting item from server: %d', order:GetItemID())
                    XFG.Events:Get('ItemLoaded'):Start()
                    RequestItemCached(order:GetItemID())
                end

                if(not self:IsFirstQuery() and (order:IsGuild() or order:IsPersonal())) then
                    order:Broadcast()
                end
                XFG.Orders:Add(order)
            else
                XFG.Orders:Push(order)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
            XFG.Orders:Push(order)
        end)
    end

    -- There is no submit datetime for orders, so have to get creative in determining which one is the new one
    if(self:IsFirstQuery()) then
        self:IsFirstQuery(false)
    end
end

function OrderEvent:CallbackCraftOrder(inEvent) 
    local self = XFG.Handlers.OrderEvent
    try(function ()
        QueryOrders()
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function OrderEvent:CallbackCanRequestOrders(inEvent) 
    local self = XFG.Handlers.OrderEvent
    try(function ()        
        QueryOrders()
        XFG.Events:Remove('CanRequestOrders')
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function OrderEvent:CallbackItemLoaded(inEvent, inItemID, inLoadSuccessful) 
    local self = XFG.Handlers.OrderEvent
    try(function ()
        if(inLoadSuccessful) then
            for _, order in XFG.Orders:Iterator() do
                if(not order:HasItemLink() and order:GetItemID() == inItemID) then
                    local item = Item:CreateFromItemID(order:GetItemID())
                    order:SetItemLink(item:GetItemLink())
                    order:SetItemIcon(item:GetItemIcon())
                    if(not order:IsMyOrder()) then
                        order:Display()
                    end
                end
            end
        end

        if(not XFG.Orders:HasPending()) then
            XFG.Events:Get('ItemLoaded'):Stop()
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion