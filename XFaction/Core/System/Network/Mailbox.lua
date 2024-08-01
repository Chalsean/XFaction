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

        XF.Timers:Add({
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

        self:Add(inMessage:Key())
        -- self:Forward(inMessage)

        -- -- Every message contains unit and link information, except LOGOUT
        -- XFO.Confederate:ProcessMessage(inMessage)
        -- XFO.Links:ProcessMessage(inMessage)

        -- if(inMessage:Subject() == XF.Enum.Message.LOGIN or inMessage:Subject() == XF.Enum.Message.LOGOUT or inMessage:Subject() == XF.Enum.Message.DATA) then
        --     return
        -- end

        -- -- Process GCHAT/ACHIEVEMENT message
        -- if(inMessage:Subject() == XF.Enum.Message.GCHAT or inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT) then
        --     XFO.ChatFrame:ProcessMessage(inMessage)
        --     return
        -- end

        -- -- Process ORDER message
        -- if(inMessage:Subject() == XF.Enum.Message.ORDER) then
        --     XFO.Orders:ProcessMessage(inMessage)
        --     return
        -- end
    end).
    finally(function()
        self:Push(inMessage)
    end)
end

function XFC.Mailbox:Forward(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    -- if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
    --     -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
    --     local nodeCount = XF.Nodes:GetTarCount(XF.Player.Target)
    --     if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
    --         local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
    --         if(math.random(1, 100) <= percentage) then
    --             XF:Debug(self:ObjectName(), 'Randomly selected, forwarding message')
    --             inMessage:Type(XF.Enum.Network.BNET)
    --             XFO.BNet:Send(inMessage)
    --         else
    --             XF:Debug(self:ObjectName(), 'Not randomly selected, will not forward mesesage')
    --         end
    --     else
    --         XF:Debug(self:ObjectName(), 'Node count under threshold, forwarding message')
    --         inMessage:Type(XF.Enum.Network.BNET)
    --         XFO.BNet:Send(inMessage)
    --     end

    -- -- If there are still BNet targets remaining and came via BNet, broadcast
    -- elseif(inMessageTag == XF.Enum.Tag.BNET) then
    --     if(inMessage:HasTargets()) then
    --         inMessage:Type(XF.Enum.Network.BROADCAST)
    --     else
    --         inMessage:Type(XF.Enum.Network.LOCAL)
    --     end
    --     XFO.Chat:Send(inMessage)
    -- end
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
    
    XFO.Chat:Send(message)
end

local function SendMessage(inSubject, inData)

    XF.Player.LastBroadcast = XFF.TimeCurrent()

    local message = nil
    try(function ()
        message = self:Pop()
        message:Initialize()
        message:Subject(inSubject)
        message:Data(inData)
        XFO.Chat:Send(message)
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
    SendMessage(XF.Enum.Message.DATA, inData)
end

function XFC.Mailbox:SendAchievementMessage(inData)
    SendMessage(XF.Enum.Message.ACHIEVEMENT, inData)
end

function XFC.Mailbox:SendOrderMessage(inData)
    SendMessage(XF.Enum.Message.ORDER, inData)
end
--#endregion