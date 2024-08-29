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
        XFF.ChatFrameFilter('CHAT_MSG_GUILD', XFO.ChatFrame.ChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD event filter')
        XFF.ChatFrameFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFO.ChatFrame.AchievementFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
local function GetChatHex(inEvent, inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction')
    local config = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'

    local hex = nil
    if(XF.Config.Chat[config].CColor) then
        if(XF.Config.Chat[config].FColor) then
            hex = inFaction:IsHorde() and XF:RGBPercToHex(XF.Config.Chat[config].HColor.Red, XF.Config.Chat[config].HColor.Green, XF.Config.Chat[config].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[config].AColor.Red, XF.Config.Chat[config].AColor.Green, XF.Config.Chat[config].AColor.Blue)
        else
            hex = XF:RGBPercToHex(XF.Config.Chat[config].Color.Red, XF.Config.Chat[config].Color.Green, XF.Config.Chat[config].Color.Blue)
        end
    elseif(XF.Config.Chat[config].FColor) then
        hex = inFaction:IsHorde() and 'E0000D' or '378DEF'
    else
        local color = _G.ChatTypeInfo[inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT']
        hex = XF:RGBPercToHex(color.r, color.g, color.b)
    end
    return hex
end

local function ModifyFilterMessage(inEvent, inText, inUnit)
    local configNode = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local event = inEvent == 'CHAT_MSG_GUILD' and 'GUILD' or 'GUILD_ACHIEVEMENT'
    local text = ''
    if(XF.Config.Chat[configNode].Faction and inUnit:HasFaction()) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Faction():IconID()))
    end
    if(XF.Config.Chat[configNode].Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end
    if(XF.Config.Chat[configNode].Guild and inUnit:HasGuild()) then
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    text = text .. inText

    if(inUnit:HasFaction()) then
        local hex = GetChatHex(inEvent, inUnit:Faction())
        if hex ~= nil then
            text = format('|cff%s%s|r', hex, text)
        end
    end

    return text
end

function XFC.ChatFrame:GetMessagePrefix(inEvent, inUnit)
    assert(type(inEvent) == 'string')
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    local config = inEvent == 'CHAT_MSG_GUILD' and 'GChat' or 'Achievement'
    local text = ''
    if(XF.Config.Chat[config].Faction and inUnit:HasFaction()) then
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Faction():IconID()))
    end

    if(inEvent == 'CHAT_MSG_GUILD_ACHIEVEMENT') then
        if(inUnit:IsSameFaction()) then
            text = text .. '%s '
        elseif(inUnit:IsFriend()) then
            text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inUnit:Name(), inUnit:Friend():AccountID(), inUnit:Name(), inUnit:Name()) .. ' '
        else
            text = text .. '%s '
        end
    end

    if(XF.Config.Chat[config].Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end

    if(XF.Config.Chat[config].Guild and inUnit:HasGuild()) then
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end

    return text
end

local function ModifyPlayerChat(inEvent, inText, inUnit)
    assert(type(inEvent) == 'string')
    assert(type(inText) == 'string')
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    local text = GetMessagePrefix(inEvent, inUnit) .. inText
    if(inUnit:HasFaction()) then
        local hex = GetChatHex(inEvent, inUnit:Faction())
        if hex ~= nil then
            text = format('|cff%s%s|r', hex, text)
        end
    end

    return text
end

function XFC.ChatFrame:ChatFilter(inEvent, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(not XF.Config.Chat.GChat.Enable) then
        return true
    elseif(string.find(inText, XF.Settings.Frames.Chat.Prepend)) then
        inText = string.gsub(inText, XF.Settings.Frames.Chat.Prepend, '')
    -- Whisper sometimes throws an erronous error, so hide it to avoid confusion for the player
    elseif(string.find(inText, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    elseif(XFO.Confederate:Contains(inGUID)) then
        inText = ModifyFilterMessage(inEvent, inText, XFO.Confederate:Get(inGUID))
    end
    return false, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

function XFC.ChatFrame:AchievementFilter(inEvent, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    if(not XF.Config.Chat.Achievement.Enable) then
        return true
    elseif(string.find(inText, XF.Settings.Frames.Chat.Prepend)) then
        inText = string.gsub(inText, XF.Settings.Frames.Chat.Prepend, '')
    elseif(XFO.Confederate:Contains(inGUID)) then
        inText = ModifyFilterMessage(inEvent, inText, XFO.Confederate:Get(inGUID))
    end
    return false, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

local function DisplayGuildChat(inUnit, inText)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    assert(type(inText) == 'string')

    local frameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        frameTable = { XFF.ChatGetWindow(i) }
        local v
        for _, frameName in ipairs(frameTable) do
            if frameName == 'GUILD' then
                local frame = 'ChatFrame' .. i
                if _G[frame] then

                    local text = XFO.ChatFrame:GetMessagePrefix('CHAT_MSG_GUILD', inUnit) .. inText
                    local hex = GetChatHex('CHAT_MSG_GUILD', inUnit:Faction())                   
                    if hex ~= nil then
                        text = format('|cff%s%s|r', hex, text)
                    end

                    if(XFO.WIM:IsLoaded() and XFO.WIM:API().modules.GuildChat.enabled) then
                        XFO.WIM:API():CHAT_MSG_GUILD(text, inUnit:UnitName(), XF.Player.Faction():Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                    else
                        text = XF.Settings.Frames.Chat.Prepend .. text
                        XFF.ChatHandler(_G[frame], 'CHAT_MSG_GUILD', text, inUnit:UnitName(), XF.Player.Faction:Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                    end
                end                                   
                break
            end
        end
    end
end

local function DisplayAchievement(inUnit, inID)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    assert(type(inID) == 'number')

    local frameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        frameTable = { XFF.ChatGetWindow(i) }
        local v
        for _, frameName in ipairs(frameTable) do
            if frameName == 'GUILD_ACHIEVEMENT' then
                local frame = 'ChatFrame' .. i
                if _G[frame] then

                    local text = XFO.ChatFrame:GetMessagePrefix('CHAT_MSG_GUILD_ACHIEVEMENT', inUnit)
                    text = text .. XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(XFF.PlayerAchievementLink(inID), "(Player.-:.-:.-:.-:.-:)"  , inUnit:GUID() .. ':1:' .. date("%m:%d:%y:") ) .. '!'
                    local hex = GetChatHex('CHAT_MSG_GUILD_ACHIEVEMENT', inUnit:Faction())                   
                    if hex ~= nil then
                        text = format('|cff%s%s|r', hex, text)
                    end
                    
                    text = XF.Settings.Frames.Chat.Prepend .. text  
                    XFF.ChatHandler(_G[frame], 'CHAT_MSG_GUILD_ACHIEVEMENT', text, inUnit:UnitName(), XF.Player.Faction:Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                end                                   
                break
            end
        end
    end
end

function XFC.ChatFrame:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(not XF.Player.Unit:CanGuildListen()) then return end
    if(inMessage:FromUnit():IsSameGuild()) then return end
    if(XFF.PlayerIsIgnored(inMessage:From())) then return end

    if(inMessage:IsGuildChatMessage()) then
        if(not XF.Config.Chat.GChat.Enable) then return end
        DisplayGuildChat(inMessage:FromUnit(), inMessage:Data())
        XFO.Elephant:AddMessage(inMessage, 'CHAT_MSG_GUILD')
    elseif(inMessage:IsAchievementMessage()) then
        if(not XF.Config.Chat.Achievement.Enable) then return end
        DisplayAchievement(inMessage:FromUnit(), inMessage:Data())
        XFO.Elephant:AddMessage(inMessage, 'CHAT_MSG_GUILD_ACHIEVEMENT')
    end
end
--#endregion