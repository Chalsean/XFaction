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
function XFC.ChatFrame:Display(inType, inName, inUnitName, inMainName, inGuild, inFrom, inData)
    assert(type(inName) == 'string')
    assert(type(inUnitName) == 'string')
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')

    local faction = inGuild:Faction()
    local message = XF.Settings.Frames.Chat.Prepend

    if(inType == XF.Enum.Message.GCHAT) then inType = 'GUILD' end
    if(inType == XF.Enum.Message.ACHIEVEMENT) then inType = 'GUILD_ACHIEVEMENT' end
    local configNode = inType == 'GUILD' and 'GChat' or 'Achievement'
    if(not XF.Config.Chat[configNode].Enable) then return end

    local frameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        frameTable = { GetChatWindowMessages(i) }
        local v
        for _, frameName in ipairs(frameTable) do
            if frameName == inType then
                local frame = 'ChatFrame' .. i
                if _G[frame] then

                    local text = ''

                    if(XF.Config.Chat[configNode].Faction) then  
                        text = text .. format('%s ', format(XF.Icons.String, faction:IconID()))
                    end

                    if(inType == 'GUILD_ACHIEVEMENT') then
                        --FIXif(faction:Equals(XF.Player.Faction)) then
                            text = text .. '%s '
                        -- else
                        --     local friend = XFO.Friends:GetByRealmUnitName(inGuild:GetRealm(), inName)
                        --     if(friend ~= nil) then
                        --         text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inName, friend:GetAccountID(), inName, inName) .. ' '
                        --     else
                        --         -- Maybe theyre in a bnet community together, no way to associate tho
                        --         text = text .. '%s '
                        --     end
                        -- end
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
                            hex = faction:IsHorde() and XF:RGBPercToHex(XF.Config.Chat[configNode].HColor.Red, XF.Config.Chat[configNode].HColor.Green, XF.Config.Chat[configNode].HColor.Blue) or XF:RGBPercToHex(XF.Config.Chat[configNode].AColor.Red, XF.Config.Chat[configNode].AColor.Green, XF.Config.Chat[configNode].AColor.Blue)
                        else
                            hex = XF:RGBPercToHex(XF.Config.Chat[configNode].Color.Red, XF.Config.Chat[configNode].Color.Green, XF.Config.Chat[configNode].Color.Blue)
                        end
                    elseif(XF.Config.Chat[configNode].FColor) then
                        hex = faction:IsHorde() and 'E0000D' or '378DEF'
                    else
                        local color = _G.ChatTypeInfo[inType]
                        hex = XF:RGBPercToHex(color.r, color.g, color.b)
                    end
                   
                    if hex ~= nil then
                        text = format('|cff%s%s|r', hex, text)
                    end

                    if(inType == 'GUILD' and XF.Addons.WIM:IsLoaded() and XF.Addons.WIM:GetAPI().modules.GuildChat.enabled) then
                        XF.Addons.WIM:GetAPI():CHAT_MSG_GUILD(text, inUnitName, XF.Player.Faction:Language(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    else
                        text = XF.Settings.Frames.Chat.Prepend .. text
                        ChatFrame_MessageEventHandler(_G[frame], 'CHAT_MSG_' .. inType, text, inUnitName, XF.Player.Faction:Language(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    end
                end                                   
                break
            end
        end
    end
end

function XFC.ChatFrame:DisplayGuildChat(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    if(not XF.Config.Chat.GChat.Enable) then return end
    self:Display(inMessage:Subject(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild(), inMessage:From(), inMessage:Data())
end

function XFC.ChatFrame:DisplayAchievement(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    if(not XF.Config.Chat.Achievement.Enable) then return end
    self:Display(inMessage:Subject(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild(), inMessage:From(), inMessage:Data())
end
--#endregion