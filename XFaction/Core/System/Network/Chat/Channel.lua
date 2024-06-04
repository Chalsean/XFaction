local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Channel'

XFC.Channel = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Channel:new()
    local object = XFC.Channel.parent.new(self)
    object.__name = ObjectName
    object.password = nil
    object.isCommunity = false
    return object
end
--#endregion

--#region Properties
function XFC.Channel:Password(inPassword)
    assert(type(inPassword) == 'string' or inPassword == nil)
    if(inPassword ~= nil) then
        self.password = inPassword
    end
    return self.password
end

function XFC.Channel:IsCommunity(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isCommunity = inBoolean
    end
    return self.isCommunity
end
--#endregion

--#region Methods
function XFC.Channel:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  isCommunity (' .. type(self.isCommunity) .. '): ' .. tostring(self.isCommunity))
end

function XFC.Channel:IsGuild(inBoolean)
    return self:Name() == 'GUILD'
end

function XFC.Channel:SetColor()
    if(not self:IsGuild() and XF.Config.Channels[self:Name()] ~= nil) then
        local color = XF.Config.Channels[self:Name()]
        XFF.ChatSetChannelColor('CHANNEL' .. self:ID(), color.R, color.G, color.B)
        XF:Debug(self:ObjectName(), 'Set channel [%s] RGB [%f:%f:%f]', self:Name(), color.R, color.G, color.B)
    end
end
--#endregion