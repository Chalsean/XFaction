local XFG, G = unpack(select(2, ...))
local ObjectName = 'Channel'

Channel = Object:newChildConstructor()

--#region Constructors
function Channel:new()
    local object = Channel.parent.new(self)
    object.__name = 'Channel'
    object.ID = nil
    object.password = nil
    object.type = Enum.PermanentChatChannelType.None
    return object
end
--#endregion

--#region Print
function Channel:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
end
--#endregion

--#region Accessors
function Channel:GetID()
    return self.ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Channel:GetPassword()
    return self.password
end

function Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self.password = inPassword
end

function Channel:GetType()
    return self.type
end

function Channel:SetType(inType)
    assert(type(inType) == 'number')
    self.type = inType
end

function Channel:IsUnknown()
    return self.type == Enum.PermanentChatChannelType.None
end

function Channel:IsCommunity()
    return self.type == Enum.PermanentChatChannelType.Communities
end

function Channel:IsCustom()
    return self.type == Enum.PermanentChatChannelType.Custom
end
--#endregion