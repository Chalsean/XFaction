local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Channel'

XFC.Channel = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Channel:new()
    local object = XFC.Channel.parent.new(self)
    object.__name = ObjectName
    object.password = nil
    object.community = false
    return object
end
--#endregion

--#region Print
function XFC.Channel:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  community (' .. type(self.community) .. '): ' .. tostring(self.community))
end
--#endregion

--#region Accessors
function XFC.Channel:GetPassword()
    return self.password
end

function XFC.Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self.password = inPassword
end

function XFC.Channel:IsCommunity(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.community = inBoolean
    end
    return self.community
end

function XFC.Channel:SetColor()
    if(XF.Config.Channels[self:GetName()] ~= nil) then
        local color = XF.Config.Channels[self:GetName()]
        XFF.ChatSetChannelColor('CHANNEL' .. self:GetID(), color.R, color.G, color.B)
        XF:Debug(self:GetObjectName(), 'Set channel [%s] RGB [%f:%f:%f]', self:GetName(), color.R, color.G, color.B)
    end
end
--#endregion