local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config'

Config = Object:newChildConstructor()

function Config:new()
    local object = Config.parent.new(self)
    object.__name = ObjectName
    object.value = nil
    return object
end

function Config:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  value (' .. type(self.value) .. '): ' .. tostring(self.value))
    end
end

function Config:GetValue()
    return self.value
end

function Config:SetValue(inValue)
    self.value = inValue
end

function Config:GetLabel()
    return self:GetKey()
end

function Config:SetLabel(inLabel)
    self:SetKey(inLabel)
end