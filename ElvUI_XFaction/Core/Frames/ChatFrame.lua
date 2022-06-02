local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ChatFrame'
local LogCategory = 'FChat'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

ChatFrame = {}

function ChatFrame:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Initialized = false
        self._ElvUI = false     
        self._ElvUIModule = nil 
        self._ChatFrameHandler = nil  
    end

    return Object
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

function ChatFrame:DisplayChat(inEvent, inMessage)
    local _FrameTable
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        local v
        for _, _FrameName in ipairs(_FrameTable) do
            if _FrameName == 'CHANNEL' then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then

                    local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
                    local _Faction = _Guild:GetFaction()
                    local _, _, _, _, _, _Name = GetPlayerInfoByGUID(inMessage:GetFrom())

                    local _Text = format('%s ', format(IconTokenString, _Faction:GetIconID()))
                    if(inMessage:GetMainName() ~= nil) then
                        _Text = _Text .. "(" .. inMessage:GetMainName() .. ") "
                    end
                    _Text = _Text .. "<" .. _Guild:GetShortName() .. "> " .. inMessage:GetData()

                    local _Channel = XFG.Network.Sender:GetLocalChannel()
                    local _ChannelName = _Channel:GetName()
                    
                    self._ChatFrameHandler(_G[_Frame], 'CHAT_MSG_' .. inEvent, _Text, _Name, 'Common', _ChannelName, _Name, inMessage:GetFlags(), 0, _Channel:GetID(), _Channel:GetShortName(), 0, _, inMessage:GetFrom())
                end                                   
                break
            end
        end
    end
end