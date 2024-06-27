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
	return Message:new()
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
    assert(type(inMessage) == 'table' and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    try(function()
        -- Is a newer version available?
        if(not XF.Cache.NewVersionNotify and XF.Version:IsNewer(inMessage:GetVersion())) then
            print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
            XF.Cache.NewVersionNotify = true
        end

        -- Deserialize unit data
        if(inMessage:HasUnitData()) then
            local unitData = XF:DeserializeUnitData(inMessage:GetData())
            inMessage:SetData(unitData)
            if(not unitData:HasVersion()) then
                unitData:SetVersion(inMessage:GetVersion())
            end
        end

        self:Add(inMessage:Key())
        inMessage:Print()

        --#region Forwarding
        -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
        if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
            -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
            local nodeCount = XF.Nodes:GetTarCount(XF.Player.Target)
            if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
                local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
                if(math.random(1, 100) <= percentage) then
                    XF:Debug(self:ObjectName(), 'Randomly selected, forwarding message')
                    inMessage:SetType(XF.Enum.Network.BNET)
                    XF.Mailbox.BNet:Send(inMessage)
                else
                    XF:Debug(self:ObjectName(), 'Not randomly selected, will not forward mesesage')
                end
            else
                XF:Debug(self:ObjectName(), 'Node count under threshold, forwarding message')
                inMessage:SetType(XF.Enum.Network.BNET)
                XF.Mailbox.BNet:Send(inMessage)
            end

        -- If there are still BNet targets remaining and came via BNet, broadcast
        elseif(inMessageTag == XF.Enum.Tag.BNET) then
            if(inMessage:HasTargets()) then
                inMessage:SetType(XF.Enum.Network.BROADCAST)
            else
                inMessage:SetType(XF.Enum.Network.LOCAL)
            end
            XF.Mailbox.Chat:Send(inMessage)
        end
        --#endregion

        --#region Process message
        -- Process GCHAT message
        if(inMessage:GetSubject() == XF.Enum.Message.GCHAT) then
            if(XF.Player.Unit:CanGuildListen() and not XF.Player.Guild:Equals(inMessage:GetGuild())) then
                XF.Frames.Chat:DisplayGuildChat(inMessage)
            end
            return
        end

        -- Process ACHIEVEMENT message
        if(inMessage:GetSubject() == XF.Enum.Message.ACHIEVEMENT) then
            -- Local guild achievements should already be displayed by WoW client
            if(not XF.Player.Guild:Equals(inMessage:GetGuild())) then
                XF.Frames.Chat:DisplayAchievement(inMessage)
            end
            return
        end

        -- Process LINK message
        if(inMessage:GetSubject() == XF.Enum.Message.LINK) then
            XF.Links:ProcessMessage(inMessage)
            return
        end

        -- Process LOGOUT message
        if(inMessage:GetSubject() == XF.Enum.Message.LOGOUT) then
            if(XF.Player.Guild:Equals(inMessage:GetGuild())) then
                -- In case we get a message before scan
                if(not XFO.Confederate:Contains(inMessage:GetFrom())) then
                    XF.Frames.System:DisplayLogoutMessage(inMessage)
                else
                    if(XFO.Confederate:Get(inMessage:GetFrom()):IsOnline()) then
                        XF.Frames.System:DisplayLogoutMessage(inMessage)
                    end
                    XFO.Confederate:OfflineUnit(inMessage:GetFrom())
                end
            else
                XF.Frames.System:DisplayLogoutMessage(inMessage)
                XFO.Confederate:Remove(inMessage:GetFrom())
            end
            XF.DataText.Guild:RefreshBroker()
            return
        end

        -- Process ORDER message
        if(inMessage:GetSubject() == XF.Enum.Message.ORDER) then
            local order = nil
            try(function ()
                order = XFO.Orders:Pop()
                order:Decode(inMessage:GetData())
                if(not XFO.Orders:Contains(order:Key())) then
                    XFO.Orders:Add(order)
                    order:Display()
                else
                    XFO.Orders:Push(order)
                end
            end).
            catch(function (inErrorMessage)
                XF:Warn(ObjectName, inErrorMessage)
                XFO.Orders:Push(order)
            end)
            return
        end

        -- Process DATA/LOGIN message
        if(inMessage:HasUnitData()) then
            local unitData = inMessage:GetData()
            if(inMessage:GetSubject() == XF.Enum.Message.LOGIN and 
            (not XFO.Confederate:Contains(unitData:Key()) or XFO.Confederate:Get(unitData:Key()):IsOffline())) then
                XF.Frames.System:DisplayLoginMessage(inMessage)
            end
            XFO.Confederate:Add(unitData)
            XF:Info(self:ObjectName(), 'Updated unit [%s] information based on message received', unitData:GetUnitName())
            XF.DataText.Guild:RefreshBroker()
        end
        --#endregion
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
--#endregion