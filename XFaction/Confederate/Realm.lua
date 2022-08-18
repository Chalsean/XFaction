local XFG, G = unpack(select(2, ...))
local ObjectName = 'Realm'

Realm = Object:newChildConstructor()

function Realm:new()
    local _Object = Realm.parent.new(self)
    _Object.__name = ObjectName
    self._APIName = nil
    self._IDs = {}
    self._IDCount = 0
    return _Object
end

function Realm:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
        XFG:Debug(ObjectName, '  _IDCount (' .. type(self._IDCount) .. '): ' .. tostring(self._IDCount))
        XFG:Debug(ObjectName, '  _IDs (' .. type(self._IDs) .. '): ')
        for _, _Value in pairs (self._IDs) do
            XFG:Debug(ObjectName, '  ID (' .. type(_Value) .. ') ' .. tostring(_Value))
        end
    end
end

function Realm:GetAPIName()
    return self._APIName
end

function Realm:SetAPIName(inName)
    assert(type(inName) == 'string')
    self._APIName = inName
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
end

function Realm:IsConnected()
    return self._IDCount > 1
end