local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Region'

XFC.Region = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Region:new()
    local object = XFC.Region.parent.new(self)
    object.__name = ObjectName
    object.current = nil
    return object
end
--#endregion

--#region Properties
function XFC.Region:IsCurrent()
    if(self.current == nil) then
        self.current = self:ID() == XFF.RegionGetCurrent()
    end
    return self.current
end
--#endregion

--#region Methods
function XFC.Region:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  current (' .. type(self.current) .. '): ' .. tostring(self.current))
end
--#endregion