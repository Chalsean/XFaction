local XFG, G = unpack(select(2, ...))
local ObjectName = 'Class'

Class = Object:newChildConstructor()

function Class:new()
    local object = Class.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.apiName = nil
    object.color = nil
    return object
end

function Class:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
        if(self:HasColor()) then self:GetColor():Print() end
    end
end

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

function Class:HasColor()
    return self.color ~= nil
end

function Class:GetColor()
    return self.color
end

function Class:SetColor(inColor)
    assert(type(inColor) == 'table' and inColor.__name == 'Color', 'argument must be Color object')
    self.color = inColor
end