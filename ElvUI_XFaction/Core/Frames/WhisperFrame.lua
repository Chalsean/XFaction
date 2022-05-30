local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'WhisperFrame'
local LogCategory = 'FWhisper'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local AG = LibStub("AceGUI-3.0")

WhisperFrame = {}

function WhisperFrame:new(inObject)
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
        self._Frame = nil
    end

    return Object
end

function WhisperFrame:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())

        -- Create a container frame
        self._Frame = AG:Create("Frame")
        self._Frame:SetCallback('OnClose',function(widget) AG:Release(widget) end)
        self._Frame:SetTitle('XFaction Whisper')
        self._Frame:SetStatusText("Status Bar")
        self._Frame:SetLayout("Flow")
        -- Create a button
        local btn = AG:Create("Button")
        btn:SetWidth(170)
        btn:SetText("Button !")
        btn:SetCallback("OnClick", function() print("Click!") end)
        -- Add the button to the container
        self._Frame:AddChild(btn)

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function WhisperFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function WhisperFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _ElvUI (" .. type(self._ElvUI) .. "): ".. tostring(self._ElvUI))
end

function WhisperFrame:GetKey()
    return self._Key
end

function WhisperFrame:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end
