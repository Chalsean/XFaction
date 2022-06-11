local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatFrame'
local LogCategory = 'FChat'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

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
                XFG:Info(LogCategory, "Using ElvUI chat handler")
                self:IsElvUI(true)
                self._ElvUIModule = ElvUI[1]:GetModule('Chat')
                self._ChatFrameHandler = function(...) self._ElvUIModule:FloatingChatFrame_OnEvent(...) end
            end
        else
            XFG:Info(LogCategory, "Using default chat handler")
            self._ChatFrameHandler = ChatFrame_MessageEventHandler
        end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChatFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ChatFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _ElvUI (" .. type(self._ElvUI) .. "): ".. tostring(self._ElvUI))
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
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "Usage: IsElvUI([boolean])")
    if(inBoolean ~= nil) then
        self._ElvUI = inBoolean
    end
    return self._ElvUI
end

function ChatFrame:DisplayGuild(inMessage)
    --if(XFG.Config.Chat.GChat.Enable == false) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
    local _FrameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        local v
        for _, _FrameName in ipairs(_FrameTable) do
            if _FrameName == 'GUILD' then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then

                    local _Text = ''
                    local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())

                    if(XFG.Config.Chat.GChat.Faction) then
                        local _Faction = _Guild:GetFaction()
                        _Text = format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
                    end

                    if(XFG.Config.Chat.GChat.Main and inMessage:GetMainName() ~= nil) then
                            _Text = _Text .. "(" .. inMessage:GetMainName() .. ") "
                    end

                    if(XFG.Config.Chat.GChat.Guild) then
                        _Text = _Text .. "<" .. _Guild:GetShortName() .. "> "
                    end

                    _Text = _Text .. inMessage:GetData()
                    
                    --local _Hex = XFG:RGBPercToHex(XFG.Config.Chat.GChat.Color.Red, XFG.Config.Chat.GChat.Color.Green, XFG.Config.Chat.GChat.Color.Blue)
                    --_Text = format('|cff%s%s|r', _Hex, _Text)

                    local _Channel = XFG.Network.Outbox:GetLocalChannel()
                    local _ChannelName = _Channel:GetName()
                    
                    self._ChatFrameHandler(_G[_Frame], 'CHAT_MSG_GUILD', _Text, inMessage:GetUnitName(), 'Common', '', inMessage:GetUnitName(), '', 0, 0, '', 0, _, inMessage:GetFrom())
                end                                   
                break
            end
        end
    end
end

function ChatFrame:DisplayAchievement(inMessage)
    --if(XFG.Config.System.Achievement == false) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
    local _FrameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        local v
        for _, _FrameName in ipairs(_FrameTable) do
            if _FrameName == 'ACHIEVEMENT' then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then

                    local _Text = ''
                    local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())

                    if(XFG.Config.Chat.GChat.Faction) then
                        local _Faction = _Guild:GetFaction()
                        _Text = format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
                    end

                    if(XFG.Config.Chat.GChat.Main and inMessage:GetMainName() ~= nil) then
                            _Text = _Text .. "(" .. inMessage:GetMainName() .. ") "
                    end

                    if(XFG.Config.Chat.GChat.Guild) then
                        _Text = _Text .. "<" .. _Guild:GetShortName() .. "> "
                    end

                    _Text = _Text .. inMessage:GetData()
                    
                    local _Hex = XFG:RGBPercToHex(XFG.Config.Chat.GChat.Color.Red, XFG.Config.Chat.GChat.Color.Green, XFG.Config.Chat.GChat.Color.Blue)
                    _Text = format('|cff%s%s|r', _Hex, _Text)

                    local _Channel = XFG.Network.Outbox:GetLocalChannel()
                    local _ChannelName = _Channel:GetName()
                    
                    self._ChatFrameHandler(_G[_Frame], 'CHAT_MSG_ACHIEVEMENT', _Text, inMessage:GetUnitName(), 'Common', '', inMessage:GetUnitName(), '', 0, 0, '', 0, _, inMessage:GetFrom())
                end                                   
                break
            end
        end
    end
end