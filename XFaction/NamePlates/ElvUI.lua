local XFG, G = unpack(select(2, ...))
local ObjectName = 'ElvUINameplate'
local LogCategory = 'NPElvUI'

ElvUINameplate = Nameplate:newChildConstructor()

function ElvUINameplate:new()
    local _Object = ElvUINameplate.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function ElvUINameplate:Initialize()
	if(not self:IsInitialized()) then
        if(XFG.Config.Nameplates.ElvUI.Enable) then

            XFG.Media:AddMedia(XFG.Icons.Guild, 'Icon')

            XFG.ElvUI:AddTag('confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                local _GuildName = GetGuildInfo(inNameplate)
                -- The guild check is not correct, could have sharded in a guild of same name from another realm
                if(XFG.Confederate:Contains(_GUID) or XFG.Guilds:ContainsGuildName(_GuildName)) then
                    _GuildName = XFG.Confederate:GetName()
                end
                return _GuildName
            end)

            XFG.ElvUI:AddTag('confederate:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                local _GuildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(_GUID) or XFG.Guilds:ContainsGuildName(_GuildName)) then
                    _GuildName = XFG.Confederate:GetKey()
                end
                if(_GuildName) then
                    return format('<%s>', _GuildName)
                end 
            end)

            XFG.ElvUI:AddTag('guild:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                local _GuildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(_GUID)) then
                    _GuildName = XFG.Confederate:GetUnit(_GUID):GetGuild():GetInitials()
                elseif(XFG.Guilds:ContainsGuildName(_GuildName)) then
                    _GuildName = XFG.Guilds:GetGuildByName(_GuildName):GetInitials()
                end
                if(_GuildName) then
                    return format('<%s>', _GuildName)
                end 
            end)
            
            XFG.ElvUI:AddTag('main', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                local _UnitName = UnitName(inNameplate)
                if(XFG.Confederate:Contains(_GUID)) then
                    local _UnitData = XFG.Confederate:GetUnit(_GUID)
                    if(_UnitData:HasMainName()) then
                        _UnitName = _UnitData:GetMainName()
                    end
                end
                return _UnitName
            end)
            
            XFG.ElvUI:AddTag('main:parenthesis', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                if(XFG.Confederate:Contains(_GUID)) then
                    local _UnitData = XFG.Confederate:GetUnit(_GUID)
                    if(_UnitData:HasMainName()) then
                        return '(' .. _UnitData:GetMainName() .. ')'
                    end
                end
            end)
            
            XFG.ElvUI:AddTag('team', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                if(XFG.Confederate:Contains(_GUID)) then
                    return XFG.Confederate:GetUnit(_GUID):GetTeam():GetName()
                end
            end)
            
            XFG.ElvUI:AddTag('confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local _GUID = UnitGUID(inNameplate)
                local _GuildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(_GUID) or XFG.Guilds:ContainsGuildName(_GuildName)) then
                    return format('%s', format(XFG.Icons.Texture, XFG.Media:GetMedia(XFG.Icons.Guild):GetPath()))
                end
            end)
        end
        
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end