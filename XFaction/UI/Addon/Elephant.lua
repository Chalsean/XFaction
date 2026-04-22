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
function XFC.Elephant:AddMessage(inUnit, inEvent, inText)
    if(self:IsInitialized()) then
        try(function()
            local elephant = {
                time = time(),
                arg1 = inText,
                arg2 = inUnit:UnitName(),
                arg6 = '',
                arg9 = XFO.Channels:Get('GUILD'):Name(),
                clColor = 'ff' .. inUnit():Class():Hex()
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