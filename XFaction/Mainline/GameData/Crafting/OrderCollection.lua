local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'OrderCollection'

--#region Constructors
function XFC.OrderCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = 'CraftOrder', 
            event = 'CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE', 
            callback = XFO.Orders.CallbackCraftOrder, 
            instance = false,
            start = true
        })
        XFO.Events:Add({
            name = 'CanRequestOrders', 
            event = 'CRAFTINGORDERS_CAN_REQUEST', 
            callback = XFO.Orders.CallbackRequestOrders, 
            instance = false,
            start = true
        })
        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
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
            callback = XFF.FunctionCreateCallback(function(inResultStatus, ...)
                if(inResultStatus == Enum.CraftingOrderResult.Ok) then
                    GetMyOrders()
                end
            end),
        }
        -- CraftOrder API is unusual, you can't just call a function to get a listing
        -- You have to make a server request and provide a callback for when the server feels like handling your query
        XFF.CraftingQueryServer(request)
    end).
    catch(function (err)
        XF:Warn(ObjectName, err)
    end)
end

function GetMyOrders()
    local self = XFO.Orders
    local myOrders = XFF.CraftingGetOrders()
    for _, myOrder in ipairs(myOrders) do
        try(function ()
            local order = XFC.Order:new()
            order:Key(XF.Player.Unit:UnitName() .. ':' .. myOrder.orderID)   
            if((myOrder.orderState == Enum.CraftingOrderState.Creating or myOrder.orderState == Enum.CraftingOrderState.Created) and not self:Contains(order:Key())) then
                order:Type(myOrder.orderType)
                order:ID(myOrder.orderID)
                order:Customer(XF.Player.Unit)
                if(myOrder.crafterGuid ~= nil) then
                    order:CrafterGUID(myOrder.crafterGuid)
                    order:CrafterName(myOrder.crafterName)
                end

                local professionName = XFF.CraftingGetSkillProfession(myOrder.skillLineAbilityID)
                if(professionName ~= nil and type(professionName) == 'string') then
                    local profession = XFO.Professions:Get(professionName)
                    if(profession ~= nil) then
                        order:Profession(profession)
                    end
                end

                local recipe = XFF.CraftingGetRecipe(myOrder.skillLineAbilityID)
                order:RecipeID(recipe.recipeID)

                if(recipe.supportsQualities and myOrder.minQuality > 0) then
                    order:Quality(recipe.qualityIDs[myOrder.minQuality])
                end

                -- This function is executed upon query of the player's orders, therefore we know the player is always the customer for IsPersonal
                if(order:IsGuild() or order:IsPersonal()) then

                    local item = XFF.CraftingGetItem(order:RecipeID(), nil, nil, nil, order:Quality())
                    order:Link(item.hyperlink)
                    self:Add(order)
                    
                    if(not self:IsFirstQuery()) then
                        XFO.SystemFrame:DisplayOrder(order)
                        XFO.Mailbox:SendOrderMessage(order:Serialize())
                    end
                end                
            end
        end).
        catch(function (err)
            XF:Warn(ObjectName, err)
        end)
    end

    -- There is no submit datetime for orders, so have to get creative in determining which one is the new one
    if(self:IsFirstQuery()) then
        self:IsFirstQuery(false)
    end
end

function XFC.OrderCollection:CallbackCraftOrder() 
    local self = XFO.Orders
    try(function ()
        QueryMyOrders()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.OrderCollection:CallbackRequestOrders() 
    local self = XFO.Orders
    try(function ()        
        QueryMyOrders()
        XFO.Events:Remove('CanRequestOrders')
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion