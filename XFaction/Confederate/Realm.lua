local XFG, G = unpack(select(2, ...))
local ObjectName = 'Realm'

Realm = Object:newChildConstructor()

--#region Constructors
function Realm:new()
    local object = Realm.parent.new(self)
    object.__name = ObjectName
    object.ID = 0
    object.connectedRealms = nil
    object.connectedRealmCount = 0
    object.apiName = nil
    object.isTargeted = false
    return object
end
--#endregion

--#region Initializers
function Realm:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.connectedRealms = {}
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function Realm:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
    XFG:Debug(ObjectName, '  isTargeted (' .. type(self.isTargeted) .. '): ' .. tostring(self.isTargeted))
    XFG:Debug(ObjectName, '  connectedRealmCount (' .. type(self.connectedRealmCount) .. '): ' .. tostring(self.connectedRealmCount))
    for _, realm in pairs (self.connectedRealms) do
        XFG:Debug(ObjectName, '* connectedRealm [%d]', realm:GetID())
    end
end
--#endregion

--#region Iterators
function Realm:ConnectedIterator()
    return next, self.connectedRealms, nil
end
--#endregion

--#region Hash
function Realm:HasConnections()
    return self.connectedRealmCount > 1
end

function Realm:AddConnected(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    if(self.connectedRealms[inRealm:GetID()] == nil) then
        self.connectedRealms[inRealm:GetID()] = inRealm
        self.connectedRealmCount = self.connectedRealmCount + 1
    end
end

function Realm:IsConnected(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    for _, realm in pairs (self.connectedRealms) do
        if(inRealm:Equals(realm)) then
            return true
        end
    end
    return false
end
--#endregion

--#region Accessors
function Realm:GetAPIName()
    return self.apiName
end

function Realm:GetID()
    return self.ID
end

function Realm:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Realm:GetAPIName()
    if(self.apiName == nil) then 
        self.apiName = GetNormalizedRealmName() 
    end
    return self.apiName
end

function Realm:IsTargeted(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isTargeted = inBoolean
    end
    return self.isTargeted
end

function Realm:IsCurrent()
    return self:GetID() == GetRealmID()
end
--#endregion

--#region Operators
function Realm:Equals(inRealm)
    if(inRealm == nil) then return false end
    if(type(inRealm) ~= 'table' or inRealm.__name == nil) then return false end
    if(self:GetObjectName() ~= inRealm:GetObjectName()) then return false end
    if(self:GetKey() == inRealm:GetKey()) then return true end
    -- Consider connected realms equal
    for _, connectedRealm in self:ConnectedIterator() do
        if(connectedRealm:GetKey() == inRealm:GetKey()) then return true end
    end
    return false
end
--#endregion