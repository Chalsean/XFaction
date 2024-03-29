local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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
        for _, message in ipairs(XF.Config.Logout) do
            XF:Debug(ObjectName, '* Previous Logout: %s', message)
        end
        XF.Config.Logout = {}
        XF.Hooks:Add({name = 'ReloadUI', 
                       original = 'ReloadUI', 
                       callback = XF.Handlers.SystemEvent.CallbackReloadUI,
                       pre = true})
        XF.Events:Add({name = 'Logout',
                        event = 'PLAYER_LOGOUT',
                        callback = XF.Handlers.SystemEvent.CallbackLogout,
                        instance = true})
        -- Not sure this is necessary but don't feel like taking the risk of removing it
        XF.Events:Add({name = 'LoadScreen', 
                        event = 'PLAYER_ENTERING_WORLD', 
                        callback = XF.Handlers.SystemEvent.CallbackLogin, 
                        instance = true})
		self:IsInitialized(true)
        XF.Config.Logout[#XF.Config.Logout + 1] = XF.Player.Unit:GetUnitName()
	end
end
--#endregion

--#region Callbacks
function SystemEvent:CallbackLogout()
    if(not XF.Cache.UIReload) then
        local message = nil
        try(function ()
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout started'
            message = XF.Mailbox.Chat:Pop()
            message:Initialize()
            message:SetType(XF.Enum.Network.BROADCAST)
            message:SetSubject(XF.Enum.Message.LOGOUT)
            if(XF.Player.Unit:IsAlt() and XF.Player.Unit:HasMainName()) then
                message:SetMainName(XF.Player.Unit:GetMainName())
            end
            message:SetGuild(XF.Player.Guild)
            message:SetUnitName(XF.Player.Unit:GetName())
            message:SetData(' ')
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout sending message'
            XF.Mailbox.Chat:Send(message)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout message sent'
        end).
        catch(function (inErrorMessage)
            XF:Error(ObjectName, inErrorMessage)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Failed to send logout message: ' .. inErrorMessage
        end)
    end
end

function SystemEvent:CallbackReloadUI()
    try(function ()        
        XF.Confederate:Backup()
        XF.Friends:Backup()
        XF.Links:Backup()
        XFO.Orders:Backup()
    end).
    catch(function (inErrorMessage)
        XF:Error(ObjectName, inErrorMessage)
        XF.Config.Errors[#XF.Config.Errors + 1] = 'Failed to perform backups: ' .. inErrorMessage
    end).
    finally(function ()
        XF.Cache.UIReload = true
        _G.XFCacheDB = XF.Cache
    end)
end

function SystemEvent:CallbackLogin()
    if(XF.Channels:HasLocalChannel()) then
        XF.Channels:SetLast(XF.Channels:GetLocalChannel():GetKey())
    end
end
--#endregion