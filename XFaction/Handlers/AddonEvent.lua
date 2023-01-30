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
        XFG.Events:Add({name = 'AddonEvent', 
                        event = 'ADDON_LOADED', 
                        callback = XFG.Handlers.AddonEvent.CallbackAddonLoaded, 
                        instance = true,
                        start = true})
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
    if(XFG.Cache.Backup == nil) then
        XFG.Cache.Backup = {
            Confederate = {},
            Friends = {},
        }
    end
end
--#endregion

--#region Callbacks
function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(GetAddOnEnableState(nil, inAddonName) > 0) then
            if(inAddonName == XFG.Name and not XFG.Handlers.AddonEvent:IsLoaded()) then
                XFG:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                XFG:ConfigInitialize()
                XFG.Addons.ElvUI:Initialize()
                XFG.Handlers.AddonEvent:IsLoaded(true)
            elseif(inAddonName == 'ElvUI') then
                XFG.Addons.ElvUI:Initialize()
            elseif(inAddonName == 'WIM') then
                XFG.Addons.WIM:Initialize()
            elseif(inAddonName == 'RaiderIO') then
                XFG.Addons.RaiderIO:Initialize()
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end
--#endregion