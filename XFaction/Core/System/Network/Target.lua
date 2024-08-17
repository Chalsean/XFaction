local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Target'

XFC.Target = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Target:new()
    local object = XFC.Target.parent.new(self)
    object.__name = ObjectName
    object.guild = nil
    object.chatOnlineCount = 0
    object.bnetOnlineCount = 0
    return object
end

function XFC.Target:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:IsMyTarget()) then
            self:ChatOnlineCount(-1)
        end
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

function XFC.Target:ChatOnlineCount(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.chatOnlineCount = self.chatOnlineCount + inCount
    end
    return self.chatOnlineCount
end

function XFC.Target:BNetOnlineCount(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.bnetOnlineCount = self.bnetOnlineCount + inCount
    end
    return self.bnetOnlineCount
end
--#endregion

--#region Methods
function XFC.Target:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  chatOnlineCount (' .. type(self.chatOnlineCount) .. '): ' .. tostring(self.chatOnlineCount))
    XF:Debug(self:ObjectName(), '  bnetOnlineCount (' .. type(self.bnetOnlineCount) .. '): ' .. tostring(self.bnetOnlineCount))
    if(self:HasGuild()) then self:Guild():Print() end
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

function XFC.Target:UseChatProtocol()
    return self:ChatOnlineCount() > 1
end

function XFC.Target:CalcChatOnline(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(inUnit:IsPlayer()) then return end
    if(not inUnit:IsSameFaction() or not inUnit:IsSameRealm()) then return end

    if(inUnit:IsOnline()) then
        self:ChatOnlineCount(1)
    else
        self:ChatOnlineCount(-1)
    end

    XFO.DTLinks:RefreshBroker()
end
--#endregion