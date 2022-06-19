local XFG, G = unpack(select(2, ...))
local ObjectName = 'XFactionFrame'
local LogCategory = 'FXFaction'

XFactionFrame = {}

function XFactionFrame:new(inObject)
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
        self._HeaderFont = nil
        self._RegularFont = nil
    end

    return Object
end

function XFactionFrame:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())

        self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

        local _Frame = CreateFrame('Frame', nil, UIParent)
        _Frame.anim = _Frame:CreateAnimationGroup()
        _Frame.rotate = _Frame.anim:CreateAnimation ("Rotation")
        _Frame.rotate:SetDegrees (360)
        _Frame.rotate:SetDuration (2)
        _Frame.anim:SetLooping ("repeat")
	
	    local t = _Frame:CreateTexture (nil, "overlay")
	    t:SetTexture ([[Interface\COMMON\StreamCircle]])
	    t:SetAlpha (0.7)
	    t:SetAllPoints()

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFactionFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function XFactionFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function XFactionFrame:GetKey()
    return self._Key
end

function XFactionFrame:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end