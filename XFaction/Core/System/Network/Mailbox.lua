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

    local guildBroadcast = inMessage:IsMyMessage()
    local chatBroadcast = inMessage:IsMyMessage()
    local removedTargets = ''

    -- Identify targets player will cover and remove from message
    -- so the next recipient knows they dont need to consider those targets
    if(inMessage:Contains(XF.Player.Target:Key())) then
        guildBroadcast = true
        inMessage:Remove(XF.Player.Target:Key())
        removedTargets = XF.Player.Guild:Initials()
    end
    
    for _, target in inMessage:Iterator() do
        if(target:UseChatProtocol()) then
            chatBroadcast = true
            -- Only remove target if theres redundancy
            if(target:ChatCount() > 1) then
                inMessage:Remove(target:Key())
                removedTargets = removedTargets .. target:Guild():Initials() .. ';'
            end
        end
    end
    XF:Debug(self:ObjectName(), 'Targets removed from message [%s]: %s', inMessage:Key(), removedTargets)

    -- Leverage messages as a ping but dont send double to them
    local whispered = {}
    if(inMessage:IsMyMessage()) then
        for _, friend in XFO.Friends:Iterator() do
            if(friend:CanLink() and not friend:IsLinked()) then
                XFO.BNet:Whisper(inMessage, friend)
                whispered[friend:Key()] = true
            end
        end
    end

    if(guildBroadcast) then
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
    end
    if(chatBroadcast) then
        XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
    end    

    -- Forwarding message, if remaining targets, switch to BNet
    if(inMessage:Count() > 0 and XFO.Friends:HasLinkedFriends()) then
        for _, target in inMessage:Iterator() do
            local friend = XFO.Friends:GetRandomRecipient(target)
            if(friend ~= nil and whispered[friend:Key()] == nil) then
                XFO.BNet:Whisper(inMessage, friend)
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