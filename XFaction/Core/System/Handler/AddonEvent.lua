local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'AddonEvent'

XFC.AddonEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.AddonEvent:new()
    local object = XFC.AddonEvent.parent.new(self)
    object.__name = ObjectName
    self.isLoaded = false
    return object
end

function XFC.AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XFO.Events:Add({
            name = 'AddonEvent', 
            event = 'ADDON_LOADED', 
            callback = XFO.AddonEvent.CallbackAddonLoaded, 
            instance = true,
            start = true
        })

        -- In case they already loaded
        if(XFF.ClientIsAddonLoaded('ElvUI')) then
            self:CallbackAddonLoaded('ElvUI')
        end
        if(XFF.ClientIsAddonLoaded('WIM')) then
            self:CallbackAddonLoaded('WIM')
        end
        if(XFF.ClientIsAddonLoaded('RaiderIO')) then
            self:CallbackAddonLoaded('RaiderIO')
        end
        if(XFF.ClientIsAddonLoaded('Elephant')) then
            self:CallbackAddonLoaded('Elephant')
        end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.AddonEvent:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion

--#region Methods
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

function XFC.AddonEvent:CallbackAddonLoaded(inAddonName)
    local self = XFO.AddonEvent
    try(function ()
        if(XFF.ClientAddonState(inAddonName) > 0) then
            if(inAddonName == XF.Name and not self:IsLoaded()) then
                XF:Info(self:ObjectName(), 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeCache()
                XF:ConfigInitialize()
                XFO.ElvUI:Initialize()
                self:IsLoaded(true)
            elseif(inAddonName == 'ElvUI') then
                XFO.ElvUI:Initialize()
            elseif(inAddonName == 'WIM') then
                XFO.WIM:Initialize()
            elseif(inAddonName == 'RaiderIO') then
                XFO.RaiderIO:Initialize()
            elseif(inAddonName == 'Elephant') then
                XFO.Elephant:Initialize()
            end
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)    
end
--#endregion