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

function ChatFrame:DisplayChat(inEvent, inText, inSenderName, inFaction, inFlags, inLineID, inSenderGUID)
    local _FrameTable
    XFG:DataDumper(LogCategory, inSenderName)
    XFG:DataDumper(LogCategory, inSenderGUID)
    XFG:DataDumper(LogCategory, inFlags)
    XFG:DataDumper(LogCategory, inLineID)
    -- There are multiple chat windows, each registers for certain types of messages to display
    -- Thus GUILD can be on multiple chat windows and we need to display on all
    for i = 1, NUM_CHAT_WINDOWS do
        _FrameTable = { GetChatWindowMessages(i) }
        XFG:DataDumper(LogCategory, _FrameTable)
        local v
        for _, _Name in ipairs(_FrameTable) do
            if _Name == 'GUILD' then
                local _Frame = 'ChatFrame' .. i
                if _G[_Frame] then
                    local _SenderName = format('%s %s', format(IconTokenString, inFaction:GetIconID()), inSenderName)
                    self._ChatFrameHandler(_G[_Frame], 'CHAT_MSG_GUILD', inText, _SenderName, 'Common', '', inSenderName, inFlags, 0, 0, '', 0, _, inSenderGUID)
                end
                break
            end
        end
    end
end