local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'AddonEvent'
local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnEnableState = GetAddOnEnableState

AddonEvent = XFC.Object:newChildConstructor()

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
        XFO.Events:Add({name = 'AddonEvent', 
                        event = 'ADDON_LOADED', 
                        callback = XF.Handlers.AddonEvent.CallbackAddonLoaded, 
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
    XF.Cache = _G.XFCacheDB
    
    if(XF.Cache.UIReload == nil or not XF.Cache.UIReload) then
        XF:Info(ObjectName, 'Initializing cache')
        XF.Cache = {
            Channel = {},
            Confederate = {},
            Errors = {},
            NewVersionNotify = false,
            UIReload = false,                    
            Verbosity = 4,
        }
    elseif(XF.Cache.Errors ~= nil) then
        -- Log any reloadui errors encountered
        for _, _ErrorText in ipairs(XF.Cache.Errors) do
            XF:Warn(ObjectName, _ErrorText)
        end
        XF.Cache.Errors = {}
    else
        XF.Cache.Errors = {}
    end
    if(XF.Cache.Backup == nil) then
        XF.Cache.Backup = {
            Confederate = {},
            Friends = {},
            Items = {},
            Orders = {},
        }
    end
end
--#endregion

--#region Callbacks
function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(GetAddOnEnableState(nil, inAddonName) > 0) then
            if(inAddonName == XF.Name and not XF.Handlers.AddonEvent:IsLoaded()) then
                XF:Info(ObjectName, 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                XF:ConfigInitialize()
                XF.Addons.ElvUI:Initialize()
                XF.Handlers.AddonEvent:IsLoaded(true)
            elseif(inAddonName == 'ElvUI') then
                XF.Addons.ElvUI:Initialize()
            elseif(inAddonName == 'WIM') then
                XF.Addons.WIM:Initialize()
            elseif(inAddonName == 'RaiderIO') then
                XF.Addons.RaiderIO:Initialize()
            end
        end
    end).
    catch(function (err)
        XF:Warn(ObjectName, err)
    end)    
end
--#endregion