local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Team'
local LogCategory = 'GTeam'

Team = {}

function Team:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or _typeof == 'string' or
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
        self._Name = nil
        self._ShortName = nil
        self._Initialized = false
    end

    return Object
end

function Team:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Team:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(self:GetShortName())
	end
	return self:IsInitialized()
end

function Team:Print(inPrintOffline)
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _ShortName (" .. type(self._ShortName) .. "): ".. tostring(self._ShortName))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Team:GetKey()
    return self._Key
end

function Team:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Team:GetName()
    return self._Name
end

function Team:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Team:GetShortName()
    return self._ShortName
end

function Team:SetShortName(inShortName)
    assert(type(inShortName) == 'string')
    self._ShortName = inShortName
    return self:GetShortName()
end