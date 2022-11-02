local XFG, G = unpack(select(2, ...))
local ObjectName = 'Inbox'

Inbox = Object:newChildConstructor()

function Inbox:new()
    local _Object = Inbox.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function Inbox:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:Info(ObjectName, "Registering to receive [%s] messages", XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:RegisterComm(XFG.Settings.Network.Message.Tag.LOCAL, 
                         function(inMessageType, inMessage, inDistribution, inSender) 
                            XFG.Inbox:Receive(inMessageType, inMessage, inDistribution, inSender)
                         end)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

-- Channel and whisper traffic is received by this function
-- BNet traffic is in the BNet class
function Inbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, "Received message [%s] from [%s] on [%s]", inMessageTag, inSender, inDistribution)
    end

    -- If not a message from this addon, ignore
    local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(not _AddonTag) then
        return
    end

    local _Message = nil
    try(function ()
        _Message = XFG:DecodeMessage(inEncodedMessage)
        XFG:Debug(ObjectName, 'Decoded message successfully')
        XFG.Inbox:Process(_Message, inMessageTag)
        XFG.Metrics:Get(XFG.Settings.Metric.ChannelReceive):Increment()
        XFG.Metrics:Get(XFG.Settings.Metric.Messages):Increment()
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end).
    finally(function ()
        XFG.Mailbox:Push(_Message)
    end)
end

function Inbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")

    --========================================
    -- Ignore message
    --========================================

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than from Unit object
	if(inMessage:GetFrom() == XFG.Player.GUID) then
        return
	end

    -- Have you seen this message before?
    if(XFG.Mailbox:Contains(inMessage:GetKey())) then
        --XFG:Debug(LogCategory, "This message has already been processed %s", inMessage:GetKey())
        return
    else
        XFG.Mailbox:Add(inMessage)
    end

    -- Is a newer version available?
    if(not XFG.Cache.NewVersionNotify and XFG.Version:IsNewer(inMessage:GetVersion())) then
        print(format(XFG.Lib.Locale['NEW_VERSION'], XFG.Title))
        XFG.Cache.NewVersionNotify = true
    end

    -- Deserialize unit data
    if(inMessage:HasUnitData()) then
        local _UnitData = XFG:DeserializeUnitData(inMessage:GetData())
        inMessage:SetData(_UnitData)
        if(not _UnitData:HasVersion()) then
            _UnitData:SetVersion(inMessage:GetVersion())
        end
    end

    inMessage:ShallowPrint()

    --========================================
    -- Forward message
    --========================================

    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XFG.Settings.Network.Message.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        local _NodeCount = XFG.Nodes:GetTargetCount(XFG.Player.Target)
        if(_NodeCount > XFG.Settings.Network.BNet.Link.PercentStart) then
            local _Percentage = (XFG.Settings.Network.BNet.Link.PercentStart / _NodeCount) * 100
            if(math.random(1, 100) <= _Percentage) then
                XFG:Debug(ObjectName, 'Randomly selected, forwarding message')
                inMessage:SetType(XFG.Settings.Network.Type.BNET)
                XFG.Outbox:Send(inMessage)
            else
                XFG:Debug(ObjectName, 'Not randomly selected, will not forward mesesage')
            end
        else
            XFG:Debug(ObjectName, 'Node count under threshold, forwarding message')
            inMessage:SetType(XFG.Settings.Network.Type.BNET)
            XFG.Outbox:Send(inMessage)
        end        

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XFG.Settings.Network.Message.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
        else
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)
        end
        XFG.Outbox:Send(inMessage)
    end

    --========================================
    -- Process message
    --========================================

    -- Process GCHAT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.GCHAT) then
        if(XFG.Player.Unit:CanGuildListen() and not XFG.Player.Guild:Equals(inMessage:GetGuild())) then
            XFG.Frames.Chat:DisplayGuildChat(inMessage)
        end
        return
    end

    -- Process ACHIEVEMENT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
        XFG.Frames.Chat:DisplayAchievement(inMessage)
        return
    end

    -- Process LINK message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LINK) then
        XFG.Links:ProcessMessage(inMessage)
        return
    end

    -- Process LOGOUT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGOUT) then
        -- If own guild, GuildEvent will take care of logout        
        if(not XFG.Player.Guild:Equals(inMessage:GetGuild()) or
           not XFG.Player.Realm:Equals(inMessage:GetGuild():GetRealm()) or
           not XFG.Player.Faction:Equals(inMessage:GetGuild():GetFaction())) then            
            XFG.Confederate:Remove(inMessage:GetFrom())
            XFG.Frames.System:DisplayLogoutMessage(inMessage)
        end
        return
    end

    -- Process JOIN message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.JOIN) then
        --XFG.Frames.System:DisplayJoinMessage(inMessage)
        return
    end

    -- Process DATA/LOGIN message
    if(inMessage:HasUnitData()) then
        local _UnitData = inMessage:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:Add(_UnitData) and XFG.DebugFlag) then
            XFG:Info(ObjectName, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
            -- Display system message that unit has logged on
            if(not XFG.Player.Guild:Equals(_UnitData:GetGuild())) then
                XFG.Frames.System:DisplayLoginMessage(inMessage)
            end
        end
    end
end