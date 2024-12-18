local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ElvUI'

XFC.ElvUI = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.ElvUI:new()
    local object = XFC.ElvUI.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ElvUI:Initialize()
    if(not self:IsInitialized() and XF.Config ~= nil and ElvUI ~= nil) then
        self:ParentInitialize()
        XFO.Media:Add(XF.Icons.Guild, 'Icon')
        XFO.ElvUI:API(ElvUI[1])        
        XFO.ElvUI:AddTags()
        XFO.ElvUI:IsLoaded(true)
        XF:Info(self:ObjectName(), 'ElvUI loaded successfully')
		self:IsInitialized(true)
	end
end

function XFC.ElvUI:AddTags()
    -- This will add uOF tags for availability to ElvUI nameplates/unitframes
    self:API():AddTag('xf:confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = XFF.PlayerGUID(inNameplate)
        local guildName = XFF.PlayerGuild(inNameplate)
        try(function ()
            -- The guild check is not correct, could have sharded in a guild of same name from another realm
            if(XF.Initialized and (XFO.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                guildName = XFO.Confederate:Name()
            end
        end)
        return guildName
    end)
    self:API():AddTagInfo('xf:confederate', XF.Name, XF.Lib.Locale['ADDON_ELVUI_CONFEDERATE'])

    self:API():AddTag('xf:confederate:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = XFF.PlayerGUID(inNameplate)
        local guildName = XFF.PlayerGuild(inNameplate)
        try(function ()
            if(XF.Initialized and (XFO.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                guildName = XFO.Confederate:Key()
            end
        end)
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end
    end)
    self:API():AddTagInfo('xf:confederate:initials', XF.Name, XF.Lib.Locale['ADDON_ELVUI_CONFEDERATE_INITIALS'])

    self:API():AddTag('xf:guild:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
        local guid = XFF.PlayerGUID(inNameplate)
        local guildName = XFF.PlayerGuild(inNameplate)
        try(function ()
            if(XF.Initialized and XFO.Confederate:Contains(guid)) then
                guildName = XFO.Confederate:Get(guid):Guild():Initials()
            elseif(XF.Initialized and XFO.Guilds:ContainsName(guildName)) then
                guildName = XFO.Guilds:GetByName(guildName):Initials()
            end
        end)
        if(guildName ~= nil) then
            return format('<%s>', guildName)
        end 
    end)
    self:API():AddTagInfo('xf:guild:initials', XF.Name, XF.Lib.Locale['ADDON_ELVUI_GUILD_INITIALS'])

    self:API():AddTag('xf:main', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local guid = XFF.PlayerGUID(inNameplate)
        local unitName = XFF.PlayerName(inNameplate)
        try(function ()
            if(XF.Initialized and XFO.Confederate:Contains(guid)) then
                local unitData = XFO.Confederate:Get(guid)
                if(unitData:IsAlt()) then
                    unitName = unitData:MainName()
                end
            end
        end)
        return unitName
    end)
    self:API():AddTagInfo('xf:main', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MAIN'])

    self:API():AddTag('xf:main:parenthesis', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local main = ''
        try(function ()
            if(XF.Initialized) then
                local guid = XFF.PlayerGUID(inNameplate)
                if(XFO.Confederate:Contains(guid)) then
                    local unitData = XFO.Confederate:Get(guid)
                    if(unitData:IsAlt()) then
                        main = '(' .. unitData:MainName() .. ')'
                    end
                end
            end
        end)
        return main
    end)
    self:API():AddTagInfo('xf:main:parenthesis', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MAIN_PARENTHESIS'])

    self:API():AddTag('xf:team', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local team = ''
        try(function ()
            local guid = XFF.PlayerGUID(inNameplate)
            if(XF.Initialized and XFO.Confederate:Contains(guid)) then
                team = XFO.Confederate:Get(guid):Team():Name()
            end
        end)
        return team
    end)
    self:API():AddTagInfo('xf:team', XF.Name, XF.Lib.Locale['ADDON_ELVUI_TEAM'])

    self:API():AddTag('xf:confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
        local icon = ''
        try(function ()
            local guid = XFF.PlayerGUID(inNameplate)
            local guildName = XFF.PlayerGuild(inNameplate)
            if(XF.Initialized and (XFO.Confederate:Contains(guid) or XFO.Guilds:ContainsName(guildName))) then
                icon = XFO.Media:Get(XF.Icons.Guild):GetTexture()
            end
        end)
        return icon
    end)
    self:API():AddTagInfo('xf:confederate:icon', XF.Name, XF.Lib.Locale['ADDON_ELVUI_MEMBER_ICON'])
end
--#endregion