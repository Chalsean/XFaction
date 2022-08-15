local XFG, G = unpack(select(2, ...))

Realm = Object:newChildConstructor()

function Realm:new()
    local _Object = Realm.parent.new(self)
    _Object.__name = 'Realm'
    self._APIName = nil
    self._IDs = {}
    self._IDCount = 0
    return _Object
end

function Realm:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
    XFG:Debug(self:GetObjectName(), '  _IDCount (' .. type(self._IDCount) .. '): ' .. tostring(self._IDCount))
    XFG:Debug(self:GetObjectName(), '  _IDs (' .. type(self._IDs) .. '): ')
    for _, _Value in pairs (self._IDs) do
        XFG:Debug(self:GetObjectName(), '  ID (' .. type(_Value) .. ') ' .. tostring(_Value))
    end
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