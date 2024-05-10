local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChatEvent'

ChatEvent = XFC.Object:newChildConstructor()

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
        XF.Events:Add({name = 'GuildChat', 
                        event = 'CHAT_MSG_GUILD', 
                        callback = XF.Handlers.ChatEvent.CallbackGuildMessage, 
                        instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.GUID == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = XF.Mailbox.Chat:Pop()
                message:Initialize()
                message:SetFrom(XF.Player.Unit:GetGUID())
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.GCHAT)
                message:Name(XF.Player.Unit:Name())
                message:SetUnitName(XF.Player.Unit:GetUnitName())
                message:SetGuild(XF.Player.Guild)
                if(XF.Player.Unit:IsAlt() and XF.Player.Unit:HasMainName()) then
                    message:SetMainName(XF.Player.Unit:GetMainName())
                end
                message:SetData(inText)
                XF.Mailbox.Chat:Send(message, true)
            end).
            finally(function ()
                XF.Mailbox.Chat:Push(message)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion