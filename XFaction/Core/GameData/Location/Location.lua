local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Location'

XFC.Location = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Location:new()
    local object = XFC.Location.parent.new(self)
    object.__name = ObjectName
    object.parentID = 0
    object.type = XF.Enum.Location.Unknown
    return object
end
--#endregion

--#region Properties
function XFC.Location:ParentID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(inID ~=  nil) then
        self.parentID = inID
    end
    return self.parentID
end

function XFC.Location:Type(inType)
    assert(type(inType) == 'number' or inID == nil)
    if(inType ~=  nil) then
        self.type = inType
    end
    return self.type
end
--#endregion

--#region Methods
function XFC.Location:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  parentID (' .. type(self.parentID) .. '): ' .. tostring(self.parentID))
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
end

function XFC.Location:Serialize()
    if(self:ID() ~= nil) then
        return self:ID()
    end
    return self:Key()
end
--#endregion