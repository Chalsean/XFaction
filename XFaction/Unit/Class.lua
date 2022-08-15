local XFG, G = unpack(select(2, ...))

Class = Object:newChildConstructor()

function Class:new()
    local _Object = Class.parent.new(self)
    _Object.__name = 'Class'
    _Object._ID = nil
    _Object._APIName = nil
    _Object._R = nil
    _Object._G = nil
    _Object._B = nil
    _Object._Hex = nil
    return _Object
end

function Class:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(self:GetObjectName(), '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
    XFG:Debug(self:GetObjectName(), '  _R (' .. type(self._R) .. '): ' .. tostring(self._R))
    XFG:Debug(self:GetObjectName(), '  _G (' .. type(self._G) .. '): ' .. tostring(self._G))
    XFG:Debug(self:GetObjectName(), '  _B (' .. type(self._B) .. '): ' .. tostring(self._B))
    XFG:Debug(self:GetObjectName(), '  _Hex (' .. type(self._Hex) .. '): ' .. tostring(self._Hex))
end

function Class:GetID()
    return self._ID
end

function Class:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Class:GetAPIName()
    return self._APIName
end

function Class:SetAPIName(inAPIName)
    assert(type(inAPIName) == 'string')
    self._APIName = inAPIName
    return self:GetAPIName()
end

function Class:GetRGB()
    return self._R, self._G, self._B
end

function Class:GetRGBPercent()
    return self._R / 255, self._G / 255, self._B / 255
end

function Class:SetRGB(inR, inG, inB)
    assert(type(inR) == 'number')
    assert(type(inG) == 'number')
    assert(type(inB) == 'number')
    self._R = inR
    self._G = inG
    self._B = inB
    return self:GetRGB()
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self._Hex = inHex
    return self:GetHex()
end

function Class:GetHex()
    return self._Hex
end