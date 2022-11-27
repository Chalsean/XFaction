local XFG, G = unpack(select(2, ...))
local ObjectName = 'WIM'

XFWIM = Addon:newChildConstructor()

--#region Constructors
function XFWIM:new()
    local object = XFWIM.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFWIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('WIM Load', XFG.Settings.Network.Message.IPC.ADDON_LOADED, XFG.Addons.WIM.CallbackAddonLoaded, true, true, true)
		self:IsInitialized(true)
	end
end

function XFWIM:CallbackAddonLoaded(inAddonName)
    if(inAddonName == ObjectName and not XFG.Addons.WIM:IsLoaded()) then
        XFG.Addons.WIM:SetAPI(WIM)        
        XFG.Addons.WIM:IsLoaded(true)
        XFG:Info(ObjectName, 'WIM loaded successfully')
    end
end
--#endregion