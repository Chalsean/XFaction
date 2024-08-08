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

    try(function()

        -- Forward message to any remaining targets
        XFO.PostOffice:Send(inMessage)

        -- Every message contains unit and link information, except LOGOUT
        XFO.Confederate:ProcessMessage(inMessage)
        XFO.Links:ProcessMessage(inMessage)

        if(inMessage:Subject() == XF.Enum.Message.LOGIN or inMessage:Subject() == XF.Enum.Message.LOGOUT or inMessage:Subject() == XF.Enum.Message.DATA) then
            return
        end

        -- Process GCHAT/ACHIEVEMENT message
        if(inMessage:Subject() == XF.Enum.Message.GCHAT or inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT) then
            XFO.ChatFrame:ProcessMessage(inMessage)
            return
        end

        -- Process ORDER message
        if(inMessage:Subject() == XF.Enum.Message.ORDER) then
            XFO.Orders:ProcessMessage(inMessage)
            return
        end        
    end).
    finally(function()
        self:Push(inMessage)
    end)
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

local function GetFactionRecipient(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target')

    local keys = {}
    for _, unit in XFO.Confederate:Iterator() do
        if(unit:Target():Equals(inTarget)) then
            -- Same realm/faction means chat channel broadcast
            if(unit:IsSameFaction() and unit:IsSameRealm()) then
                return unit
            elseif(unit:IsSameFaction()) then
                table.insert(keys, unit:Key())
            end
        end
    end

    if(#keys == 0) then return end
    -- Randomly select someone to whisper
    return XFO.Confederate:Get(keys[math.random(#keys)])
end

function XFC.Mailbox:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    self:Add(inMessage:Key())

    -- Send message to GUILD channel
    if(inMessage:Contains(XF.Player.Target:Key())) then
        XFO.Chat:Broadcast(inMessage, XFO.Channels:GuildChannel())
        inMessage:Remove(XF.Player.Target:Key())
    end

    local hasBroadcast = false    
    for _, target in inMessage:Iterator() do
        local recipient = GetFactionRecipient(target)
        if(recipient ~= nil) then
            -- Send message to addon channel
            if(recipient:IsSameRealm() and recipient:IsSameFaction()) then
                if(not hasBroadcast) then
                    XFO.Chat:Broadcast(inMessage, XFO.Channels:LocalChannel())
                    hasBroadcast = true
                end
            -- Whisper players of same faction
            elseif(recipient:IsSameFaction()) then
                XFO.Chat:Whisper(inMessage, recipient)
            end
        else
            -- Whisper friends of opposite faction
            local friend = XFO.Friends:GetByTarget(target)
            if(friend ~= nil) then
                XFO.BNet:Whisper(inMessage, friend)
                inMessage:Remove(target:Key())
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

    for _, target in XFO.Targets:Iterator() do
        if(not target:Equals(XF.Player.Target)) then
            message:Add(target)
        end
    end
    
    self:Send(message)
end

local function SendMessage(inSubject, inData)

    XF.Player.LastBroadcast = XFF.TimeCurrent()

    local message = nil
    try(function ()
        message = self:Pop()
        message:Initialize()
        message:Subject(inSubject)
        message:Data(inData)
        self:Send(message)
    end).
    finally(function ()
        self:Push(message)
    end)
end

function XFC.Mailbox:SendLoginMessage()
    SendMessage(XF.Enum.Message.LOGIN)
end

function XFC.Mailbox:SendDataMessage()
    SendMessage(XF.Enum.Message.DATA)
end

function XFC.Mailbox:SendGuildChatMessage(inData)
    SendMessage(XF.Enum.Message.GCHAT, inData)
end

function XFC.Mailbox:SendAchievementMessage(inData)
    SendMessage(XF.Enum.Message.ACHIEVEMENT, inData)
end

function XFC.Mailbox:SendOrderMessage(inData)
    SendMessage(XF.Enum.Message.ORDER, inData)
end
--#endregion