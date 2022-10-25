local XFG, G = unpack(select(2, ...))
local ObjectName = 'Class'

Class = Object:newChildConstructor()

--#region Constructors
function Class:new()
    local object = Class.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.apiName = nil
    object.r = nil
    object.g = nil
    object.b = nil
    object.hex = nil
    return object
end
--#endregion

--#region Print
function Class:Print()
    if(XFG.Verbosity) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
        XFG:Debug(ObjectName, '  r (' .. type(self.r) .. '): ' .. tostring(self.r))
        XFG:Debug(ObjectName, '  g (' .. type(self.g) .. '): ' .. tostring(self.g))
        XFG:Debug(ObjectName, '  b (' .. type(self.b) .. '): ' .. tostring(self.b))
        XFG:Debug(ObjectName, '  hex (' .. type(self.hex) .. '): ' .. tostring(self.hex))
    end
end
--#endregion

--#region Accessors
function Class:GetID()
    return self.ID
end

function Class:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Class:GetAPIName()
    return self.apiName
end

function Class:SetAPIName(inAPIName)
    assert(type(inAPIName) == 'string')
    self.apiName = inAPIName
end

function Class:GetRGB()
    return self.r, self.g, self.b
end

function Class:GetRGBPercent()
    return self.r / 255, self.g / 255, self.b / 255
end

function Class:SetRGB(inR, inG, inB)
    assert(type(inR) == 'number')
    assert(type(inG) == 'number')
    assert(type(inB) == 'number')
    self.r = inR
    self.g = inG
    self.b = inB
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self.hex = inHex
end

function Class:GetHex()
    return self.hex
end
--#endregion