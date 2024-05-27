local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Realm'

XFC.Realm = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Realm:new()
    local object = XFC.Realm.parent.new(self)
    object.__name = ObjectName
    object.connectedRealms = nil
    object.connectedRealmCount = 0
    object.apiName = nil
    object.isTargeted = false
    object.isCurrent = nil
    object.guildCount = 0
    return object
end

function XFC.Realm:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.connectedRealms = {}
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Realm:APIName()
    if(self.apiName == nil) then 
        self.apiName = XFF.RealmGetAPIName() 
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
    if(self.isCurrent == nil) then 
        self.isCurrent = self:ID() == XFF.RealmGetID()
    end
    return self.isCurrent
end

function XFC.Realm:GuildCount(inCount)
    assert(type(inCount) == 'number' or inCount == nil, 'argument must be number or nil')
    if(inCount ~= nil) then
        self.guildCount = inCount
    end
    return self.guildCount
end
--#endregion

--#region Methods
function XFC.Realm:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
    XF:Debug(self:ObjectName(), '  isTargeted (' .. type(self.isTargeted) .. '): ' .. tostring(self.isTargeted))
    XF:Debug(self:ObjectName(), '  isCurrent (' .. type(self.isCurrent) .. '): ' .. tostring(self.isCurrent))
    XF:Debug(self:ObjectName(), '  guildCount (' .. type(self.guildCount) .. '): ' .. tostring(self.guildCount))
    XF:Debug(self:ObjectName(), '  connectedRealmCount (' .. type(self.connectedRealmCount) .. '): ' .. tostring(self.connectedRealmCount))
    for _, realm in pairs (self.connectedRealms) do
        XF:Debug(self:ObjectName(), '* connectedRealm [%d]', realm:ID())
    end
end

function XFC.Realm:ConnectedIterator()
    return next, self.connectedRealms, nil
end

function XFC.Realm:HasConnections()
    return self.connectedRealmCount > 1
end

function XFC.Realm:AddConnected(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    if(self.connectedRealms[inRealm:ID()] == nil) then
        self.connectedRealms[inRealm:ID()] = inRealm
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

function XFC.Realm:Equals(inRealm)
    if(inRealm == nil) then return false end
    if(type(inRealm) ~= 'table' or inRealm.__name == nil) then return false end
    if(self:ObjectName() ~= inRealm:ObjectName()) then return false end
    if(self:Key() == inRealm:Key()) then return true end
    -- Consider connected realms equal
    for _, connectedRealm in self:ConnectedIterator() do
        if(connectedRealm:Key() == inRealm:Key()) then return true end
    end
    return false
end
--#endregion