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
    if(_G.XFCacheDB == nil) then _G.XFCacheDB = {} end
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
        XFG.Cache.Player.GUID = UnitGUID('player')
        XFG.Cache.Player.Realm = GetRealmName()
        XFG.Cache.Player.Realm = 'Proudmoore'        
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

local function LoadConfig()
    if(_G.XFConfigDB == nil) then _G.XFConfigDB = {} end
    XFG.Config = _G.XFConfigDB
    XFG.Configs = ConfigCollection:new(); XFG.Configs:Initialize()
    XFG.Configs:Add('Enable', true)
end

function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(GetAddOnEnableState(nil, inAddonName) > 0) then
            if(inAddonName == XFG.Category) then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                LoadConfig()
                XFG.Player.GUID = XFG.Cache.Player.GUID
                XFG.Player.Faction = XFG.Factions:GetByName(UnitFactionGroup('player'))
            elseif(inAddonName == 'ElvUI') then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                XFG.ElvUI = ElvUI[1]
                XFG.Nameplates.ElvUI = ElvUINameplate:new(); XFG.Nameplates.ElvUI:Initialize()
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