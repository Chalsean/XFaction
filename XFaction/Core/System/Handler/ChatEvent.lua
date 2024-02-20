local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ChatEvent'

XFC.ChatEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.ChatEvent:new()
    local object = XFC.ChatEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ChatEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({name = 'GuildChat', 
                        event = 'CHAT_MSG_GUILD', 
                        callback = XFO.ChatEvent.CallbackGuildMessage, 
                        instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function XFC.ChatEvent:CallbackGuildMessage(inText, _, _, _, _, _, _, _, _, _, _, inSenderGUID)
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.Unit:GetGUID() == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = XFO.Chat:Pop()
                message:Initialize()
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.GCHAT)
                message:SetData(inText)
                XFO.Chat:Send(message, true)
            end).
            finally(function ()
                XFO.Chat:Push(message)
            end)
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)
end
--#endregion