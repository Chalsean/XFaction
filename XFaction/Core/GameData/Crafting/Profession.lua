local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Profession'

XFC.Profession = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Profession:new()
    local object = XFC.Profession.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    return object
end
--#endregion

--#region Properties
function XFC.Profession:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil)
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end
--#endregion

--#region Methods
function XFC.Profession:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion