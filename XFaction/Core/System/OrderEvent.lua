local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'OrderEvent'
local ListMyOrders = C_CraftingOrders.ListMyOrders
local GetMyOrders = C_CraftingOrders.GetMyOrders
local GetRecipe = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility
local IsItemCached = C_Item.IsItemDataCachedByID
local RequestItemCached = C_Item.RequestLoadItemDataByID
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

        XF.Events:Add({name = 'ItemLoaded', 
                        event = 'ITEM_DATA_LOAD_RESULT', 
                        callback = XF.Handlers.OrderEvent.CallbackItemLoaded, 
                        instance = true,
                        start = false})

		self:IsInitialized(true)
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
function QueryOrders()
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
                    GetOrders()
                end
            end),
        }
        -- CraftOrder API is unusual, you can't just call a function to get a listing
        -- You have to make a server request and provide a callback for when the server feels like handling your query
        ListMyOrders(request)
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function GetOrders()
    local self = XF.Handlers.OrderEvent
    local myOrders = GetMyOrders()
    for _, myOrder in ipairs(myOrders) do
        local order = XFO.Orders:Pop()
        try(function ()
            order:SetKey(XF.Player.Unit:GetUnitName() .. ':' .. myOrder.orderID)            
            if(self:IsFirstQuery() or not XFO.Orders:Contains(order:GetKey())) then
                order:SetType(myOrder.orderType)
                order:SetID(myOrder.orderID)
                order:SetCustomerUnit(XF.Player.Unit)
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
                    XF:Debug(ObjectName, 'Requesting item from server: %d', order:GetItemID())
                    XF.Events:Get('ItemLoaded'):Start()
                    RequestItemCached(order:GetItemID())
                end

                if(not self:IsFirstQuery() and (order:IsGuild() or order:IsPersonal())) then
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
        QueryOrders()
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function XFC.OrderEvent:CallbackCanRequestOrders(inEvent) 
    local self = XF.Handlers.OrderEvent
    try(function ()        
        QueryOrders()
        XF.Events:Remove('CanRequestOrders')
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function XFC.OrderEvent:CallbackItemLoaded(inEvent, inItemID, inLoadSuccessful) 
    local self = XF.Handlers.OrderEvent
    try(function ()
        if(inLoadSuccessful) then
            for _, order in XFO.Orders:Iterator() do
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

        if(not XFO.Orders:HasPending()) then
            XF.Events:Get('ItemLoaded'):Stop()
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion