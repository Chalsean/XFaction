local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChatFrame'

XFC.ChatFrame = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.ChatFrame:new()
    local object = XFC.ChatFrame.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ChatFrame:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFF.ChatFrameFilter('CHAT_MSG_GUILD', XFO.ChatFrame.ChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD event filter')
        XFF.ChatFrameFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFO.ChatFrame.AchievementFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Callbacks
local function ModifyPlayerChat(inEvent, inMessage, inUnitData)
    local configNode = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local event = inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT'
    local text = ''
    if(XF.Config.Chat[configNode].Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnitData:Race():Faction():IconID()))
    end
    if(XF.Config.Chat[configNode].Main and inUnitData:IsAlt() and inUnitData:HasMainName()) then
        text = text .. '(' .. inUnitData:MainName() .. ') '
    end
    if(XF.Config.Chat[configNode].Guild) then
        text = text .. '<' .. inUnitData:Guild():Initials() .. '> '
    end
    text = text .. inMessage

    local hex = nil
    if(XF.Config.Chat[configNode].CColor) then
        if(XF.Config.Chat[configNode].FColor) then
            hex = inUnitData:Race():Faction():IsHorde() and XF:RGBPercToHex(XF.Config.Chat[configNode].HColor.Red, XF.Config.Chat[configNode].HColor.Green, XF.Config.Chat[configNode].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[configNode].AColor.Red, XF.Config.Chat[configNode].AColor.Green, XF.Config.Chat[configNode].AColor.Blue)
        else
            hex = XF:RGBPercToHex(XF.Config.Chat[configNode].Color.Red, XF.Config.Chat[configNode].Color.Green, XF.Config.Chat[configNode].Color.Blue)
        end
    elseif(XF.Config.Chat[configNode].FColor) then
        hex = inUnitData:Race():Faction():IsHorder() and 'E0000D' or '378DEF'
    elseif(_G.ChatTypeInfo[event]) then
        local color = _G.ChatTypeInfo[event]
        hex = XF:RGBPercToHex(color.r, color.g, color.b)
    end
    
    if hex ~= nil then
        text = format('|cff%s%s|r', hex, text)
    end

    return text
end

function XFC.ChatFrame:ChatFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(not XF.Config.Chat.GChat.Enable) then
        return true
    elseif(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
    -- Whisper sometimes throws an erronous error, so hide it to avoid confusion for the player
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    elseif(XFO.Confederate:Contains(inGUID)) then
        inMessage = ModifyPlayerChat(inEvent, inMessage, XFO.Confederate:Get(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

function XFC.ChatFrame:AchievementFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(not XF.Config.Chat.Achievement.Enable) then
        return true
    elseif(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
    elseif(XFO.Confederate:Contains(inGUID)) then
        inMessage = ModifyPlayerChat(inEvent, inMessage, XFO.Confederate:Get(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end
--#endregion

--#region Display
local function GetFrame()
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    local frameTable
    for i = 1, NUM_CHAT_WINDOWS do
        frameTable = { XFF.ChatGetWindow(i) }
        local v
        for _, frameName in ipairs(frameTable) do
            if frameName == inType then
                local frame = 'ChatFrame' .. i
                if _G[frame] then
                    return _G[frame]
                end
            end
        end
    end
end

local function GetChatColor(inType, inFaction)
    assert(type(inType) == 'string')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    local hex = nil
    if(XF.Config.Chat[inType].CColor) then
        if(XF.Config.Chat[inType].FColor) then
            hex = inFaction:IsHorde() and XF:RGBPercToHex(XF.Config.Chat[inType].HColor.Red, XF.Config.Chat[inType].HColor.Green, XF.Config.Chat[inType].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[inType].AColor.Red, XF.Config.Chat[inType].AColor.Green, XF.Config.Chat[inType].AColor.Blue)
        else
            hex = XF:RGBPercToHex(XF.Config.Chat[inType].Color.Red, XF.Config.Chat[inType].Color.Green, XF.Config.Chat[inType].Color.Blue)
        end
    elseif(XF.Config.Chat[inType].FColor) then
        hex = inFaction:IsHorde() and 'E0000D' or '378DEF'
    else
        local color = _G.ChatTypeInfo[inType == 'GChat' and 'GUILD' or 'GUILD_ACHIEVEMENT']
        hex = XF:RGBPercToHex(color.r, color.g, color.b)
    end
end

local function DisplayGuildChat(inMessage)

    local message = XF.Settings.Frames.Chat.Prepend
    local frame = GetFrame()
    if(frame ~= nil) then
        local text = ''

        if(XF.Config.Chat.GChat.Faction) then
            text = text .. format('%s ', format(XF.Icons.String, inMessage:Faction():IconID()))
        end

        if(XF.Config.Chat.GChat.Main and inMessage:MainName() ~= nil) then
            text = text .. '(' .. inMessage:MainName() .. ') '
        end

        if(XF.Config.Chat.GChat.Guild) then
            text = text .. '<' .. inMessage:Guild():Initials() .. '> '
        end

        text = text .. inMessage:Data()

        local hex = GetChatColor('GChat', inMessage():Faction())
        if hex ~= nil then
            text = format('|cff%s%s|r', hex, text)
        end

        if(XFO.Addons.WIM:IsLoaded() and XFO.Addons.WIM:API().modules.GuildChat.enabled) then
            XFO.Addons.WIM:API():CHAT_MSG_GUILD(text, inMessage:From(), XF.Player.Faction:Language(), '', inMessage:From(), '', 0, 0, '', 0, _, inMessage:From())
        else
            text = XF.Settings.Frames.Chat.Prepend .. text
            XFF.ChatHandler(frame, 'CHAT_MSG_GUILD', text, inMessage:From(), XF.Player.Faction:Language(), '', inMessage:From(), '', 0, 0, '', 0, _, inMessage:From())
        end
    end
end

local function DisplayAchievement(inMessage)
    
    local message = XF.Settings.Frames.Chat.Prepend
    local frame = GetFrame()
    if(frame ~= nil) then
        local text = ''

        if(XF.Config.Chat.GChat.Faction) then
            text = text .. format('%s ', format(XF.Icons.String, inMessage:Faction():IconID()))
        end

        if(XF.Player.Faction:Equals(inMessage:Faction())) then
            text = text .. '%s '
        else
            local friend = XFO.Friends:Get(inGuild:GetRealm(), inName)
            if(friend ~= nil) then
                text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inName, friend:GetAccountID(), inName, inName) .. ' '
            else
                -- Maybe theyre in a bnet community together, no way to associate tho
                text = text .. '%s '
            end
        end

        if(XF.Config.Chat.Achievement.Main and inMessage:MainName() ~= nil) then
            text = text .. '(' .. inMessage:MainName() .. ') '
        end

        if(XF.Config.Chat.Achievement.Guild) then
            text = text .. '<' .. inMessage:Guild():Initials() .. '> '
        end

        text = text .. inMessage:Data()

        local hex = GetChatColor('Achievement', inMessage():Faction())
        if hex ~= nil then
            text = format('|cff%s%s|r', hex, text)
        end

        if(XFO.Addons.WIM:IsLoaded() and XFO.Addons.WIM:API().modules.GuildChat.enabled) then
            XFO.Addons.WIM:API():CHAT_MSG_GUILD_ACHIEVEMENT(text, inMessage:From():UnitName(), XF.Player.Faction:Language(), '', inMessage:From():UnitName(), '', 0, 0, '', 0, _, inMessage:From():Key())
        else
            text = XF.Settings.Frames.Chat.Prepend .. text
            XFF.ChatHandler(frame, 'CHAT_MSG_GUILD_ACHIEVEMENT', text, inMessage:From():UnitName(), XF.Player.Faction:Language(), '', inMessage:From():UnitName(), '', 0, 0, '', 0, _, inMessage:From():Key())
        end
    end
end

function XFC.ChatFrame:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message', 'argument must be Message type object')
    if(XF.Player.Unit:CanGuildListen() and not XF.Player.Guild:Equals(inMessage:Guild())) then
        if(inMessage:Subject() == XF.Enum.Message.GCHAT and XF.Config.Chat.GChat.Enable) then
            DisplayGuildChat(inMessage)
        elseif(inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT and XF.Config.Chat.Achievement.Enable) then
            DisplayAchievement(inMessage)
        end
    end
end
--#endregion