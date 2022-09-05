local XFG, G = unpack(select(2, ...))
local ObjectName = 'Realm'

Realm = Object:newChildConstructor()

function Realm:new()
    local object = Realm.parent.new(self)
    object.__name = ObjectName
    object.apiName = nil
    object.ID = 0
    object.IDs = {}
    object.IDCount = 0
    return object
end

function Realm:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  IDCount (' .. type(self.IDCount) .. '): ' .. tostring(self.IDCount))
        XFG:Debug(ObjectName, '  IDs (' .. type(self.IDs) .. '): ')
        for _, value in pairs (self.IDs) do
            XFG:Debug(ObjectName, '  ID (' .. type(value) .. ') ' .. tostring(value))
        end
    end
end

function Realm:GetAPIName()
    return self.apiName
end

function Realm:SetAPIName(inName)
    assert(type(inName) == 'string')
    self.apiName = inName
end

function Realm:GetID()
    return self.ID
end

function Realm:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Realm:GetIDs()
    return self.IDs
end

function Realm:SetIDs(inIDs)
    assert(type(inIDs) == 'table')
    self.IDs = inIDs
    self.IDCount = table.getn(self.IDs)
end

function Realm:IsConnected()
    return self.IDCount > 1
end

function Realm:IDIterator()
    return next, self.IDs, nil
end