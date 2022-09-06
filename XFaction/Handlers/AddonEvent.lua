local XFG, G = unpack(select(2, ...))
local ObjectName = 'AddonEvent'
local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnEnableState = GetAddOnEnableState

AddonEvent = Object:newChildConstructor()

function AddonEvent:new()
    local object = AddonEvent.parent.new(self)
    object.__name = ObjectName
    return object
end

function AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('AddonEvent', 'ADDON_LOADED', XFG.Handlers.AddonEvent.CallbackAddonLoaded)
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

local function InitializeCache()
    XFG.Cache = _G.XFCacheDB
    if(XFG.Cache.UIReload == nil or not XFG.Cache.UIReload) then
        XFG:Info(ObjectName, 'Initializing cache')
        XFG.Cache = {
            Backup = {
                Confederate = {},
                Friends = {},
            },
            Channel = {},
            Errors = {},
            NewVersionNotify = false,
            Player = {},
            Teams = {},
            UIReload = false,                    
            Verbosity = 4,
        }
    elseif(XFG.Cache.Errors ~= nil) then
        -- Log any reloadui errors encountered
        for _, _ErrorText in ipairs(XFG.Cache.Errors) do
            XFG:Warn(ObjectName, _ErrorText)
        end
        XFG.Cache.Errors = {}
    else
        XFG.Cache.Errors = {}
    end
    XFG.Cache.FirstScan = {}
end

local function StartElvUI()
    if(XFG.Config ~= nil and XFG.ElvUI ~= nil) then
        XFG.Nameplates.ElvUI = ElvUINameplate:new(); XFG.Nameplates.ElvUI:Initialize()
    end
end

function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(GetAddOnEnableState(nil, inAddonName) > 0) then
            if(inAddonName == XFG.Name) then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                XFG:LoadConfigs()
                StartElvUI()
                XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	            XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	            XFG.DataText.Metrics = DTMetrics:new(); XFG.DataText.Metrics:Initialize()                
            elseif(inAddonName == 'ElvUI') then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                XFG.ElvUI = ElvUI[1]
                StartElvUI()
            elseif(inAddonName == 'WIM') then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                if(WIM.modules.GuildChat.enabled) then
                    XFG.WIM = WIM.modules.GuildChat
                end
            elseif(inAddonName == 'RaiderIO') then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                XFG.RaidIO:IsLoaded(true)
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end