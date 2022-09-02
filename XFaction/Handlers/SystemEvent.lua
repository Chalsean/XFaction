local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemEvent'

SystemEvent = Object:newChildConstructor()

function SystemEvent:new()
    local _Object = SystemEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Hooks:Add('ReloadUI', 'ReloadUI', XFG.Handlers.SystemEvent.CallbackReloadUI)
        XFG.Events:Add('Logout', 'PLAYER_LOGOUT', XFG.Handlers.SystemEvent.CallbackLogout, true, true)        
        XFG.Events:Add('LoadScreen', 'PLAYER_ENTERING_WORLD', XFG.Handlers.SystemEvent.CallbackLogin, true, true)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', XFG.Handlers.SystemEvent.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_SYSTEM event filter')
		self:IsInitialized(true)
	end
end

function SystemEvent:CallbackLogout()    
    if(XFG.DB.UIReload) then 
        -- Backup information on reload to be restored
        XFG.Confederate:Backup()
        XFG.Friends:Backup()
        XFG.Links:Backup()
    else
        local _NewMessage = nil
        try(function ()        
            _NewMessage = XFG.Mailbox.Chat:Pop()
            _NewMessage:Initialize()
            _NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
            _NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.LOGOUT)
            if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
            end
            _NewMessage:SetGuild(XFG.Player.Guild)
            _NewMessage:SetRealm(XFG.Player.Realm)
            _NewMessage:SetUnitName(XFG.Player.Unit:GetName())
            _NewMessage:SetData(' ')
            XFG.Mailbox.Chat:Send(_NewMessage)
        end).
        catch(function (inErrorMessage)
            XFG.DB.Errors[#XFG.DB.Errors + 1] = 'Failed to send logoff message: ' .. inErrorMessage
        end).
        finally(function ()
            XFG.Mailbox.Chat:Push(_NewMessage)
        end)
    end    
end

function SystemEvent:CallbackReloadUI()
    if(XFG.DB ~= nil) then
        XFG.DB.UIReload = true
    end
end

function SystemEvent:CallbackLogin()
    if(XFG.Outlook:HasLocalChannel()) then
        XFG.Channels:SetLast(XFG.Outlook:GetLocalChannel():GetKey())
    end
end

function SystemEvent:ChatFilter(inEvent, inMessage, ...)
    if(string.find(inMessage, XFG.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_LOGIN'])) then
        return true
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_LOGOUT'])) then
        return true
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_JOIN_GUILD'])) then
        return true 
    end
    return false, inMessage, ...
end