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

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    assert(type(inMessageTag) == 'string')

    try(function()
        -- Is a newer version available?
        if(not XF.Cache.NewVersionNotify and XF.Version:IsNewer(inMessage:GetVersion())) then
            print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
            XF.Cache.NewVersionNotify = true
        end

        -- Deserialize unit data
        if(inMessage:HasUnitData()) then
            local unitData = XF:DeserializeUnitData(inMessage:Data())
            inMessage:Data(unitData)
            if(not unitData:HasVersion()) then
                unitData:SetVersion(inMessage:GetVersion())
            end
        end

        self:Add(inMessage:Key())
        inMessage:Print()
        self:Forward(inMessage)

        -- Process GCHAT message
        if(inMessage:Subject() == XF.Enum.Message.GCHAT) then
            XFO.ChatFrame:DisplayGuildChat(inMessage)
            return
        end

        -- Process ACHIEVEMENT message
        if(inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT) then
            XFO.ChatFrame:DisplayAchievement(inMessage)
            return
        end

        -- Process LINK message
        if(inMessage:Subject() == XF.Enum.Message.LINK) then
            XF.Links:ProcessMessage(inMessage)
            return
        end

        -- Process LOGOUT message
        if(inMessage:Subject() == XF.Enum.Message.LOGOUT) then
            if(XF.Player.Guild:Equals(inMessage:GetGuild())) then
                -- In case we get a message before scan
                if(not XFO.Confederate:Contains(inMessage:From())) then
                    XF.Frames.System:DisplayLogoutMessage(inMessage)
                else
                    if(XFO.Confederate:Get(inMessage:From()):IsOnline()) then
                        XF.Frames.System:DisplayLogoutMessage(inMessage)
                    end
                    XFO.Confederate:OfflineUnit(inMessage:From())
                end
            else
                XF.Frames.System:DisplayLogoutMessage(inMessage)
                XFO.Confederate:Remove(inMessage:From())
            end
            XF.DataText.Guild:RefreshBroker()
            return
        end

        -- Process ORDER message
        if(inMessage:Subject() == XF.Enum.Message.ORDER) then
            XFO.Orders:ProcessMessage(inMessage)
            return
        end

        -- Process DATA/LOGIN message
        if(inMessage:HasUnitData()) then
            local unitData = inMessage:Data()
            if(inMessage:Subject() == XF.Enum.Message.LOGIN and 
            (not XFO.Confederate:Contains(unitData:Key()) or XFO.Confederate:Get(unitData:Key()):IsOffline())) then
                XF.Frames.System:DisplayLoginMessage(inMessage)
            end
            XFO.Confederate:Add(unitData)
            XF:Info(self:ObjectName(), 'Updated unit [%s] information based on message received', unitData:UnitName())
            XF.DataText.Guild:RefreshBroker()
        end
    end).
    finally(function()
        self:Push(inMessage)
    end)
end

function XFC.Mailbox:Forward(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        local nodeCount = XF.Nodes:GetTarCount(XF.Player.Target)
        if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
            local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
            if(math.random(1, 100) <= percentage) then
                XF:Debug(self:ObjectName(), 'Randomly selected, forwarding message')
                inMessage:Type(XF.Enum.Network.BNET)
                XFO.BNet:Send(inMessage)
            else
                XF:Debug(self:ObjectName(), 'Not randomly selected, will not forward mesesage')
            end
        else
            XF:Debug(self:ObjectName(), 'Node count under threshold, forwarding message')
            inMessage:Type(XF.Enum.Network.BNET)
            XFO.BNet:Send(inMessage)
        end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XF.Enum.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:Type(XF.Enum.Network.BROADCAST)
        else
            inMessage:Type(XF.Enum.Network.LOCAL)
        end
        XFO.Chat:Send(inMessage)
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
--#endregion