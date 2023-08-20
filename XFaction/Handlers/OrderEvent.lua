local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderEvent'
local ListMyOrders = C_CraftingOrders.ListMyOrders
local GetMyOrders = C_CraftingOrders.GetMyOrders
local CreateCallback = C_FunctionContainers.CreateCallback
local GetProfessionForSkill = C_TradeSkillUI.GetProfessionNameForSkillLineAbility

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

        -- Add event handler for completed/rejected/timed out orders

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
            order:SetKey(myOrder.orderID)
            if(self:IsFirstQuery() or not XFG.Orders:Contains(order:GetKey())) then
                order:SetID(myOrder.orderID)
                order:SetItemID(myOrder.itemID)
                order:SetCustomerGUID(XFG.Player.Unit:GetGUID())
                order:SetCustomerName(XFG.Player.Unit:GetUnitName())
                order:SetCustomerGuild(XFG.Player.Guild)
                order:SetMinimumQuality(myOrder.minQuality)
                order:IsFulfillable(myOrder.isFulfillable)

                local professionName = GetProfessionForSkill(myOrder.skillLineAbilityID)
                if(professionName ~= nil and type(professionName) == 'string') then
                    local profession = XFG.Professions:GetByName(professionName)
                    if(profession ~= nil) then
                        order:SetProfession(profession)
                    end
                end

                order:Print()

                -- There is no submit datetime for orders, so have to get creative in determining which one is the new one
                if(self:IsFirstQuery()) then
                    XFG.Orders:Add(order)
                else
                    order:IsLatestOrder(true)
                    XFG.Orders:Add(order)
                    order:Broadcast()
                    XFG.DataText.Orders:RefreshBroker()
                end
            else
                XFG.Orders:Push(order)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
            XFG.Orders:Push(order)
        end)
    end

    if(self:IsFirstQuery()) then
        if(XFG.Orders:GetCount() > 0) then
            XFG.Orders:Broadcast()
            XFG.DataText.Orders:RefreshBroker()
        end
        self:IsFirstQuery(false)
    end
end

function OrderEvent:CallbackCraftOrder(inEvent) 
    local self = XFG.Handlers.OrderEvent
    try(function ()
        for _, order in XFG.Orders:Iterator() do
            if(order:IsMyOrder()) then
                order:IsLatestOrder(false)
            end
        end
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
--#endregion