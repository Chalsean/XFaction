local XFG, G = unpack(select(2, ...))
local ObjectName = 'Spec'

Spec = Object:newChildConstructor()

function Spec:new()
    local object = Spec.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.iconID = nil
    return object
end

function Spec:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    end
end

function Spec:GetID()
    return self.ID
end

function Spec:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Spec:GetIconID()
    return self.iconID
end

function Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end