local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Realm'

XFC.Realm = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Realm:new()
    local object = XFC.Realm.parent.new(self)
    object.__name = ObjectName
    object.parentID = 0
    object.region = nil
    object.expansion = nil
    return object
end
--#endregion

--#region Properties
function XFC.Realm:ParentID(inParentID)
    assert(type(inParentID) == 'number' or inParentID == nil)
    if(inParentID ~= nil) then
        self.parentID = inParentID
    end
    return self.parentID
end

function XFC.Realm:Region(inRegion)
    assert(type(inRegion) == 'table' and inRegion.__name == 'Region' or inRegion == nil)
    if(inRegion ~= nil) then
        self.region = inRegion
    end
    return self.region
end

function XFC.Realm:Expansion(inExansion)
    assert(type(inExansion) == 'table' and inExansion.__name == 'Expansion' or inExansion == nil)
    if(inExansion ~= nil) then
        self.expansion = inExansion
    end
    return self.expansion
end
--#endregion

--#region Methods
function XFC.Realm:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  parentID (' .. type(self.parentID) .. '): ' .. tostring(self.parentID))
    if(self:HasRegion()) then self:Region():Print() end
    if(self:HasExpansion()) then self:Expansion():Print() end
end

function XFC.Realm:APIName()
    return string.gsub(self:Name(), "%s+", "")
end

function XFC.Realm:HasRegion()
    return self:Region() ~= nil
end

function XFC.Realm:HasExpansion()
    return self:Expansion() ~= nil
end

function XFC.Realm:Equals(inRealm)
    if(inRealm == nil) then return false end
    if(type(inRealm) ~= 'table' or inRealm.__name == nil) then return false end
    if(self:ObjectName() ~= inRealm:ObjectName()) then return false end
    if(self:Key() == inRealm:Key()) then return true end
    -- Consider connected realms equal
    if(self:ParentID() == inRealm:ParentID()) then return true end
    return false
end

function XFC.Realm:Serialize()
    return self:ID()
end
--#endregion