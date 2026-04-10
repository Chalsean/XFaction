local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Janitor'

XFC.Janitor = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Janitor:new()
    local object = XFC.Janitor.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.Janitor:Initialize()
    if(not self:IsInitialized()) then
        XFO.Timers:Add({
            name = 'Janitor', 
            delta = 60, 
            callback = XFO.Janitor.CallbackJanitor, 
            repeater = true, 
            instance = true
        })
        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
function XFC.Janitor:CallbackJanitor()
    local self = XFO.Janitor
    try(function()
        if(not InCombatLockdown()) then
            local window = time() - 300
            for _, unit in XFO.Confederate:Iterator() do
                try(function()
                    if(not unit:IsPlayer() and unit:IsOnline() and unit:TimeStamp() < window) then
                        XFO.Confederate:Remove(unit)
                    end
                end).catch(function() end)
            end

            local epoch = time() - 3600
            for key, receivedTime in XFO.Mailbox:Iterator() do
                try(function()
                    if(receivedTime < epoch) then
                        XFO.Mailbox:Remove(key)
                    end
                end).catch(function() end)
            end
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion