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

function XFC.ChatFrame:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFF.ChatFrameFilter('CHAT_MSG_GUILD', XFO.ChatFrame.CallbackChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD event filter')
        XFF.ChatFrameFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFO.ChatFrame.CallbackAchievementFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
local function _ModifyPlayerChat(inEvent, inText, inUnit)
    local configNode = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local event = inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT'
    local text = ''
    if(XF.Config.Chat[configNode].Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Race():Faction():IconID()))
    end
    if(XF.Config.Chat[configNode].Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end
    if(XF.Config.Chat[configNode].Guild) then
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    text = text .. inText

    local hex = nil
    if(XF.Config.Chat[configNode].CColor) then
        if(XF.Config.Chat[configNode].FColor) then
            hex = inUnit:Race():Faction():IsHorde() and XF:RGBPercToHex(XF.Config.Chat[configNode].HColor.Red, XF.Config.Chat[configNode].HColor.Green, XF.Config.Chat[configNode].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[configNode].AColor.Red, XF.Config.Chat[configNode].AColor.Green, XF.Config.Chat[configNode].AColor.Blue)
        else
            hex = XF:RGBPercToHex(XF.Config.Chat[configNode].Color.Red, XF.Config.Chat[configNode].Color.Green, XF.Config.Chat[configNode].Color.Blue)
        end
    elseif(XF.Config.Chat[configNode].FColor) then
        hex = inUnit:Race():Faction():IsHorde() and 'E0000D' or '378DEF'
    elseif(_G.ChatTypeInfo[event]) then
        local color = _G.ChatTypeInfo[event]
        hex = XF:RGBPercToHex(color.r, color.g, color.b)
    end
    
    if hex ~= nil then
        text = format('|cff%s%s|r', hex, text)
    end

    return text
end

function XFC.ChatFrame:CallbackChatFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    local self = XFO.ChatFrame
    if(not XF.Config.Chat.GChat.Enable) then
        return true
    elseif(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
    -- Whisper sometimes throws an erronous error, so hide it to avoid confusion for the player
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    elseif(XFO.Confederate:Contains(inGUID)) then
        inMessage = _ModifyPlayerChat(inEvent, inMessage, XFO.Confederate:Get(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

function XFC.ChatFrame:CallbackAchievementFilter(inEvent, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    local self = XFO.ChatFrame
    if(not XF.Config.Chat.Achievement.Enable) then
        return true
    elseif(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
    elseif(XFO.Confederate:Contains(inGUID)) then
        inMessage = _ModifyPlayerChat(inEvent, inMessage, XFO.Confederate:Get(inGUID))
    end
    return false, inMessage, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

function XFC.ChatFrame:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    if(inMessage:IsLegacy()) then
        self:LegacyProcessMessage(inMessage)
        return
    end

    if(XF.Player.Unit:CanGuildListen()) then
        if(not inMessage:FromUnit():IsSameGuild()) then
            if(inMessage:IsGuildChat()) then
                XFO.ChatFrame:DisplayGuildChat(inMessage:FromUnit(), inMessage:Data())
            else
                XFO.ChatFrame:DisplayAchievement(inMessage:FromUnit(), inMessage:Data())
            end
        end
    end
end

local function _DisplayChatWindows(inUnit, inType, inText)
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        local frameTable = { XFF.ChatGetWindow(i) }
        for _, frameName in ipairs(frameTable) do
            if frameName == inType then -- GUILD or GUILD_ACHIEVEMENT
                local frame = 'ChatFrame' .. i
                if _G[frame] then
                    if(inType == 'GUILD' and XFO.WIM:IsLoaded() and XFO.WIM:API().modules.GuildChat.enabled) then
                        XFO.WIM:API():CHAT_MSG_GUILD(inText, inUnit:UnitName(), XF.Player.Faction:Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                    else
                        XFF.ChatHandler(_G[frame], 'CHAT_MSG_' .. inType, inText, inUnitName, XF.Player.Faction:Language(), '', inUnitName, '', 0, 0, '', 0, _, inUnit:GUID())
                    end
                end
            end
        end
    end
end

function XFC.ChatFrame:DisplayGuildChat(inUnit, inText)
    if(not XF.Config.Chat.GChat.Enable) then return end
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    assert(type(inText) == 'string')

    local text = XF.Settings.Frames.Chat.Prepend .. _ModifyPlayerChat('CHAT_MSG_GUILD', inText, inUnit)
    _DisplayChatWindows(inUnit, 'GUILD', text)
end

function XFC.ChatFrame:DisplayAchievement(inUnit, inID)
    if(not XF.Config.Chat.Achievement.Enable) then return end
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    assert(type(inID) == 'number')

    local text = XF.Settings.Frames.Chat.Prepend
    local achievement = XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(XFF.PlayerGetAchievementLink(inID), "(Player.-:.-:.-:.-:.-:)"  , inUnit:GUID() .. ':1:' .. date("%m:%d:%y:") ) .. '!'
    text = text .. _ModifyPlayerChat('CHAT_MSG_GUILD_ACHIEVEMENT', achievement, inUnit)
    _DisplayChatWindows(inUnit, 'GUILD_ACHIEVEMENT', text)
end

--#region Deprecated, remove after 4.13
function XFC.ChatFrame:LegacyDisplay(inType, inName, inUnitName, inMainName, inGuild, inFrom, inData, inFaction)
    assert(type(inName) == 'string')
    assert(type(inUnitName) == 'string')
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild')

    local message = XF.Settings.Frames.Chat.Prepend

    if(inType == XF.Enum.Message.GCHAT) then inType = 'GUILD' end
    if(inType == XF.Enum.Message.ACHIEVEMENT) then inType = 'GUILD_ACHIEVEMENT' end
    local configNode = inType == 'GUILD' and 'GChat' or 'Achievement'
    if(not XF.Config.Chat[configNode].Enable) then return end

    local frameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        frameTable = { XFF.ChatGetWindow(i) }
        local v
        for _, frameName in ipairs(frameTable) do
            if frameName == inType then
                local frame = 'ChatFrame' .. i
                if _G[frame] then

                    local text = ''

                    if(XF.Config.Chat[configNode].Faction) then  
                        text = text .. format('%s ', format(XF.Icons.String, inFaction:IconID()))
                    end

                    if(inType == 'GUILD_ACHIEVEMENT') then
                        if(inFaction:Equals(XF.Player.Faction)) then
                            text = text .. '%s '
                        else
                            -- TODO
                            -- local friend = XFO.Friends:GetByRealmUnitName(inGuild:Realm(), inName)
                            -- if(friend ~= nil) then
                            --     text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inName, friend:GetAccountID(), inName, inName) .. ' '
                            -- else
                                -- Maybe theyre in a bnet community together, no way to associate tho
                                text = text .. '%s '
                            -- end
                        end
                    end

                    if(XF.Config.Chat[configNode].Main and inMainName ~= nil) then
                        text = text .. '(' .. inMainName .. ') '
                    end

                    if(XF.Config.Chat[configNode].Guild) then
                        text = text .. '<' .. inGuild:Initials() .. '> '
                    end

                    if(inType == 'GUILD_ACHIEVEMENT') then
                        text = text .. XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(GetAchievementLink(inData), "(Player.-:.-:.-:.-:.-:)"  , inFrom .. ':1:' .. date("%m:%d:%y:") ) .. '!'
                    else
                        text = text .. inData
                    end

                    local hex = nil
                    if(XF.Config.Chat[configNode].CColor) then
                        if(XF.Config.Chat[configNode].FColor) then
                            hex = inFaction:Name() == 'Horde' and XF:RGBPercToHex(XF.Config.Chat[configNode].HColor.Red, XF.Config.Chat[configNode].HColor.Green, XF.Config.Chat[configNode].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[configNode].AColor.Red, XF.Config.Chat[configNode].AColor.Green, XF.Config.Chat[configNode].AColor.Blue)
                        else
                            hex = XF:RGBPercToHex(XF.Config.Chat[configNode].Color.Red, XF.Config.Chat[configNode].Color.Green, XF.Config.Chat[configNode].Color.Blue)
                        end
                    elseif(XF.Config.Chat[configNode].FColor) then
                        hex = inFaction:Name() == 'Horde' and 'E0000D' or '378DEF'
                    else
                        local color = _G.ChatTypeInfo[inType]
                        hex = XF:RGBPercToHex(color.r, color.g, color.b)
                    end
                   
                    if hex ~= nil then
                        text = format('|cff%s%s|r', hex, text)
                    end

                    if(inType == 'GUILD' and XFO.WIM:IsLoaded() and XFO.WIM:API().modules.GuildChat.enabled) then
                        XFO.WIM:API():CHAT_MSG_GUILD(text, inUnitName, XF.Player.Faction:Language(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    else
                        text = XF.Settings.Frames.Chat.Prepend .. text
                        XFF.ChatHandler(_G[frame], 'CHAT_MSG_' .. inType, text, inUnitName, XF.Player.Faction:Language(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    end
                end                                   
                break
            end
        end
    end
end

function XFC.ChatFrame:LegacyProcessMessage(inMessage)
    if(XF.Player.Unit:CanGuildListen()) then
        if(not XF.Player.Guild:Equals(inMessage:Guild())) then
            if(inMessage:IsGuildChat()) then
                XFO.ChatFrame:LegacyDisplayGuildChat(inMessage)
            else
                XFO.ChatFrame:LegacyDisplayAchievement(inMessage)
            end
        end
    end
end

function XFC.ChatFrame:LegacyDisplayGuildChat(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(not XF.Config.Chat.GChat.Enable) then return end
    self:LegacyDisplay(inMessage:Subject(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild(), inMessage:From(), inMessage:Data(), inMessage:Faction())
end

function XFC.ChatFrame:LegacyDisplayAchievement(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(not XF.Config.Chat.Achievement.Enable) then return end
    self:LegacyDisplay(inMessage:Subject(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild(), inMessage:From(), inMessage:Data(), inMessage:Faction())
end
--#endregion
--#endregion