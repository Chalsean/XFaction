local XFG, G = unpack(select(2, ...))
local ObjectName = 'Media'

Media = Object:newChildConstructor()

function Media:new()
    local _Object = Media.parent.new(self)
    _Object.__name = ObjectName
    _Object._Type = nil
    _Object._Path = nil
    return _Object
end

function Media:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _Type (' .. type(self._Type) .. '): ' .. tostring(self._Type))
        XFG:Debug(ObjectName, '  _Path (' .. type(self._Path) .. '): ' .. tostring(self._Path))
    end
end

function Media:GetType()
    return self._Type
end

function Media:SetType(inType)
    assert(type(inType) == 'string')
    self._Type = inType
    return self:GetType()
end

function Media:GetPath()
    return self._Path
end

function Media:SetPath(inPath)
    assert(type(inPath) == 'string')
    self._Path = inPath
    return self:GetPath()
end

function Media:GetTexture()
    return format('%s', format(XFG.Icons.Texture, self:GetPath()))
end