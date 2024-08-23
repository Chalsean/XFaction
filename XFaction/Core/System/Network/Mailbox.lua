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

    -- Own messages get shotgunned
    if(inMessage:IsMyMessage()) then
        XF:Debug(self:ObjectName(), 'Own message, broadcasting')
        inMessage:Remove(XF.Player.Target:Key())
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
        XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
        for _, friend in XFO.Friends:Iterator() do
            if(friend:CanLink()) then
                friend:Print()
                XFO.BNet:Whisper(inMessage, friend)
            end
        end
        return
    end

    -- Forwarding logic
    local guild = false

    -- If you receive via BNet theres little redundancy so broadcast
    if(inMessage:Contains(XF.Player.Target:Key()) and inMessage:IsBNetProtocol()) then
        XF:Debug(self:ObjectName(), 'Received via BNet and guild is targeted')
        inMessage:Remove(XF.Player.Target:Key())
        guild = true
    -- If you received via Channel, do random selection
    elseif(inMessage:Contains(XF.Player.Target:Key()) and _RandomSelection(XFO.Channels:LocalChannel():Count())) then
        XF:Debug(self:ObjectName(), 'Received via channel, guild targeted and randomly selected')
        inMessage:Remove(XF.Player.Target:Key())
        guild = true
    -- If you received via Guild, then you dont need to rebroadcast to Guild
    end

    local coverage = {}
    for _, target in inMessage:Iterator() do
        coverage[target:Key()] = {}
    end

    -- Leverage BNet if you can, whispers dont count against cap
    for _, friend in XFO.Friends:RandomIterator() do
        if(friend:IsLinked() and friend:HasUnit()) then            
            local target = friend:Unit():Target()
            if(inMessage:Contains(target:Key()) and #coverage[target:Key()] < 2) then
                table.insert(coverage[target:Key()], friend)
            end
        end
    end
    -- Remove targets that we know are covered
    for target, friends in pairs(coverage) do
        if(#friends > 1) then
            inMessage:Remove(target)
        end
    end

    if(guild) then
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
    end
    
    for target, friends in pairs(coverage) do
        inMessage:Add(XFO.Targets:Get(target))
        for _, friend in ipairs(friends) do
            friend:Print()
            XF:Debug(self:ObjectName(), 'BNet whisper linked friends on target')
            XFO.BNet:Whisper(inMessage, friend)
        end
        if(#friends > 1) then
            inMessage:Remove(target)
        end
    end

    -- If you received the message via channel, theres no point in putting it back on it
    -- Otherwise randomly select who forwards
    if(not inMessage:IsChannelProtocol() and inMessage:Count() > 0 and _RandomSelection(XFO.Channels:LocalChannel():Count())) then
        XF:Debug(self:ObjectName(), 'Randomly selected to broadcast to chat')
        XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
    end
end

-- Do not initiliaze message as we do not need unit/link data
-- Since we are logging out, dont care about memory leak
function XFC.Mailbox:SendLogoutMessage()
    local message = XFC.Message:new()
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