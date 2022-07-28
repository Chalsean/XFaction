local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemEvent'
local LogCategory = 'HESystem'
local TotalChannels = 10

SystemEvent = {}

function SystemEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end

function SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        XFG:CreateEvent('Logout', 'PLAYER_LOGOUT', XFG.Handlers.SystemEvent.CallbackLogout, true, true)
        XFG:Hook('ReloadUI', self.CallbackReloadUI, true)
        XFG:Info(LogCategory, 'Created hook for pre-ReloadUI')
        XFG:CreateEvent('LoadScreen', 'PLAYER_ENTERING_WORLD', XFG.Handlers.SystemEvent.CallbackLogin, true, true)
        XFG:Info(LogCategory, 'Created hook for loading screen')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', XFG.Handlers.SystemEvent.ChatFilter)
        XFG:Info(LogCategory, 'Created CHAT_MSG_SYSTEM event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SystemEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SystemEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SystemEvent:CallbackLogout()
    if(XFG.DB.UIReload) then 
        -- Backup information on reload to be restored
        XFG.Confederate:CreateBackup()
        XFG.Friends:CreateBackup()
        XFG.Links:CreateBackup()
    else
        local _Message = XFG.Factories.GuildMessage:CheckOut()
        try(function ()
            _Message:SetType(XFG.Settings.Network.Type.BROADCAST)
            _Message:SetSubject(XFG.Settings.Network.Message.Subject.LOGOUT)
            if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                _Message:SetMainName(XFG.Player.Unit:GetMainName())
            end
            _Message:SetGuild(XFG.Player.Guild)
            _Message:SetRealm(XFG.Player.Realm)
            _Message:SetUnitName(XFG.Player.Unit:GetName())
            _Message:SetData(' ')
            XFG.Outbox:Send(_Message)
        end).
        finally(function ()
            XFG.Factories.GuildMessage:CheckIn(_Message)
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
        XFG.Channels:SetChannelLast(XFG.Outlook:GetLocalChannel():GetKey())
    end
end

function SystemEvent:ChatFilter(inEvent, inMessage, ...)
    if(string.find(inMessage, XFG.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(not XFG.Config.Chat.Login.Enable and string.find(inMessage, XFG.Lib.Locale['CHAT_LOGIN'])) then
        return true
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_LOGOUT'])) then
        return true    
    end
    return false, inMessage, ...
end