local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
    if(not self:IsInitialized() and XF.Config ~= nil and ElvUI ~= nil) then
        self:ParentInitialize()
        XF.Media:Add(XF.Icons.Guild, 'Icon')
        XF.Addons.ElvUI:SetAPI(ElvUI[1])        
        XF.Addons.ElvUI:AddTags()
        XF.Addons.ElvUI:IsLoaded(true)
        XF:Info(ObjectName, 'ElvUI loaded successfully')
		self:IsInitialized(true)
	end
end

function XFElvUI:AddTags()
    -- This will add uOF tags for availability to ElvUI nameplates/unitframes
    self:GetAPI():AddTag('xf:confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        try(function ()
            -- The guild check is not correct, could have sharded in a guild of same name from another realm
            if(XF.Initialized and (XF.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                guildName = XF.Confederate:Name()
            end
        end)
        return guildName
    end)
    self:GetAPI():AddTagInfo('xf:confederate', XF.Name, XF.Lib.Locale['ADDON_ELVUI_CONFEDERATE'])

    self:GetAPI():AddTag('xf:confederate:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        try(function ()
            if(XF.Initialized and (XF.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                guildName = XF.Confederate:Key()
            end
        end)
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end
    end)
    self:GetAPI():AddTagInfo('xf:confederate:initials', XF.Name, XF.Lib.Locale['ADDON_ELVUI_CONFEDERATE_INITIALS'])

    self:GetAPI():AddTag('xf:guild:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local guildName = GetGuildInfo(inNameplate)
        try(function ()
            if(XF.Initialized and XF.Confederate:Contains(guid)) then
                guildName = XF.Confederate:Get(guid):GetGuild():Initials()
            elseif(XF.Initialized and XFO.Guilds:ContainsName(guildName)) then
                guildName = XFO.Guilds:Get(guildName):Initials()
            end
        end)
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end 
    end)
    self:GetAPI():AddTagInfo('xf:guild:initials', XF.Name, XF.Lib.Locale['ADDON_ELVUI_GUILD_INITIALS'])

    self:GetAPI():AddTag('xf:main', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local guid = UnitGUID(inNameplate)
        local unitName = UnitName(inNameplate)
        try(function ()
            if(XF.Initialized and XF.Confederate:Contains(guid)) then
                local unitData = XF.Confederate:Get(guid)
                if(unitData:HasMainName()) then
                    unitName = unitData:GetMainName()
                end
            end
        end)
        return unitName
    end)
    self:GetAPI():AddTagInfo('xf:main', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MAIN'])

    self:GetAPI():AddTag('xf:main:parenthesis', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local main = ''
        try(function ()
            if(XF.Initialized) then
                local guid = UnitGUID(inNameplate)
                if(XF.Confederate:Contains(guid)) then
                    local unitData = XF.Confederate:Get(guid)
                    if(unitData:HasMainName()) then
                        main = '(' .. unitData:GetMainName() .. ')'
                    end
                end
            end
        end)
        return main
    end)
    self:GetAPI():AddTagInfo('xf:main:parenthesis', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MAIN_PARENTHESIS'])

    self:GetAPI():AddTag('xf:team', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local team = ''
        try(function ()
            local guid = UnitGUID(inNameplate)
            if(XF.Initialized and XF.Confederate:Contains(guid)) then
                team = XF.Confederate:Get(guid):GetTeam():Name()
            end
        end)
        return team
    end)
    self:GetAPI():AddTagInfo('xf:team', XF.Name, XF.Lib.Locale['ADDON_ELVUI_TEAM'])

    self:GetAPI():AddTag('xf:confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local icon = ''
        try(function ()
            local guid = UnitGUID(inNameplate)
            local guildName = GetGuildInfo(inNameplate)
            if(XF.Initialized and (XF.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                icon = XF.Media:Get(XF.Icons.Guild):GetTexture()
            end
        end)
        return icon
    end)
    self:GetAPI():AddTagInfo('xf:confederate:icon', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MEMBER_ICON'])
end
--#endregion