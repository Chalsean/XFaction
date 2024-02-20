local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'SystemEvent'

XFC.SystemEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemEvent:new()
    local object = XFC.SystemEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.SystemEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()     
        -- Log any messages encountered during last logout
        for _, message in ipairs(XF.Config.Logout) do
            XF:Debug(self:GetObjectName(), '* Previous Logout: %s', message)
        end
        XF.Config.Logout = {}
        XFO.Hooks:Add({name = 'ReloadUI', 
                       original = 'ReloadUI', 
                       callback = XFO.SystemEvent.CallbackReloadUI,
                       pre = true})
        XFO.Events:Add({name = 'Logout',
                        event = 'PLAYER_LOGOUT',
                        callback = XFO.SystemEvent.CallbackLogout,
                        instance = true})
		self:IsInitialized(true)
        XF.Config.Logout[#XF.Config.Logout + 1] = XF.Player.Unit:GetUnitName()
	end
end
--#endregion

--#region Callbacks
function XFC.SystemEvent:CallbackLogout()
    if(not XF.Cache.UIReload) then
        local message = nil
        try(function ()
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout started'
            message = XFO.Chat:Pop()
            message:Initialize()
            message:SetType(XF.Enum.Network.BROADCAST)
            message:SetSubject(XF.Enum.Message.LOGOUT)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout sending message'
            XFO.Chat:Send(message)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout message sent'
        end).
        catch(function (err)
            XF:Error(self:GetObjectName(), err)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Failed to send logout message: ' .. err
        end).
        finally(function()
            XFO.Chat:Push(message)
        end)
    end
end

function XFC.SystemEvent:CallbackReloadUI()
    try(function ()        
        XFO.Confederate:Backup()
        XFO.Friends:Backup()
        XFO.Links:Backup()
        -- FIX: Move to retail
        --XFO.Orders:Backup()
    end).
    catch(function (err)
        XF:Error(self:GetObjectName(), err)
        XF.Config.Errors[#XF.Config.Errors + 1] = 'Failed to perform backups: ' .. err
    end).
    finally(function ()
        XF.Cache.UIReload = true
        _G.XFCacheDB = XF.Cache
    end)
end
--#endregion