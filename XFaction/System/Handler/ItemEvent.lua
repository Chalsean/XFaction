local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ItemEvent'

XFC.ItemEvent = Object:newChildConstructor()

--#region Constructors
function XFC.ItemEvent:new()
    local object = XFC.ItemEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ItemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XF.Events:Add({name = 'ItemLoaded', 
                        event = 'ITEM_DATA_LOAD_RESULT', 
                        callback = XF.Handlers.ItemEvent.CallbackItemLoaded, 
                        instance = true,
                        start = false})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function XFC.ItemEvent:CallbackItemLoaded(inEvent, inItemID, inLoadSuccessful) 
    local self = XF.Handlers.ItemEvent
    try(function ()
        -- Cache items from server
        if(inLoadSuccessful) then
            XFO.Items:Cache(inItemID)
        end

        -- Check for pending order displays
        XFO.Orders:Display()

        -- If not waiting on other items, disable listener
        if(not XFO.Items:HasPending()) then
            XF.Events:Get('ItemLoaded'):Stop()
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion