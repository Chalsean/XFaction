local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Spec'

XFC.Spec = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Spec:new()
    local object = XFC.Spec.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.class = nil
    return object
end
--#endregion

--#region Properties
function XFC.Spec:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil)
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end

function XFC.Spec:Class(inClass)
    assert(type(inClass) == 'table' and inClass.__name == 'Class' or inClass == nil)
    if(inClass ~= nil) then
        self.class = inClass
    end
    return self.class
end
--#endregion

--#region Methods
function XFC.Spec:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    if(self:HasClass()) then self:Class():Print() end
end

function XFC.Spec:HasClass()
    return self.class ~= nil
end
--#endregion