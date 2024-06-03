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

    self:Add(inMessage:Key())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessageTag == XF.Enum.Tag.LOCAL) then

        if(XFO.Friends:ContainsByGUID(inMessage:From())) then
            local friend = XFO.Friends:GetByGUID(inMessage:From())
            if(friend:CanLink() and not friend:IsLinked()) then
                XFO.BNet:Ping(friend)
            end
        end

        if(inMessage:HasTargets()) then
            -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
            -- local nodeCount = XF.Nodes:GetTargetCount(XF.Player.Target)
            -- if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
            --     local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
            --     if(math.random(1, 100) <= percentage) then
            --         XF:Debug(ObjectName, 'Randomly selected, forwarding message')
            --         inMessage:SetType(XF.Enum.Network.BNET)
            --         XF.Mailbox.BNet:Send(inMessage)
            --     else
            --         XF:Debug(ObjectName, 'Not randomly selected, will not forward mesesage')
            --     end
            -- else
            --     XF:Debug(ObjectName, 'Node count under threshold, forwarding message')
                inMessage:Type(XF.Enum.Network.BNET)
                XFO.BNet:Send(inMessage)
            -- end
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
    --#endregion

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
--#endregion