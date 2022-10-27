local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatEvent'

ChatEvent = Object:newChildConstructor()

--#region Constructors
function ChatEvent:new()
    local object = ChatEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function ChatEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('GuildChat', 'CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.CallbackGuildMessage, true, true)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_GUILD event filter')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XFG.Player.GUID == inSenderGUID and XFG.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = XFG.Mailbox.Chat:Pop()
                message:Initialize()
                message:SetFrom(XFG.Player.Unit:GetGUID())
                message:SetType(XFG.Settings.Network.Type.BROADCAST)
                message:SetSubject(XFG.Settings.Network.Message.Subject.GCHAT)
                message:SetUnitName(XFG.Player.Unit:GetUnitName())
                message:SetGuild(XFG.Player.Guild)
                message:SetRealm(XFG.Player.Realm)
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    message:SetMainName(XFG.Player.Unit:GetMainName())
                end
                message:SetData(inText)
                XFG.Mailbox.Chat:Send(message, true)
            end).
            finally(function ()
                XFG.Mailbox.Chat:Push(message)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

local function ModifyPlayerChat(inEvent, inMessage, inUnitData)
    local configNode = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local event = inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT'
    local text = ''
    if(XFG.Config.Chat[configNode].Faction) then  
        text = text .. format('%s ', format(XFG.Icons.String, inUnitData:GetFaction():GetIconID()))
    end
    if(XFG.Config.Chat[configNode].Main and inUnitData:IsAlt() and inUnitData:HasMainName()) then
        text = text .. '(' .. inUnitData:GetMainName() .. ') '
    end
    if(XFG.Config.Chat[configNode].Guild) then
        text = text .. '<' .. inUnitData:GetGuild():GetInitials() .. '> '
    end
    text = text .. inMessage

    local hex = nil
    if(XFG.Config.Chat[configNode].CColor) then
        if(XFG.Config.Chat[configNode].FColor) then
            hex = inUnitData:GetFaction():GetName() == 'Horde' and XFG:RGBPercToHex(XFG.Config.Chat[configNode].HColor.Red, XFG.Config.Chat[configNode].HColor.Green, XFG.Config.Chat[configNode].HColor.Blue) or XFG:RGBPercToHex(XFG.Config.Chat[configNode].AColor.Red, XFG.Config.Chat[configNode].AColor.Green, XFG.Config.Chat[configNode].AColor.Blue)
        else
            hex = XFG:RGBPercToHex(XFG.Config.Chat[configNode].Color.Red, XFG.Config.Chat[configNode].Color.Green, XFG.Config.Chat[configNode].Color.Blue)
        end
    elseif(XFG.Config.Chat[configNode].FColor) then
        hex = inUnitData:GetFaction():GetName() == 'Horde' and 'E0000D' or '378DEF'
    elseif(_G.ChatTypeInfo[event]) then
        local color = _G.ChatTypeInfo[event]
        hex = XFG:RGBPercToHex(color.r, color.g, color.b)
    end
    
    if hex ~= nil then
        text = format('|cff%s%s|r', hex, text)
    end

    return text
end

function ChatEvent:ChatFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(string.find(inMessage, XFG.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
    -- Whisper sometimes throws an erronous error, so hide it to avoid confusion for the player
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_NO_PLAYER_FOUND']) or string.find(inMessage, XFG.Lib.Locale['CHAT_ACHIEVEMENT'])) then
        return true
    elseif(XFG.Confederate:Contains(inGUID)) then
        inMessage = ModifyPlayerChat(inEvent, inMessage, XFG.Confederate:Get(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end
--#endregion