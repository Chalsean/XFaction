local XFG, G = unpack(select(2, ...))
local ObjectName = 'Realm'
local LogCategory = 'CRealm'

Realm = {}

function Realm:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._APIName = nil
    self._IDs = {}
    self._IDCount = 0
    self._Initialized = false
    
    return Object
end

function Realm:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Realm:Initialize()
	if(self:IsInitialized() == false) then
        if(self:GetKey() == nil) then
            self:SetKey(GetRealmName())
            self:SetName(GetRealmName())
        end
        local _, _, _, _, _, _, _, _, _RealmIDs = XFG.Lib.Realm:GetRealmInfo(self:GetName())
        self:SetIDs(_RealmIDs)
	end
	return self:IsInitialized()
end

function Realm:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
    XFG:Debug(LogCategory, '  _IDCount (' .. type(self._IDCount) .. '): ' .. tostring(self._IDCount))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
    XFG:Debug(LogCategory, '  _IDs (' .. type(self._IDs) .. '): ')
    for _, _Value in pairs (self._IDs) do
        XFG:Debug(LogCategory, '  ID (' .. type(_Value) .. ') ' .. tostring(_Value))
    end
end

function Realm:GetKey()
    return self._Key
end

function Realm:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Realm:GetName()
    return self._Name
end

function Realm:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Realm:GetAPIName()
    return self._APIName
end

function Realm:SetAPIName(inName)
    assert(type(inName) == 'string')
    self._APIName = inName
    return self:GetAPIName()
end

function Realm:GetID()
    if(self._IDCount > 0) then
        return self._IDs[1]
    end
end

function Realm:GetIDs()
    return self._IDs
end

function Realm:SetIDs(inIDs)
    assert(type(inIDs) == 'table')
    self._IDs = inIDs
    self._IDCount = table.getn(self._IDs)
    return self:GetIDs()
end

function Realm:IsConnected()
    return self._IDCount > 1
end

function Realm:Equals(inRealm)
    if(inRealm == nil) then return false end
    if(type(inRealm) ~= 'table' or inRealm.__name == nil or inRealm.__name ~= 'Realm') then return false end
    if(self:GetKey() ~= inRealm:GetKey()) then return false end
    return true
end