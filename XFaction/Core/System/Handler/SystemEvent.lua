local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemEvent'

SystemEvent = XFC.Object:newChildConstructor()

--#region Constructors
function SystemEvent:new()
    local object = SystemEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()     
        -- Log any messages encountered during last logout
        for _, message in ipairs(XF.Config.Logout) do
            XF:Debug(ObjectName, '* Previous Logout: %s', message)
        end
        XF.Config.Logout = {}

        XFO.Hooks:Add({
            name = 'ReloadUI', 
            original = 'ReloadUI', 
            callback = XF.Handlers.SystemEvent.CallbackReloadUI,
            pre = true
        })
        XFO.Events:Add({
            name = 'Logout',
            event = 'PLAYER_LOGOUT',
            callback = XF.Handlers.SystemEvent.CallbackLogout,
            instance = true
        })
        -- Not sure this is necessary but don't feel like taking the risk of removing it
        XFO.Events:Add({
            name = 'LoadScreen', 
            event = 'PLAYER_ENTERING_WORLD', 
            callback = XF.Handlers.SystemEvent.CallbackLogin, 
            instance = true
        })
		self:IsInitialized(true)
        XF.Config.Logout[#XF.Config.Logout + 1] = XF.Player.Unit:UnitName()
	end
end
--#endregion

--#region Callbacks
function SystemEvent:CallbackLogout()
    if(not XF.Cache.UIReload) then
        XFO.Chat:SendLogoutMessage()
    end
end

function SystemEvent:CallbackReloadUI()
    try(function ()        
        XFO.Confederate:Backup()
        XFO.Friends:Backup()
        XFO.Links:Backup()
        XFO.Orders:Backup()
    end).
    catch(function (err)
        XF:Error(ObjectName, err)
        XF.Config.Errors[#XF.Config.Errors + 1] = 'Failed to perform backups: ' .. err
    end).
    finally(function ()
        XF.Cache.UIReload = true
        _G.XFCacheDB = XF.Cache
    end)
end

function SystemEvent:CallbackLogin()
    if(XFO.Channels:HasLocalChannel()) then
        XFO.Channels:SetLast(XFO.Channels:LocalChannel():Key())
    end
end
--#endregion