local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Media'

XFC.Media = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Media:new()
    local object = XFC.Media.parent.new(self)
    object.__name = ObjectName
    object.type = nil
    object.path = nil
    return object
end
--#endregion

--#region Properties
function XFC.Media:Type(inType)
    assert(type(inType) == 'string' or inType == nil, 'argument must be string or nil')
    if(inType ~= nil) then
        self.type = inType
    end
end

function XFC.Media:Path(inPath)
    assert(type(inPath) == 'string' or inPatch == nil, 'argument must be string or nil')
    if(inPatch ~= nil) then
        self.path = inPath
    end
    return self.path
end

function XFC.Media:Texture()
    return format('%s', format(XF.Icons.Texture, self:Path()))
end
--#endregion

--#region Methods
function XFC.Media:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  path (' .. type(self.path) .. '): ' .. tostring(self.path))
end
--#endregion