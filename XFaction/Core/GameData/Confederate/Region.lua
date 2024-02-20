local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Region'

XFC.Region = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Region:new()
    local object = XFC.Region.parent.new(self)
    object.__name = ObjectName
    object.current = false
    return object
end
--#endregion

--#region Print
function XFC.Region:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  current (' .. type(self.current) .. '): ' .. tostring(self.current))
end
--#endregion

--#region Accessors
function XFC.Region:IsCurrent(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.current = inBoolean
    end
    return self.current
end
--#endregion