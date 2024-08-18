local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Mailbox'

XFC.Mailbox = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Mailbox:new()
    local object = XFC.Mailbox.parent.new(self)
	object.__name = ObjectName
	return object
end

function XFC.Mailbox:NewObject()
	return XFC.Message:new()
end

function XFC.Mailbox:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        XFO.Timers:Add({
            name = 'Mailbox', 
            delta = XF.Settings.Network.Mailbox.Scan, 
            callback = XFO.Mailbox.CallbackJanitor, 
            repeater = true
        })

        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
function XFC.Mailbox:Add(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		self.objects[inKey] = XFF.TimeCurrent()
	end
end

function XFC.Mailbox:Process(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    -- Forward message to any remaining targets
    self:Send(inMessage)

    XFO.Confederate:ProcessMessage(inMessage)

    if(inMessage:IsGuildChatMessage() or inMessage:IsAchievementMessage()) then
        XFO.ChatFrame:ProcessMessage(inMessage)
    elseif(inMessage:IsOrderMessage()) then
        XFO.Orders:ProcessMessage(inMessage)
    end
    
    if(inMessage:IsBNetProtocol()) then
        XFO.Friends:ProcessMessage(inMessage)
    elseif(inMessage:IsChannelProtocol()) then
        inMessage:FromUnit():Target():Add(inMessage:FromUnit())
    end
    XFO.DTLinks:RefreshBroker()
end

function XFC.Mailbox:CallbackJanitor()
	local self = XFO.Mailbox
    local epoch = XFF.TimeCurrent() - XF.Settings.Network.Mailbox.Stale

	for key, receivedTime in self:Iterator() do
		if(receivedTime < epoch) then
			self:Remove(key)
		end
	end
end

function XFC.Mailbox:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    self:Add(inMessage:Key())
    inMessage:Print()

    -- Own messages get shotgunned
    if(inMessage:IsMyMessage()) then
        inMessage:Remove(XF.Player.Target:Key())
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
        XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
        for _, friend in XFO.Friends:Iterator() do
            XFO.BNet:Whisper(inMessage, friend)
        end
    -- Forwarding logic
    else
        if(inMessage:Contains(XF.Player.Target:Key())) then
            inMessage:Remove(XF.Player.Target:Key())
            XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
        end
        
        if(inMessage:Count() > 0) then
            XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())

            local coverage = {}
            for _, target in inMessage:Iterator() do
                coverage[target:Key()] = target:Count()
            end

            -- Leverage BNet to cover remaining targets
            for _, friend in XFO.Friends:RandomIterator() do
                if(friend:HasUnit()) then
                    local target = friend:Unit():Target()
                    if(inMessage:Contains(target:Key()) and coverage[target:Key()] < 3) then
                        XFO.BNet:Whisper(inMessage, friend)
                        coverage[target:Key()] = coverage[target:Key()] + 1
                    end
                end
            end
        end
    end
end

-- Do not initiliaze message as we do not need unit/link data
-- Since we are logging out, dont care about memory leak
function XFC.Mailbox:SendLogoutMessage()
    local message = self:Pop()
    message:From(XF.Player.GUID)
    message:TimeStamp(XFF.TimeCurrent())
    message:Subject(XF.Enum.Message.LOGOUT)
    message:Priority(XF.Enum.Priority.High)

    for _, target in XFO.Targets:Iterator() do
        if(not target:Equals(XF.Player.Target)) then
            message:Add(target)
        end
    end
    
    self:Send(message)
end

local function SendMessage(inSubject, inPriority, inData)
    local self = XFO.Mailbox
    XF.Player.LastBroadcast = XFF.TimeCurrent()

    local message = nil
    try(function ()
        message = self:Pop()
        message:Initialize()
        message:Subject(inSubject)
        message:Priority(inPriority)
        message:Data(inData)
        self:Send(message)
    end).
    finally(function ()
        self:Push(message)
    end)
end

function XFC.Mailbox:SendLoginMessage()
    SendMessage(XF.Enum.Message.LOGIN, XF.Enum.Priority.Medium)
end

function XFC.Mailbox:SendDataMessage()
    SendMessage(XF.Enum.Message.DATA, XF.Enum.Priority.Low) 
end

function XFC.Mailbox:SendGuildChatMessage(inData)
    SendMessage(XF.Enum.Message.GCHAT, XF.Enum.Priority.High, inData)
end

function XFC.Mailbox:SendAchievementMessage(inData)
    SendMessage(XF.Enum.Message.ACHIEVEMENT, XF.Enum.Priority.Medium, inData)
end

function XFC.Mailbox:SendOrderMessage(inData)
    SendMessage(XF.Enum.Message.ORDER, XF.Enum.Priority.Medium, inData)
end

function XFC.Mailbox:SendAckMessage(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
    local message = nil
    try(function ()
        message = self:Pop()
        message:Initialize()
        message:RemoveAll()
        message:Subject(XF.Enum.Message.ACK)
        message:Priority(XF.Enum.Priority.Low)
        XFO.BNet:Whisper(message, inFriend)
    end).
    finally(function ()
        self:Push(message)
    end)
end
--#endregion