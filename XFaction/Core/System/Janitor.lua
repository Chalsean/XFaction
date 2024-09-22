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
            delta = XF.Settings.Factories.Scan, 
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
        if(not XFF.PlayerIsInCombat()) then
            local window = XFF.TimeCurrent() - XF.Settings.Factories.Purge
            try(function()
                XFO.Confederate:Purge(window)
            end).catch(function() end)

            try(function()
                XFO.Friends:Purge(window)
            end).catch(function() end)

            try(function()
                XFO.Orders:Purge(window)
            end).catch(function() end)

            try(function()
                XFO.Mailbox:Purge(window)
            end).catch(function() end)

            local window = XFF.TimeCurrent() - XF.Settings.Confederate.UnitStale
            for _, unit in XFO.Confederate:Iterator() do
                try(function()
                    if(not unit:IsPlayer() and unit:IsOnline() and unit:TimeStamp() < window) then
                        XFO.Confederate:OfflineUnit(unit)
                    end
                end).catch(function() end)
            end

            for _, channel in XFO.Channels:Iterator() do
                for _, unit in channel:Iterator() do
                    try(function ()
                        if(not unit:IsPlayer() and unit:TimeStamp() < window) then
                            channel:Remove(unit:Key())
                        end
                    end).catch(function() end)
                end
            end

            for _, target in XFO.Targets:Iterator() do
                for _, unit in target:Iterator() do
                    try(function()
                        if(not unit:IsPlayer() and unit:TimeStamp() < window) then
                            target:Remove(unit:Key())
                        end
                    end).catch(function() end)
                end
            end

            local epoch = XFF.TimeCurrent() - XF.Settings.Network.Mailbox.Stale
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