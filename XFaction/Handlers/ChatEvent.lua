local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatEvent'

ChatEvent = Object:newChildConstructor()

--#region Constructors
function ChatEvent:new()
    local object = ChatEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function ChatEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add({name = 'GuildChat', 
                        event = 'CHAT_MSG_GUILD', 
                        callback = XFG.Handlers.ChatEvent.CallbackGuildMessage, 
                        instance = true,
                        start = false})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XFG.Player.GUID == inSenderGUID and XFG.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = XFG.Mailbox.Chat:Pop()
                message:Initialize()
                message:SetFrom(XFG.Player.Unit:GetGUID())
                message:SetType(XFG.Settings.Network.Type.BROADCAST)
                message:SetSubject(XFG.Settings.Network.Message.Subject.GCHAT)
                message:SetName(XFG.Player.Unit:GetName())
                message:SetUnitName(XFG.Player.Unit:GetUnitName())
                message:SetGuild(XFG.Player.Guild)
                message:SetRealm(XFG.Player.Realm)
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    message:SetMainName(XFG.Player.Unit:GetMainName())
                end
                message:SetData(inText)
                XFG.Mailbox.Chat:Send(message, true)
            end).
            finally(function ()
                XFG.Mailbox.Chat:Push(message)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion