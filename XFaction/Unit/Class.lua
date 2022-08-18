local XFG, G = unpack(select(2, ...))
local ObjectName = 'Class'

Class = Object:newChildConstructor()

function Class:new()
    local _Object = Class.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil
    _Object._APIName = nil
    _Object._R = nil
    _Object._G = nil
    _Object._B = nil
    _Object._Hex = nil
    return _Object
end

function Class:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
        XFG:Debug(ObjectName, '  _R (' .. type(self._R) .. '): ' .. tostring(self._R))
        XFG:Debug(ObjectName, '  _G (' .. type(self._G) .. '): ' .. tostring(self._G))
        XFG:Debug(ObjectName, '  _B (' .. type(self._B) .. '): ' .. tostring(self._B))
        XFG:Debug(ObjectName, '  _Hex (' .. type(self._Hex) .. '): ' .. tostring(self._Hex))
    end
end

function Class:GetID()
    return self._ID
end

function Class:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
end

function Class:GetAPIName()
    return self._APIName
end

function Class:SetAPIName(inAPIName)
    assert(type(inAPIName) == 'string')
    self._APIName = inAPIName
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
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self._Hex = inHex
end

function Class:GetHex()
    return self._Hex
end