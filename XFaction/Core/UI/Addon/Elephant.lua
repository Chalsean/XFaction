local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Elephant'

XFC.Elephant = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.Elephant:new()
    local object = XFC.Elephant.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.Elephant:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Elephant:API(Elephant)        
        XFO.Elephant:IsLoaded(true)
        XF:Info(self:ObjectName(), 'Elephant loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.Elephant:AddMessage(inMessage, inEvent)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(self:IsInitialized()) then
        try(function()
            local text = XFO.ChatFrame:GetMessagePrefix(inEvent, inMessage:FromUnit())
            if(inEvent == 'CHAT_MSG_GUILD_ACHIEVEMENT') then
                text = text .. XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(XFF.PlayerAchievementLink(inMessage:Data()), "(Player.-:.-:.-:.-:.-:)"  , inMessage:From() .. ':1:' .. date("%m:%d:%y:") ) .. '!'
            else
                text = text .. inMessage:Data()
            end

            local elephant = {
                time = inMessage:TimeStamp(),
                arg1 = text,
                arg2 = inMessage:FromUnit():UnitName(),
                arg6 = '',
                arg9 = XFO.Channels:GuildChannel():Name(),
                clColor = 'ff' .. inMessage:FromUnit():Class():Hex()
            }
            for channel_index in pairs(self:API():ProfileDb().events[inEvent].channels) do
                if self:API():ProfileDb().events[inEvent].channels[channel_index] ~= 0 and self:API():LogsDb().logs[channel_index].enabled then
                    self:API():CaptureNewMessage(elephant, channel_index)
                end
            end
        end).
        catch(function(err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
end
--#endregion