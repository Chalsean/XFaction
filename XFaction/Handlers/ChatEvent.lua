local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatEvent'

ChatEvent = Object:newChildConstructor()

function ChatEvent:new()
    local _Object = ChatEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function ChatEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:RegisterEvent('CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.CallbackGuildMessage)
        XFG:Info(ObjectName, 'Registered for CHAT_MSG_GUILD events')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_GUILD event filter')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XFG.Player.GUID == inSenderGUID and XFG.Player.Unit:CanGuildSpeak()) then
            local _NewMessage = nil
            try(function ()
                _NewMessage = XFG.Factories.GuildMessage:CheckOut()
                _NewMessage:SetFrom(XFG.Player.Unit:GetKey())
                _NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
                _NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.GCHAT)
                _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
                _NewMessage:SetGuild(XFG.Player.Guild)
                _NewMessage:SetRealm(XFG.Player.Realm)
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
                end
                _NewMessage:SetData(inText)
                XFG.Outbox:Send(_NewMessage, true)
            end).
            finally(function ()
                XFG.Factories.GuildMessage:CheckIn(_NewMessage)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

local function ModifyPlayerChat(inEvent, inMessage, inUnitData)
    local _ConfigNode = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local _Event = inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT'
    local _Text = ''
    if(XFG.Config.Chat[_ConfigNode].Faction) then  
        _Text = _Text .. format('%s ', format(XFG.Icons.String, inUnitData:GetFaction():GetIconID()))
    end
    if(XFG.Config.Chat[_ConfigNode].Main and inUnitData:IsAlt() and inUnitData:HasMainName()) then
        _Text = _Text .. '(' .. inUnitData:GetMainName() .. ') '
    end
    if(XFG.Config.Chat[_ConfigNode].Guild) then
        _Text = _Text .. '<' .. inUnitData:GetGuild():GetInitials() .. '> '
    end
    _Text = _Text .. inMessage

    local _Hex = nil
    if(XFG.Config.Chat[_ConfigNode].CColor) then
        if(XFG.Config.Chat[_ConfigNode].FColor) then
            _Hex = inUnitData:GetFaction():GetName() == 'Horde' and XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].HColor.Red, XFG.Config.Chat[_ConfigNode].HColor.Green, XFG.Config.Chat[_ConfigNode].HColor.Blue) or XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].AColor.Red, XFG.Config.Chat[_ConfigNode].AColor.Green, XFG.Config.Chat[_ConfigNode].AColor.Blue)
        else
            _Hex = XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].Color.Red, XFG.Config.Chat[_ConfigNode].Color.Green, XFG.Config.Chat[_ConfigNode].Color.Blue)
        end
    elseif(XFG.Config.Chat[_ConfigNode].FColor) then
        _Hex = inUnitData:GetFaction():GetName() == 'Horde' and 'E0000D' or '378DEF'
    elseif(_G.ChatTypeInfo[_Event]) then
        local _Color = _G.ChatTypeInfo[_Event]
        _Hex = XFG:RGBPercToHex(_Color.r, _Color.g, _Color.b)
    end
    
    if _Hex ~= nil then
        _Text = format('|cff%s%s|r', _Hex, _Text)
    end

    return _Text
end

function ChatEvent:ChatFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(string.find(inMessage, XFG.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
    -- Whisper sometimes throws an erronous error, so hide it to avoid confusion for the player
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_NO_PLAYER_FOUND']) or string.find(inMessage, XFG.Lib.Locale['CHAT_ACHIEVEMENT'])) then
        return true
    elseif(XFG.Confederate:Contains(inGUID)) then
        inMessage = ModifyPlayerChat(inEvent, inMessage, XFG.Confederate:GetObject(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end