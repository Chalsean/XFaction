local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatFrame'
local LogCategory = 'FChat'

ChatFrame = {}

function ChatFrame:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
    self._ElvUI = false     
    self._ElvUIModule = nil  
    self._ChatFrameHandler = nil
    
    return _Object
end

function ChatFrame:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
        if IsAddOnLoaded('ElvUI') then
            local _Status, _Enabled = pcall(function()
                return ElvUI[1].private.chat.enable
            end)
            if _Status and _Enabled then
                XFG:Info(LogCategory, 'Using ElvUI chat handler')
                self:IsElvUI(true)
                self._ElvUIModule = ElvUI[1]:GetModule('Chat')
                self._ChatFrameHandler = function(...) self._ElvUIModule:FloatingChatFrame_OnEvent(...) end
            end
        else
            XFG:Info(LogCategory, 'Using default chat handler')
            self._ChatFrameHandler = ChatFrame_MessageEventHandler
        end

        if(self:UseWIM()) then
            XFG:Info(LogCategory, 'Using WIM for guild chat handler')
        end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChatFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ChatFrame:UseWIM()
	return IsAddOnLoaded('WIM') and WIM.modules.GuildChat.enabled
end

function ChatFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _ElvUI (' .. type(self._ElvUI) .. '): ' .. tostring(self._ElvUI))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function ChatFrame:GetKey()
    return self._Key
end

function ChatFrame:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ChatFrame:IsElvUI(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._ElvUI = inBoolean
    end
    return self._ElvUI
end

function ChatFrame:Display(inMessage)
    if(XFG.Config.Chat.GChat.Enable == false) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'GuildMessage', 'argument must be a GuildMessage object')

    local _Event = 'GUILD'
    local _ConfigNode = 'GChat'
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
        _Event = 'GUILD_ACHIEVEMENT'
        _ConfigNode = 'Achievement'
    end

    local _FrameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        local v
        for _, _FrameName in ipairs(_FrameTable) do
            if _FrameName == _Event then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then

                    local _Text = ''
                    local _Guild = inMessage:GetGuild()                    
                    local _Faction = _Guild:GetFaction()

                    if(XFG.Config.Chat[_ConfigNode].Faction) then  
                        _Text = _Text .. format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
                    end

                    if(_Event == 'GUILD_ACHIEVEMENT') then
                        if(_Faction:Equals(XFG.Player.Faction)) then
                            _Text = _Text .. '%s '
                        else
                            local _Friend = XFG.Friends:GetFriendByRealmUnitName(inMessage:GetRealm(), inMessage:GetName())
                            if(_Friend ~= nil) then
                                _Text = _Text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', inMessage:GetName(), _Friend:GetAccountID(), inMessage:GetName(), inMessage:GetName()) .. ' '
                            else
                                -- Maybe theyre in a bnet community together, no way to associate tho
                                _Text = _Text .. '%s '
                            end
                        end
                    end

                    if(XFG.Config.Chat[_ConfigNode].Main and inMessage:GetMainName() ~= nil) then
                        _Text = _Text .. '(' .. inMessage:GetMainName() .. ') '
                    end

                    if(XFG.Config.Chat[_ConfigNode].Guild) then
                        _Text = _Text .. '<' .. _Guild:GetInitials() .. '> '
                    end

                    if(_Event == 'GUILD_ACHIEVEMENT') then
                        _Text = _Text .. XFG.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(GetAchievementLink(inMessage:GetData()), "(Player.-:.-:.-:.-:.-:)"  , inMessage:GetFrom() .. ':1:' .. date("%m:%d:%y:") ) .. '!'
                    else
                        _Text = _Text .. inMessage:GetData()
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
                        local _Color = _G.ChatTypeInfo[_Event]
                        _Hex = XFG:RGBPercToHex(_Color.r, _Color.g, _Color.b)
                    end
                   
                    if _Hex ~= nil then
                        _Text = format('|cff%s%s|r', _Hex, _Text)
                    end

                    if(_Event == 'GUILD' and self:UseWIM()) then
                        WIM.modules.GuildChat:CHAT_MSG_GUILD(_Text, inMessage:GetUnitName(), XFG.Player.Faction:GetLanguage(), '', inMessage:GetUnitName(), '', 0, 0, '', 0, _, inMessage:GetFrom())
                    else
                        self._ChatFrameHandler(_G[_Frame], 'CHAT_MSG_' .. _Event, XFG.Settings.Frames.Chat.Prepend .. _Text, inMessage:GetUnitName(), XFG.Player.Faction:GetLanguage(), '', inMessage:GetUnitName(), '', 0, 0, '', 0, _, inMessage:GetFrom())
                    end
                end                                   
                break
            end
        end
    end
end