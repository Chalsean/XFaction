local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Mailbox'

XFC.Mailbox = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Mailbox:new()
    local object = XFC.Mailbox.parent.new(self)
	object.__name = ObjectName
	object.objects = nil
    object.objectCount = 0   
    object.packets = nil
	return object
end

function XFC.Mailbox:NewObject()
	return XFC.Message:new()
end

function XFC.Mailbox:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

        XFO.Timers:Add({
            name = 'MailboxJanitor', 
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
		self.objects[inKey] = XFF.TimeGetCurrent()
	end
end

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    -- Is a newer version available?
    if(not XF.Cache.NewVersionNotify and inMessage:HasVersion() and XF.Version:IsNewer(inMessage:Version())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    inMessage:Print()

    --#region Process message
    -- LOGOUT message
    if(inMessage:IsLogout()) then
        XFO.Confederate:ProcessMessage(inMessage)        
        return
    end

    -- Legacy DATA/LOGIN message
    if(inMessage:IsLegacy() and (inMessage:IsLogin() or inMessage:IsData())) then
        XFO.Confederate:ProcessMessage(inMessage)
        return
    end

    -- Legacy LINK message
    if(inMessage:IsLink()) then
        XFO.Links:ProcessMessage(inMessage)
        return
    end

    -- All non-LOGOUT messages have unit and link data
    if(not inMessage:IsLegacy()) then
        XFO.Confederate:ProcessMessage(inMessage)
        if(inMessage:HasLinks()) then
            XFO.Links:ProcessMessage(inMessage)
        end
    end

    -- ACHIEVEMENT/GCHAT message
    if(inMessage:IsAchievement() or inMessage:IsGuildChat()) then
        XFO.ChatFrame:ProcessMessage(inMessage)
        return
    end    

    -- ORDER message
    if(inMessage:IsOrder()) then
        XFO.Orders:ProcessMessage(inMessage)
        return
    end
    --#endregion
end

function XFC.Mailbox:CallbackJanitor()
    local self = XFO.Mailbox
	for key, receivedTime in self:Iterator() do
		if(receivedTime < XFF.TimeGetCurrent() - XF.Settings.Network.Mailbox.Stale) then
			self:Remove(key)
		end
	end
end

local function _SendMessage(inSubject, inData)
    local self = XFO.Mailbox
    local message = self:Pop()
    try(function ()
        message:Initialize()
        message:Type(XF.Enum.Network.BROADCAST)
        message:Subject(inSubject)
        message:From(XF.Player.Unit:GUID())
        message:FromUnit(XF.Player.Unit)
        message:TimeStamp(XFF.TimeGetCurrent())
        message:SetAllTargets()
        message:Version(XF.Version)
        message:Faction(XF.Player.Faction)
        message:Guild(XF.Player.Guild)
        message:Links(XFO.Links:Serialize())
        message:Data(inData)
        XFO.PostOffice:Send(message)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end).
    finally(function ()
        self:Push(message)
    end)
end

function XFC.Mailbox:SendOrderMessage(inOrder)
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    XF:Info(self:ObjectName(), 'Sending order message')
    inOrder:Print()
    _SendMessage(XF.Enum.Message.ORDER, inOrder:Encode())
end

function XFC.Mailbox:SendDataMessage(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    XF:Info(self:ObjectName(), 'Sending data message for unit [%s]', inUnit:UnitName())
    _SendMessage(XF.Enum.Message.DATA, inUnit)
end

function XFC.Mailbox:SendLoginMessage(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    XF:Info(self:ObjectName(), 'Sending login message for unit [%s]', inUnit:UnitName())
    _SendMessage(XF.Enum.Message.LOGIN, inUnit)
end

function XFC.Mailbox:SendAchievementMessage(inID)
    assert(type(inID) == 'number')
    XF:Info(self:ObjectName(), 'Sending achievement message for [%d]', inID)
    _SendMessage(XF.Enum.Message.ACHIEVEMENT, inID)
end

function XFC.Mailbox:SendLogoutMessage()
    _SendMessage(XF.Enum.Message.LOGOUT, '')
end

-- Deprecated, remove after 4.13
function XFC.Mailbox:SendLinkMessage(inLinks)
    assert(type(inLinks) == 'string')
    XF:Info(self:ObjectName(), 'Sending links message')
    _SendMessage(XF.Enum.Message.LINK, inLinks)
end

function XFC.Mailbox:SendChatMessage(inText)
    assert(type(inText) == 'string')
    XF:Info(self:ObjectName(), 'Sending guild chat message [%s]', inText)
    _SendMessage(XF.Enum.Message.GCHAT, inText)
end
--#endregion