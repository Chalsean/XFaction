local XFG, G = unpack(select(2, ...))
local ObjectName = 'Channel'

Channel = Object:newChildConstructor()

--#region Constructors
function Channel:new()
    local object = Channel.parent.new(self)
    object.__name = 'Channel'
    object.ID = nil
    object.password = nil
    object.type = XFG.Enum.Channel.CUSTOM
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

function Channel:SetType(inType)
    assert(type(inType) == 'number')
    self.type = inType
end

function Channel:IsGuild(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean == true) then
        self.type = XFG.Enum.Channel.GUILD
    end
    return self.type == XFG.Enum.Channel.GUILD
end

function Channel:IsCommunity(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean == true) then
        self.type = XFG.Enum.Channel.COMMUNITY
    end
    return self.type == XFG.Enum.Channel.COMMUNITY
end
--#endregion