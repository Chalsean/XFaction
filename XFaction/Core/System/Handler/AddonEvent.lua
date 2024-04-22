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
--#endregion

--#region Initializers
function XFC.AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = ObjectName, 
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
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.AddonEvent:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion

--#region Cache
function XF:InitializeCache()
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

function XF:InitializeConfig()
	-- Get AceDB up and running as early as possible, its not available until addon is loaded
	XF.ConfigDB = LibStub('AceDB-3.0'):New('XFactionDB', XF.Defaults, true)
	XF.Config = XF.ConfigDB.profile

	-- Cache it because on shutdown, XF.Config gets unloaded while we're still logging
	XF.Verbosity = XF.Config.Debug.Verbosity

	XF.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XF.ConfigDB)
	XF.Lib.Config:RegisterOptionsTable(XF.Name, XF.Options, nil)
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, XF.Name, nil, 'General')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Addons', XF.Name, 'Addons')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Chat', XF.Name, 'Chat')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'DataText', XF.Name, 'DataText')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Profile', XF.Name, 'Profile')

	XF.ConfigDB.RegisterCallback(XF, 'OnProfileChanged', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileCopied', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileReset', 'InitProfile')

	XF:SetupRealms()

	--#region Changelog
	try(function ()
		for versionKey, config in pairs(XF.ChangeLog) do
			XFO.Versions:Add(versionKey)
			XFO.Versions:Get(versionKey):IsInChangeLog(true)
		end

		local minorOrder = 0
		local patchOrder = 0
		for _, version in XFO.Versions:ReverseSortedIterator() do
			if(version:IsInChangeLog()) then
				local minorVersion = version:Major() .. '.' .. version:Minor()
				if(XF.Options.args.General.args.ChangeLog.args[minorVersion] == nil) then
					minorOrder = minorOrder + 1
					patchOrder = 0
					XF.Options.args.General.args.ChangeLog.args[minorVersion] = {
						order = minorOrder,
						type = 'group',
						childGroups = 'tree',
						name = minorVersion,
						args = {},
					}
				end
				patchOrder = patchOrder + 1
				XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:Key()] = {
					order = patchOrder,
					type = 'group',
					name = version:Key(),
					desc = 'Major: ' .. version:Major() .. '\nMinor: ' .. version:Minor() .. '\nPatch: ' .. version:Patch(),
					args = XF.ChangeLog[version:Key()],
				}
				if(version:IsAlpha()) then
					XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:Key()].name = version:Key() .. ' |cffFF4700Alpha|r'
				elseif(version:IsBeta()) then
					XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:Key()].name = version:Key() .. ' |cffFF7C0ABeta|r'
				end
			end
		end

		-- One time install logic
		local version = XFC.Version:new()
		if(XF.Config.InstallVersion ~= nil) then
			version:Key(XF.Config.InstallVersion)
		else
			version:Key('0.0.0')
		end
		if(version:IsNewer(XFO.Version, true)) then
			XF:Info(ObjectName, 'Performing new install')	
			XF:Install()
			XF.Config.InstallVersion = XFO.Version:Key()
		end
	end).
	catch(function (inErrorMessage)
		XF:Debug(ObjectName, inErrorMessage)
	end)
	--#endregion

	XF:Info(ObjectName, 'Configs loaded')
end
--#endregion

--#region Callbacks
function XFC.AddonEvent:CallbackAddonLoaded(inAddonName)
    local self = XFO.AddonEvent
    try(function ()
        if(XFF.ClientGetAddonState(inAddonName) > 0) then
            if(inAddonName == XF.Name and not self:IsLoaded()) then
                XF:Info(self:ObjectName(), 'Addon is loaded and enabled [%s]', inAddonName)
                --InitializeCache()
                --InitializeConfig()
                XFO.ElvUI:Initialize()
                self:IsLoaded(true)
            elseif(inAddonName == 'ElvUI') then
                XFO.ElvUI:Initialize()
            elseif(inAddonName == 'WIM') then
                XFO.WIM:Initialize()
            elseif(inAddonName == 'RaiderIO') then
                XFO.RaiderIO:Initialize()
            end
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)    
end
--#endregion