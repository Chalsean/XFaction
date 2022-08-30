local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatFrame'

ChatFrame = Object:newChildConstructor()

function ChatFrame:new()
    local _Object = ChatFrame.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function ChatFrame:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetHandler()
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChatFrame:SetHandler()
    if(XFG.ElvUI) then
        local _Status, _Enabled = pcall(function()
            return XFG.ElvUI.private.chat.enable
        end)
        if _Status and _Enabled then
            XFG:Info(ObjectName, 'Using ElvUI chat handler')
            self._ElvUIModule = XFG.ElvUI:GetModule('Chat')
            self._ChatFrameHandler = function(...) self._ElvUIModule:FloatingChatFrame_OnEvent(...) end
        else
            XFG:Error(ObjectName, 'Failed to detect if elvui has chat enabled')
            self._ChatFrameHandler = ChatFrame_MessageEventHandler
        end
    else
        XFG:Info(ObjectName, 'Using default chat handler')
        self._ChatFrameHandler = ChatFrame_MessageEventHandler
    end
end

function ChatFrame:Display(inType, inName, inUnitName, inMainName, inGuild, inRealm, inFrom, inData)
    assert(type(inName) == 'string')
    assert(type(inUnitName) == 'string')
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')

    local _Faction = inGuild:GetFaction()
    local _Message = XFG.Settings.Frames.Chat.Prepend

    if(inType == XFG.Settings.Network.Message.Subject.GCHAT) then inType = 'GUILD' end
    if(inType == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then inType = 'GUILD_ACHIEVEMENT' end
    local _ConfigNode = inType == 'GUILD' and 'GChat' or 'Achievement'
    if(not XFG.Config.Chat[_ConfigNode].Enable) then return end

    local _FrameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        local v
        for _, _FrameName in ipairs(_FrameTable) do
            if _FrameName == inType then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then

                    local _Text = ''

                    if(XFG.Config.Chat[_ConfigNode].Faction) then  
                        _Text = _Text .. format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
                    end

                    if(inType == 'GUILD_ACHIEVEMENT') then
                        if(_Faction:Equals(XFG.Player.Faction)) then
                            _Text = _Text .. '%s '
                        else
                            local _Friend = XFG.Friends:GetByRealmUnitName(inRealm, inName)
                            if(_Friend ~= nil) then
                                _Text = _Text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inName, _Friend:GetAccountID(), inName, inName) .. ' '
                            else
                                -- Maybe theyre in a bnet community together, no way to associate tho
                                _Text = _Text .. '%s '
                            end
                        end
                    end

                    if(XFG.Config.Chat[_ConfigNode].Main and inMainName ~= nil) then
                        _Text = _Text .. '(' .. inMainName .. ') '
                    end

                    if(XFG.Config.Chat[_ConfigNode].Guild) then
                        _Text = _Text .. '<' .. inGuild:GetInitials() .. '> '
                    end

                    if(inType == 'GUILD_ACHIEVEMENT') then
                        _Text = _Text .. XFG.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(GetAchievementLink(inData), "(Player.-:.-:.-:.-:.-:)"  , inFrom .. ':1:' .. date("%m:%d:%y:") ) .. '!'
                    else
                        _Text = _Text .. inData
                    end

                    local _Hex = nil
                    if(XFG.Config.Chat[_ConfigNode].CColor) then
                        if(XFG.Config.Chat[_ConfigNode].FColor) then
                            _Hex = _Faction:GetName() == 'Horde' and XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].HColor.Red, XFG.Config.Chat[_ConfigNode].HColor.Green, XFG.Config.Chat[_ConfigNode].HColor.Blue) or XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].AColor.Red, XFG.Config.Chat[_ConfigNode].AColor.Green, XFG.Config.Chat[_ConfigNode].AColor.Blue)
                        else
                            _Hex = XFG:RGBPercToHex(XFG.Config.Chat[_ConfigNode].Color.Red, XFG.Config.Chat[_ConfigNode].Color.Green, XFG.Config.Chat[_ConfigNode].Color.Blue)
                        end
                    elseif(XFG.Config.Chat[_ConfigNode].FColor) then
                        _Hex = _Faction:GetName() == 'Horde' and 'E0000D' or '378DEF'
                    else
                        local _Color = _G.ChatTypeInfo[inType]
                        _Hex = XFG:RGBPercToHex(_Color.r, _Color.g, _Color.b)
                    end
                   
                    if _Hex ~= nil then
                        _Text = format('|cff%s%s|r', _Hex, _Text)
                    end

                    if(inType == 'GUILD' and XFG.WIM) then
                        XFG.WIM:CHAT_MSG_GUILD(_Text, inUnitName, XFG.Player.Faction:GetLanguage(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    else
                        _Text = XFG.Settings.Frames.Chat.Prepend .. _Text
                        ChatFrame_MessageEventHandler(_G[_Frame], 'CHAT_MSG_' .. inType, _Text, inUnitName, XFG.Player.Faction:GetLanguage(), '', inUnitName, '', 0, 0, '', 0, _, inFrom)
                    end
                end                                   
                break
            end
        end
    end
end

function ChatFrame:DisplayGuildChat(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    self:Display(inMessage:GetSubject(), inMessage:GetName(), inMessage:GetUnitName(), inMessage:GetMainName(), inMessage:GetGuild(), inMessage:GetRealm(), inMessage:GetFrom(), inMessage:GetData())
end

function ChatFrame:DisplayAchievement(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    self:Display(inMessage:GetSubject(), inMessage:GetName(), inMessage:GetUnitName(), inMessage:GetMainName(), inMessage:GetGuild(), inMessage:GetRealm(), inMessage:GetFrom(), inMessage:GetData())
end