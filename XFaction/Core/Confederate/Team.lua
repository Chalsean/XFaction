local XFG, G = unpack(select(2, ...))
local ObjectName = 'Team'
local LogCategory = 'CTeam'

Team = {}

function Team:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Initials = nil
    self._Initialized = false

    return Object
end

function Team:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Team:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(self:GetInitials())
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Team:Print(inPrintOffline)
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _Initials (' .. type(self._Initials) .. '): ' .. tostring(self._Initials))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
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

function Team:GetInitials()
    return self._Initials
end

function Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self._Initials = inInitials
    return self:GetInitials()
end