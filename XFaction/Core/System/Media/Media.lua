local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Media'

Media = XFC.Object:newChildConstructor()

--#region Constructors
function Media:new()
    local object = Media.parent.new(self)
    object.__name = ObjectName
    object.type = nil
    object.path = nil
    return object
end
--#endregion

--#region Print
function Media:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(ObjectName, '  path (' .. type(self.path) .. '): ' .. tostring(self.path))
end
--#endregion

--#region Accessors
function Media:GetType()
    return self.type
end

function Media:SetType(inType)
    assert(type(inType) == 'string')
    self.type = inType
end

function Media:GetPath()
    return self.path
end

function Media:SetPath(inPath)
    assert(type(inPath) == 'string')
    self.path = inPath
end

function Media:GetTexture()
    return format('%s', format(XF.Icons.Texture, self:GetPath()))
end
--#endregion