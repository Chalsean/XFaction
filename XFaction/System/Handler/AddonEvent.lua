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
        if(C_AddOns.IsAddOnLoaded('WIM')) then
            self:CallbackAddonLoaded('WIM')
        end
        if(C_AddOns.IsAddOnLoaded('Elephant')) then
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
local function InitializeAceDB()
    
    -- Get AceDB up and running as early as possible, its not available until addon is loaded
	XF.ConfigDB = LibStub('AceDB-3.0'):New('XFactionDB', XF.Defaults, true)

	if (XF.ConfigDB.global.HasBeenReset == nil) then
		XF.ConfigDB:ResetDB(DEFAULT)
		XF.ConfigDB.global.HasBeenReset = true
	end

	XF.Config = XF.ConfigDB.profile

	-- Cache it because on shutdown, XF.Config gets unloaded while we're still logging
	XF.Verbosity = XF.Config.Debug.Verbosity

	XF.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XF.ConfigDB)
	XF.Lib.Config:RegisterOptionsTable(XF.Name, XF.Options, nil)
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, XF.Name, nil, 'General')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Chat', XF.Name, 'Chat')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'DataText', XF.Name, 'DataText')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Profile', XF.Name, 'Profile')

	XF.ConfigDB.RegisterCallback(XF, 'OnProfileChanged', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileCopied', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileReset', 'InitProfile')

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
            Mailbox = {},
        }
    end

	XF.Cache.Setup = {
		Confederate = {},
		Realms = {},
		Teams = {},
		Guilds = {},
		GuildsRealms = {},
		Compress = true,
	}

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
	end).
	catch(function (inErrorMessage)
		XF:Debug(ObjectName, inErrorMessage)
	end)
	--#endregion

	XF:Info(ObjectName, 'Configs loaded')
end

function XFC.AddonEvent:CallbackAddonLoaded(inAddonName)
    local self = XFO.AddonEvent
    try(function ()
        if(C_AddOns.GetAddOnEnableState(inAddonName) > 0) then
            if(inAddonName == XF.Name and not self:IsLoaded()) then
                XF:Info(self:ObjectName(), 'Addon is loaded and enabled [%s]', inAddonName)
                InitializeAceDB()
                self:IsLoaded(true)
            elseif(inAddonName == 'WIM') then
                XFO.WIM:Initialize()
            elseif(inAddonName == 'Elephant') then
                XFO.Elephant:Initialize()
            end
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)    
end

function XF:InitProfile()
    -- When DB changes namespace (profile) the XF.Config becomes invalid and needs to be reset
    XF.Config = XF.ConfigDB.profile
end

function XF_ToggleOptions()
	if XF.Lib.ConfigDialog.OpenFrames[XF.Name] ~= nil then
		XF.Lib.ConfigDialog:Close(XF.Name)
	else
		XF.Lib.ConfigDialog:Open(XF.Name)
		XF.Lib.ConfigDialog:SelectGroup(XF.Name, 'General', 'About')
	end
end
--#endregion