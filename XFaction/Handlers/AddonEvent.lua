local XFG, G = unpack(select(2, ...))
local ObjectName = 'AddonEvent'

AddonEvent = Object:newChildConstructor()

function AddonEvent:new()
    local _Object = AddonEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:RegisterEvent('ADDON_LOADED', XFG.Handlers.AddonEvent.CallbackAddonLoaded)
        XFG:Info(ObjectName, 'Registered for ADDON_LOADED events')
        -- In case they already loaded
        if(IsAddOnLoaded('ElvUI')) then
            self:CallbackAddonLoaded('ElvUI')
        end
        if(IsAddOnLoaded('WIM')) then
            self:CallbackAddonLoaded('WIM')
        end
        if(IsAddOnLoaded('RaiderIO')) then
            self:CallbackAddonLoaded('RaiderIO')
        end
		self:IsInitialized(true)
	end
end

function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(inAddonName == 'ElvUI') then
            XFG:Info(ObjectName, 'ElvUI addon has loaded')
			XFG.ElvUI = ElvUI[1]
            XFG.Frames.Chat:SetHandler()
            XFG.Nameplates.ElvUI = ElvUINameplate:new(); XFG.Nameplates.ElvUI:Initialize()
        elseif(inAddonName == 'WIM') then
            if(WIM.modules.GuildChat.enabled) then
                XFG.WIM = WIM.modules.GuildChat
            end
        elseif(inAddonName == 'RaiderIO') then
            XFG.RaidIO:IsLoaded(true)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end
