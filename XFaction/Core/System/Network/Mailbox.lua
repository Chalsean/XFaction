local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Mailbox'

XFC.Mailbox = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Mailbox:new()
    local object = XFC.Mailbox.parent.new(self)
	object.__name = ObjectName
	return object
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

local function _RandomSelection(inCount)
    assert(type(inCount) == 'number')
    if(inCount > 0) then
        local rand = math.random(1, inCount)
        return rand <= XF.Settings.Network.RandomSelection
    end
    return true
end

function XFC.Mailbox:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    self:Add(inMessage:Key())
    inMessage:Print()

    local targeted = inMessage:Contains(XF.Player.Target:Key())
    inMessage:Remove(XF.Player.Target:Key())

    -- Own messages get shotgunned
    if(inMessage:IsMyMessage()) then
        XF:Debug(self:ObjectName(), 'Own message, broadcasting')
        if(XF.Player.Guild:Count() > 0) then
            XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
        else
            XF:Debug(self:ObjectName(), 'No one online to broadcast to')
        end
        XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
        for _, friend in XFO.Friends:Iterator() do
            if(friend:CanLink()) then
                XFO.BNet:Whisper(inMessage, friend)
            end
        end
        return
    end

    -- Forwarding logic
    local guild = false
    if(XF.Player.Guild:Count() > 0 and targeted) then
        -- If you receive via BNet theres little redundancy so broadcast
        if(inMessage:IsBNetProtocol()) then
            XF:Debug(self:ObjectName(), 'Received via BNet and guild is targeted')
            guild = true
        -- If you received via Channel, do random selection
        elseif(_RandomSelection(XFO.Channels:LocalChannel():Count())) then
            XF:Debug(self:ObjectName(), 'Received via channel, guild targeted and randomly selected')
            guild = true
        else
            XF:Debug(self:ObjectName(), 'Not randomly selected to forward to guild')
        end
    elseif(XF.Player.Guild:Count() == 0) then
        XF:Debug(self:ObjectName(), 'No one online to broadcast to')
    else
        XF:Debug(self:ObjectName(), 'Guild is no longer targeted')
    end

    -- First figure out all targets bnet will cover
    local coverage = {}
    for _, friend in XFO.Friends:RandomIterator() do
        if(friend:IsLinked() and friend:HasUnit()) then                        
            local target = friend:Unit():Target()
            if(inMessage:Contains(target:Key()) and coverage[target:Key()] == nil) then
                XF:Debug(self:ObjectName(), 'Friend [%s] selected to cover target [%s]', friend:Tag(), target:Guild():Initials())
                coverage[target:Key()] = friend
            end
        end
    end

    -- Now remove all targets covered by bnet so they dont get forwarded again
    for target in pairs(coverage) do
        inMessage:Remove(target)
    end

    if(guild) then
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
    end

    -- Whisper bnet recipients
    for target, friend in pairs(coverage) do
        inMessage:Add(XFO.Targets:Get(target))
        XFO.BNet:Whisper(inMessage, friend)
        inMessage:Remove(target)
    end
    
    -- If you received the message via channel, theres no point in putting it back on it
    if(inMessage:Count() > 0) then
        local channel = false
        if(inMessage:IsBNetProtocol()) then
            channel = true
        elseif(inMessage:IsGuildProtocol() and _RandomSelection(XFO.Channels:LocalChannel():Count())) then
            channel = true
        end
        if(channel) then
            XF:Debug(self:ObjectName(), 'Forwarding to chat bus for remaining targets: %d', inMessage:Count())
            XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
        end
    end
end

function XFC.Mailbox:SendLogoutMessage()
    try(function()
        local key = math.GenerateUID()
        XFO.Chat:SendLogoutMessage(key, XFO.Channels:GuildChannel())
        XFO.Chat:SendLogoutMessage(key, XFO.Channels:LocalChannel())
        for _, friend in XFO.Friends:Iterator() do
            if(friend:IsLinked()) then
                XFO.BNet:SendLogoutMessage(key, friend)
            end
        end
    end).
    catch(function() end)
end

local function SendMessage(inSubject, inPriority, inData)
    local self = XFO.Mailbox
    XF.Player.LastBroadcast = XFF.TimeCurrent()

    try(function ()
        local message = XFC.Message:new()
        message:Initialize()
        message:Subject(inSubject)
        message:Priority(inPriority)
        message:Data(inData)
        self:Send(message)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
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
    try(function ()
        if(inFriend:CanLink()) then
            local message = XFC.Message:new()
            message:Initialize()
            message:RemoveAll()
            message:Subject(XF.Enum.Message.ACK)
            message:Priority(XF.Enum.Priority.Low)
            XFO.BNet:Whisper(message, inFriend)
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion