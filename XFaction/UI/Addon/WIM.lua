local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'WIM'

XFC.WIM = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.WIM:new()
    local object = XFC.WIM.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.WIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.WIM:API(WIM)        
        XFO.WIM:IsLoaded(true)
        XF:Info(self:ObjectName(), 'WIM loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.WIM:AddMessage(inUnit, inText)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(self:IsInitialized() and XFO.WIM:API().modules.GuildChat.enabled) then
        try(function()
            XFO.WIM:API():CHAT_MSG_GUILD(inText, inUnit:UnitName(), XF.Player.Faction():Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
        end).
        catch(function(err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
end
--#endregion