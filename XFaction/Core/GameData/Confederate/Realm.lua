local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Realm'
local GetAPIRealmName = GetNormalizedRealmName

XFC.Realm = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Realm:new()
    local object = XFC.Realm.parent.new(self)
    object.__name = ObjectName
    object.connectedRealms = nil
    object.connectedRealmCount = 0
    object.apiName = nil
    object.isTargeted = false
    return object
end
--#endregion

--#region Initializers
function XFC.Realm:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.connectedRealms = {}
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function XFC.Realm:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
    XF:Debug(self:GetObjectName(), '  isTargeted (' .. type(self.isTargeted) .. '): ' .. tostring(self.isTargeted))
    XF:Debug(self:GetObjectName(), '  connectedRealmCount (' .. type(self.connectedRealmCount) .. '): ' .. tostring(self.connectedRealmCount))
    for _, realm in pairs (self.connectedRealms) do
        XF:Debug(self:GetObjectName(), '* connectedRealm [%d]', realm:GetID())
    end
end
--#endregion

--#region Iterators
function XFC.Realm:ConnectedIterator()
    return next, self.connectedRealms, nil
end
--#endregion

--#region Hash
function XFC.Realm:HasConnections()
    return self.connectedRealmCount > 1
end

function XFC.Realm:AddConnected(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    if(self.connectedRealms[inRealm:GetID()] == nil) then
        self.connectedRealms[inRealm:GetID()] = inRealm
        self.connectedRealmCount = self.connectedRealmCount + 1
    end
end

function XFC.Realm:IsConnected(inRealm)
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
function XFC.Realm:GetAPIName()
    return self.apiName
end

function XFC.Realm:GetAPIName()
    if(self.apiName == nil) then 
        self.apiName = GetAPIRealmName() 
    end
    return self.apiName
end

function XFC.Realm:IsTargeted(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isTargeted = inBoolean
    end
    return self.isTargeted
end

function XFC.Realm:IsCurrent()
    return self:GetID() == GetRealmID()
end
--#endregion

--#region Operators
function XFC.Realm:Equals(inRealm)
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