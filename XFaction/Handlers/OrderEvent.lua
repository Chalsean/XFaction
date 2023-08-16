local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderEvent'
local GetMemberInfo = C_Club.GetMemberInfo

OrderEvent = Object:newChildConstructor()

--#region Constructors
function OrderEvent:new()
    local object = OrderEvent.parent.new(self)
    object.__name = ObjectName
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

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function Bob(inOrders)
    local orders = C_CraftingOrders.GetMyOrders()
    XFG:Info(ObjectName, "GetMyOrders")
    XFG:DataDumper(ObjectName, orders)
end

function OrderEvent:CallbackCraftOrder(inEvent) 
    try(function ()
        
        local request = {
            primarySort = {
                sortType = Enum.CraftingOrderSortType.ItemName,
                reversed = false,
            },
            secondarySort = {
                sortType = Enum.CraftingOrderSortType.MaxTip,
                reversed = false,
            },
            offset = 0,
            profession = Enum.Profession.Tailoring,
            callback = C_FunctionContainers.CreateCallback(function(inResultStatus, ...)
                if(inResultStatus == Enum.CraftingOrderResult.Ok) then
                    Bob()
                end
                -- local orders = C_CraftingOrders.GetMyOrders()
                -- XFG:Info(ObjectName, "GetMyOrders")
                -- XFG:DataDumper(ObjectName, orders)
            end),
        }
        C_CraftingOrders.ListMyOrders(request)
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion