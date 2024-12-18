local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemEvent'

XFC.SystemEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemEvent:new()
    local object = XFC.SystemEvent.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()     
        -- Log any messages encountered during last logout
        for _, message in ipairs(XF.Config.Logout) do
            XF:Debug(self:ObjectName(), '* Previous Logout: %s', message)
        end
        XF.Config.Logout = {}

        XFO.Hooks:Add({
            name = 'ReloadUI', 
            original = 'ReloadUI', 
            callback = XFO.SystemEvent.CallbackReloadUI,
            pre = true
        })
        XFO.Events:Add({
            name = 'Logout',
            event = 'PLAYER_LOGOUT',
            callback = XFO.SystemEvent.CallbackLogout,
            instance = true
        })
        -- Not sure this is necessary but don't feel like taking the risk of removing it
        XFO.Events:Add({
            name = 'LoadScreen', 
            event = 'PLAYER_ENTERING_WORLD', 
            callback = XFO.SystemEvent.CallbackLogin, 
            instance = true
        })

		self:IsInitialized(true)
        XF.Config.Logout[#XF.Config.Logout + 1] = XF.Player.Unit:UnitName()
	end
end
--#endregion

--#region Methods
function XFC.SystemEvent:CallbackLogout()
    local self = XFO.SystemEvent
    if(not XF.Cache.UIReload) then
        try(function ()
            XF:Stop()
            XF.Lib.BCTL:Purge() -- Purge any pending messages
            XFO.Mailbox:SendLogoutMessage()
            --XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout message sent'
        end).
        catch(function (err)
            --  XF:Error(self:ObjectName(), err)
            --XF.Config.Logout[#XF.Config.Logout + 1] = 'Failed to send logout message: ' .. err
        end)
    end
end

function XFC.SystemEvent:CallbackReloadUI()
    local self = XFO.SystemEvent
    try(function ()
        XFO.Confederate:Backup()
    end).
    catch(function (err)
        XF:Error(self:ObjectName(), err)
        XF.Config.Logout[#XF.Config.Logout + 1] = 'Failed to perform backups: ' .. err
    end).
    finally(function ()
        XF.Cache.UIReload = true
        _G.XFCacheDB = XF.Cache
    end)
end

function XFC.SystemEvent:CallbackLogin()
    local self = XFO.SystemEvent
    try(function()
        if(XFO.Channels:HasLocalChannel()) then
            XFO.Channels:SetLast(XFO.Channels:LocalChannel():Key())
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion