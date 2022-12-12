local XFG, G = unpack(select(2, ...))
local ObjectName = 'ElvUI'

XFElvUI = Addon:newChildConstructor()

--#region Constructors
function XFElvUI:new()
    local object = XFElvUI.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFElvUI:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('ElvUI Load', XFG.Settings.Network.Message.IPC.ADDON_LOADED, XFG.Addons.ElvUI.CallbackAddonLoaded, true, true)
		self:IsInitialized(true)
	end
end

function XFElvUI:CallbackAddonLoaded(inAddonName)
    if(inAddonName == ObjectName and not XFG.Addons.ElvUI:IsLoaded()) then
        XFG.Media:Add(XFG.Icons.Guild, 'Icon')
        XFG.Addons.ElvUI:SetAPI(ElvUI[1])        
        XFG.Addons.ElvUI:AddTags()
        XFG.Addons.ElvUI:IsLoaded(true)
        XFG:Info(ObjectName, 'ElvUI loaded successfully')
    end
end

function XFElvUI:AddTags()
    -- This will add uOF tags for availability to ElvUI nameplates/unitframes
    self:GetAPI():AddTag('xf:confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        -- The guild check is not correct, could have sharded in a guild of same name from another realm
        if(XFG.Initialized and (XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName))) then
            guildName = XFG.Confederate:GetName()
        end
        return guildName
    end)
    self:GetAPI():AddTagInfo('xf:confederate', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_CONFEDERATE'])

    self:GetAPI():AddTag('xf:confederate:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        if(XFG.Initialized and (XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName))) then
            guildName = XFG.Confederate:GetKey()
        end
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end
    end)
    self:GetAPI():AddTagInfo('xf:confederate:initials', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_CONFEDERATE_INITIALS'])

    self:GetAPI():AddTag('xf:guild:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        if(XFG.Initialized and XFG.Confederate:Contains(guid)) then
            guildName = XFG.Confederate:Get(guid):GetGuild():GetInitials()
        elseif(XFG.Initialized and XFG.Guilds:ContainsName(guildName)) then
            guildName = XFG.Guilds:GetByName(guildName):GetInitials()
        end
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end 
    end)
    self:GetAPI():AddTagInfo('xf:guild:initials', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_GUILD_INITIALS'])

    self:GetAPI():AddTag('xf:main', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local unitName = UnitName(inNameplate)
        if(XFG.Initialized and XFG.Confederate:Contains(guid)) then
            local unitData = XFG.Confederate:Get(guid)
            if(unitData:HasMainName()) then
                unitName = unitData:GetMainName()
            end
        end
        return unitName
    end)
    self:GetAPI():AddTagInfo('xf:main', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_MAIN'])

    self:GetAPI():AddTag('xf:main:parenthesis', 'UNIT_NAME_UPDATE', function(inNameplate) 
        if(XFG.Initialized) then
            local guid = UnitGUID(inNameplate)
            if(XFG.Confederate:Contains(guid)) then
                local unitData = XFG.Confederate:Get(guid)
                if(unitData:HasMainName()) then
                    return '(' .. unitData:GetMainName() .. ')'
                end
            end
        end
        return ''
    end)
    self:GetAPI():AddTagInfo('xf:main:parenthesis', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_MAIN_PARENTHESIS'])

    self:GetAPI():AddTag('xf:team', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        if(XFG.Initialized and XFG.Confederate:Contains(guid)) then
            return XFG.Confederate:Get(guid):GetTeam():GetName()
        end
        return ''
    end)
    self:GetAPI():AddTagInfo('xf:team', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_TEAM'])

    self:GetAPI():AddTag('xf:confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        if(XFG.Initialized and (XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName))) then
            return XFG.Media:Get(XFG.Icons.Guild):GetTexture()
        end
        return ''
    end)
    self:GetAPI():AddTagInfo('xf:confederate:icon', XFG.Name, XFG.Lib.Locale['ADDON_ELVUI_MEMBER_ICON'])
end
--#endregion