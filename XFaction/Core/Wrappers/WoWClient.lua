local XFG, G = unpack(select(2, ...))
local ObjectName = 'WoWClient'
local LogCategory = 'WClient'

WoWClient = {}

function WoWClient:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._ID = nil
    self._Version = nil
    self._Initialized = false
    
    return Object
end

function WoWClient:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(WOW_PROJECT_ID)
        self:SetID(WOW_PROJECT_ID)
        if(WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
            self:SetName('Retail')
        elseif(WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
            self:SetName('Vanilla Classic')
        elseif(WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
            self:SetName('Burning Crusade Classic')
        end

        local _WoWVersion = GetBuildInfo()
        local _Version = Version:new()
        _Version:SetKey(_WoWVersion)        
        self:SetVersion(_Version)

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function WoWClient:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function WoWClient:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Version (' .. type(self._Version) .. '): ' .. tostring(self._Version))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function WoWClient:GetKey()
    return self._Key
end

function WoWClient:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function WoWClient:GetName()
    return self._Name
end

function WoWClient:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function WoWClient:GetID()
    return self._ID
end

function WoWClient:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function WoWClient:IsRetail()
    return self:GetID() == WOW_PROJECT_MAINLINE
end

function WoWClient:IsClassic()
    return self:GetID() == WOW_PROJECT_CLASSIC
end

function WoWClient:IsTBC()
    return self:GetID() == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

function WoWClient:GetVersion()
    return self._Version
end

function WoWClient:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
    self._Version = inVersion
    return self:GetVersion()
end