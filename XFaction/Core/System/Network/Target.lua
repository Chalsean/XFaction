local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Target'

XFC.Target = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Target:new()
    local object = XFC.Target.parent.new(self)
    object.__name = ObjectName
    object.guild = nil
    object.chatRecipients = nil
    object.chatCount = 0
    return object
end

function XFC.Target:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.chatRecipients = {}
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Target:Guild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild' or inGuild == nil)
    if(inGuild ~= nil) then
        self.guild = inGuild
    end
    return self.guild
end

function XFC.Target:ChatCount(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.chatCount = self.chatCount + inCount
    end    
    return self.chatCount
end
--#endregion

--#region Methods
function XFC.Target:Print()
    self:ParentPrint()
    if(self:HasGuild()) then self:Guild():Print() end
    XF:DataDumper(self:ObjectName(), self.chatRecipients)
end

function XFC.Target:HasGuild()
    return self.guild ~= nil
end

function XFC.Target:IsMyTarget()
    return XF.Player.Target:Equals(self)
end

function XFC.Target:Serialize()
    return self:Key()
end

function XFC.Target:Deserialize(inSerial)
    assert(type(inSerial) == 'string')
    if(XFO.Guilds:Contains(inSerial)) then
        local guild = XFO.Guilds:Get(inSerial)
        self:Guild(guild)
        self:Key(guild:Key())
        self:Name(guild:Name())
    end
end

function XFC.Target:ChatRecipient(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(inUnit:IsPlayer()) then return end
    if(inUnit:CanChat()) then
        if(self.chatRecipients[inUnit:Key()] == nil) then
            self:ChatCount(1)
            self.chatRecipients[inUnit:Key()] = true
        end
    elseif(self.chatRecipients[inUnit:Key()] ~= nil) then
        self:ChatCount(-1)
        self.chatRecipients[inUnit:Key()] = nil
    end
    XFO.DTLinks:RefreshBroker()
end

function XFC.Target:UseChatProtocol()
    return self:ChatCount() > 0
end
--#endregion