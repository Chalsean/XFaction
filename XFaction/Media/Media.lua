local XFG, G = unpack(select(2, ...))
local ObjectName = 'Media'

Media = Object:newChildConstructor()

function Media:new()
    local object = Media.parent.new(self)
    object.__name = ObjectName
    object.type = nil
    object.path = nil
    return object
end

function Media:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
        XFG:Debug(ObjectName, '  path (' .. type(self.path) .. '): ' .. tostring(self.path))
    end
end

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
    return format('%s', format(XFG.Icons.Texture, self:GetPath()))
end