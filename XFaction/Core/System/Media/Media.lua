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

--#region Print
function XFC.Media:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:GetObjectName(), '  path (' .. type(self.path) .. '): ' .. tostring(self.path))
end
--#endregion

--#region Accessors
function XFC.Media:GetType()
    return self.type
end

function XFC.Media:SetType(inType)
    assert(type(inType) == 'string')
    self.type = inType
end

function XFC.Media:GetPath()
    return self.path
end

function XFC.Media:SetPath(inPath)
    assert(type(inPath) == 'string')
    self.path = inPath
end

function XFC.Media:GetTexture()
    return format('%s', format(XF.Icons.Texture, self:GetPath()))
end
--#endregion