local XF, G = unpack(select(2, ...))
local ObjectName = 'Channel'
local SetChatColor = ChangeChatColor

Channel = Object:newChildConstructor()

--#region Constructors
function Channel:new()
    local object = Channel.parent.new(self)
    object.__name = 'Channel'
    object.password = nil
    object.community = false
    return object
end
--#endregion

--#region Print
function Channel:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  community (' .. type(self.community) .. '): ' .. tostring(self.community))
end
--#endregion

--#region Accessors
function Channel:GetPassword()
    return self.password
end

function Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self.password = inPassword
end

function Channel:IsCommunity(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.community = inBoolean
    end
    return self.community
end

function Channel:SetColor()
    if(XF.Config.Channels[self:GetName()] ~= nil) then
        local color = XF.Config.Channels[self:GetName()]
        SetChatColor('CHANNEL' .. self:GetID(), color.R, color.G, color.B)
        XF:Debug(ObjectName, 'Set channel [%s] RGB [%f:%f:%f]', self:GetName(), color.R, color.G, color.B)
    end
end
--#endregion