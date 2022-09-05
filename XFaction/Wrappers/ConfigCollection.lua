local XFG, G = unpack(select(2, ...))
local ObjectName = 'ConfigCollection'

ConfigCollection = ObjectCollection:newChildConstructor()

function ConfigCollection:new()
    local object = ConfigCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function ConfigCollection:Add(inLabel, inValue)
    local config = Config:new()
    config:Initialize()
    config:SetKey(inLabel)
    config:SetName(inLabel)
    config:SetValue(inValue)
    self.parent.Add(self, config)
end