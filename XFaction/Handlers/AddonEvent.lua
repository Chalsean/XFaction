local XFG, G = unpack(select(2, ...))
local ObjectName = 'AddonEvent'
local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnEnableState = GetAddOnEnableState

AddonEvent = Object:newChildConstructor()

--#region Constructors
function AddonEvent:new()
    local object = AddonEvent.parent.new(self)
    object.__name = ObjectName
    self.isLoaded = false
    return object
end
--#endregion

--#region Initializers
function AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('AddonEvent', 'ADDON_LOADED', XFG.Handlers.AddonEvent.CallbackAddonLoaded, true, true)
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
--#endregion

--#region Accessors
function AddonEvent:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion

--#region Cache
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
            Confederate = {},
            Errors = {},
            NewVersionNotify = false,
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
    XFG.Cache.Setup = {
		Confederate = {},
		Realms = {},
		Teams = {},
		Guilds = {},
		GuildsRealms = {},
		Compress = true,
	}
end
--#endregion

--#region Configs
function XFG:LoadConfigs()
    -- Get AceDB up and running as early as possible, its not available until addon is loaded
    XFG.ConfigDB = LibStub('AceDB-3.0'):New('XFactionDB', XFG.Defaults)
    XFG.Config = XFG.ConfigDB.profile

    -- Cache it because on shutdown, XFG.Config gets unloaded while we're still logging
    XFG.Verbosity = XFG.Config.Debug.Verbosity

    XFG.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XFG.ConfigDB)
    XFG.Lib.Config:RegisterOptionsTable(XFG.Name, XFG.Options, nil)
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, XFG.Name, nil, 'General')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Chat', XFG.Name, 'Chat')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'DataText', XFG.Name, 'DataText')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Addons', XFG.Name, 'Addons')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Setup', XFG.Name, 'Setup')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Support', XFG.Name, 'Support')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Debug', XFG.Name, 'Debug')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Profile', XFG.Name, 'Profile')

    XFG.ConfigDB.RegisterCallback(self, 'OnProfileChanged', 'InitProfile')
    XFG.ConfigDB.RegisterCallback(self, 'OnProfileCopied', 'InitProfile')
    XFG.ConfigDB.RegisterCallback(self, 'OnProfileReset', 'InitProfile')

    XFG:Info(ObjectName, 'Config loaded')
end
    
function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.ConfigDB.profile
end
--#endregion

--#region Callbacks
function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(GetAddOnEnableState(nil, inAddonName) > 0) then
            XFG.Lib.Event:SendMessage(XFG.Settings.Network.Message.IPC.ADDON_LOADED, inAddonName)
            if(inAddonName == XFG.Name and not XFG.Handlers.AddonEvent:IsLoaded()) then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                XFG:LoadConfigs()
                XFG.Handlers.AddonEvent:IsLoaded(true)      
            -- elseif(inAddonName == 'ElvUI') then XFG.Lib.Event:SendMessage(XFG.Settings.Network.Message.IPC.ADDON_LOADED, inAddonName)
            -- elseif(inAddonName == 'WIM') then XFG.Addons.WIM:OnLoad(WIM)
            --  or inAddonName == 'RaiderIO') then
            --     XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
            --     XFG.Lib.Event:SendMessage(XFG.Settings.Network.Message.IPC.ADDON_LOADED, inAddonName)
--                XFG.RaidIO:IsLoaded(true)
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end
--#endregion