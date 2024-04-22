local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Link'

XFC.Link = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Link:new()
    local object = XFC.Link.parent.new(self)
    object.__name = ObjectName
    object.from = nil
    object.to = nil
    object.lastUpdatedTime = 0
    object.isActive = false
    return object
end

function XFC.Link:Deconstructor()
    self:ParentDeconstructor()
    self.from = nil
    self.to = nil
    self.lastUpdatedTime = 0
    self.isActive = false
end

function XFC.Link:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:LastUpdatedTime(XFF.TimeGetCurrent())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.Link:LastUpdatedTime(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil, 'argument must be number or nil')
    if(inEpochTime ~= nil) then
        self.lastUpdatedTime = inEpochTime
    end
    return self.lastUpdatedTime
end

function XFC.Link:From(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil, 'argument must be Unit object or nil')
    if(inUnit ~= nil) then
        self.from = inUnit
    end
    return self.from
end

function XFC.Link:To(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil, 'argument must be Unit object or nil')
    if(inUnit ~= nil) then
        self.to = inUnit
    end
    return self.to
end

function XFC.Link:Key()
    if(self.key == nil and self:HasFrom() and self:HasTo()) then
        self.key = self:From():Key() < self:To():Key() and self:From():Key() .. ':' .. self:To():Key() or self:To():Key() .. ':' .. self:From():Key()
    end
    return self.key
end

function XFC.Link:IsActive(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isActive = inBoolean
    end    
    return self.isActive
end
--#endregion

--#region Methods
function XFC.Link:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  isActive (' .. type(self.isActive) .. '): ' .. tostring(self.isActive))
    XF:Debug(self:ObjectName(), '  lastUpdatedTime (' .. type(self.lastUpdatedTime) .. '): ' .. tostring(self.lastUpdatedTime))
    if(self:HasFrom()) then self:From():Print() end
    if(self:HasTo()) then self:To():Print() end
end

function XFC.Link:HasFrom()
    return self.from ~= nil
end

function XFC.Link:HasTo()
    return self.to ~= nil
end

function XFC.Link:IsMyLink()
    return (self:HasFrom() and self:From():IsPlayer()) or (self:HasTo() and self:To():IsPlayer())
end

function XFC.Link:Serialize()
    return self:GetFromNode():Serialize() .. ';' .. self:GetToNode():Serialize()
end

function XFC.Link:Deserialize(inSerialized)
    assert(type(inSerialized) == 'string')

    local _Nodes = string.Split(inSerialized, ';')
    self:SetFromNode(GetNode(_Nodes[1]))
    self:SetToNode(GetNode(_Nodes[2]))

    self:Initialize()
end
--#endregion