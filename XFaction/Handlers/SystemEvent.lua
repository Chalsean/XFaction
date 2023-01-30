local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemEvent'

SystemEvent = Object:newChildConstructor()

--#region Constructors
function SystemEvent:new()
    local object = SystemEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()     
        -- Log any messages encountered during last logout
        for _, message in ipairs(XFG.Config.Logout) do
            XFG:Debug(ObjectName, '* Previous Logout: %s', message)
        end
        XFG.Config.Logout = {}
        XFG.Hooks:Add({name = 'ReloadUI', 
                       original = 'ReloadUI', 
                       callback = XFG.Handlers.SystemEvent.CallbackReloadUI,
                       pre = true})
        XFG.Events:Add({name = 'Logout',
                        event = 'PLAYER_LOGOUT',
                        callback = XFG.Handlers.SystemEvent.CallbackLogout,
                        instance = true,
                        start = false})
        -- Not sure this is necessary but don't feel like taking the risk of removing it
        XFG.Events:Add({name = 'LoadScreen', 
                        event = 'PLAYER_ENTERING_WORLD', 
                        callback = XFG.Handlers.SystemEvent.CallbackLogin, 
                        instance = true,
                        start = false})
		self:IsInitialized(true)
        XFG.Config.Logout[#XFG.Config.Logout + 1] = XFG.Player.Unit:GetUnitName()
	end
end
--#endregion

--#region Callbacks
function SystemEvent:CallbackLogout()
    if(not XFG.Cache.UIReload) then
        local message = nil
        try(function ()
            XFG.Config.Logout[#XFG.Config.Logout + 1] = 'Logout started'
            message = XFG.Mailbox.Chat:Pop()
            message:Initialize()
            message:SetType(XFG.Settings.Network.Type.BROADCAST)
            message:SetSubject(XFG.Settings.Network.Message.Subject.LOGOUT)
            if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                message:SetMainName(XFG.Player.Unit:GetMainName())
            end
            message:SetGuild(XFG.Player.Guild)
            message:SetRealm(XFG.Player.Realm)
            message:SetUnitName(XFG.Player.Unit:GetName())
            message:SetData(' ')
            XFG.Config.Logout[#XFG.Config.Logout + 1] = 'Logout sending message'
            XFG.Mailbox.Chat:Send(message)
            XFG.Config.Logout[#XFG.Config.Logout + 1] = 'Logout message sent'
        end).
        catch(function (inErrorMessage)
            XFG:Error(ObjectName, inErrorMessage)
            XFG.Config.Logout[#XFG.Config.Logout + 1] = 'Failed to send logout message: ' .. inErrorMessage
        end)
    end
end

function SystemEvent:CallbackReloadUI()
    try(function ()        
        XFG.Confederate:Backup()
        XFG.Friends:Backup()
        XFG.Links:Backup()
    end).
    catch(function (inErrorMessage)
        XFG:Error(ObjectName, inErrorMessage)
        XFG.Config.Errors[#XFG.Config.Errors + 1] = 'Failed to perform backups: ' .. inErrorMessage
    end).
    finally(function ()
        XFG.Cache.UIReload = true
        _G.XFCacheDB = XFG.Cache
    end)
end

function SystemEvent:CallbackLogin()
    if(XFG.Channels:HasLocalChannel()) then
        XFG.Channels:SetLast(XFG.Channels:GetLocalChannel():GetKey())
    end
end
--#endregion