local XFG, G = unpack(select(2, ...))
local ObjectName = 'AddonEvent'
local LogCategory = 'HEAddon'

AddonEvent = {}

function AddonEvent:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self._Initialized = false
    
    return _Object
end

function AddonEvent:Initialize()
	if(not self:IsInitialized()) then
        XFG:RegisterEvent('ADDON_LOADED', XFG.Handlers.AddonEvent.CallbackAddonLoaded)
        XFG:Info(LogCategory, 'Registered for ADDON_LOADED events')
        -- In case they already loaded
        if(IsAddOnLoaded('ElvUI')) then
            self:CallbackAddonLoaded('ElvUI')
        elseif(IsAddOnLoaded('WIM')) then
            self:CallbackAddonLoaded('WIM')
        end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function AddonEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function AddonEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function AddonEvent:CallbackAddonLoaded(inAddonName)
    try(function ()
        if(inAddonName == 'ElvUI') then
            XFG:Info(LogCategory, 'ElvUI addon has loaded')
			XFG.ElvUI = ElvUI[1]
            XFG.Frames.Chat:SetHandler()
            XFG.Nameplates.ElvUI = ElvUINameplate:new(); XFG.Nameplates.ElvUI:Initialize()
        elseif(inAddonName == 'WIM') then
            if(WIM.modules.GuildChat.enabled) then
                XFG.WIM = WIM.modules.GuildChat
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(LogCategory, 'Failed to handle ADDON_LOADED event: ' .. inErrorMessage)
    end)    
end
