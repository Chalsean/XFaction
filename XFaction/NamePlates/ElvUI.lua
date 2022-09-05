local XFG, G = unpack(select(2, ...))
local ObjectName = 'ElvUINameplate'

ElvUINameplate = Object:newChildConstructor()

function ElvUINameplate:new()
    local object = ElvUINameplate.parent.new(self)
    self.__name = ObjectName
    return object
end

function ElvUINameplate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(XFG.Config.Nameplates.ElvUI.Enable) then

            XFG.Media:Add(XFG.Icons.Guild, 'Icon')

            XFG.ElvUI:AddTag('confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                local guildName = GetGuildInfo(inNameplate)
                -- The guild check is not correct, could have sharded in a guild of same name from another realm
                if(XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName)) then
                    guildName = XFG.Confederate:GetName()
                end
                return guildName
            end)

            XFG.ElvUI:AddTag('confederate:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                local guildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName)) then
                    guildName = XFG.Confederate:GetKey()
                end
                if(guildName) then
                    return format('<%s>', guildName)
                end 
            end)

            XFG.ElvUI:AddTag('guild:initials', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                local guildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(guid)) then
                    guildName = XFG.Confederate:Get(guid):GetGuild():GetInitials()
                elseif(XFG.Guilds:ContainsName(guildName)) then
                    guildName = XFG.Guilds:GetByName(guildName):GetInitials()
                end
                if(guildName) then
                    return format('<%s>', guildName)
                end 
            end)
            
            XFG.ElvUI:AddTag('main', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                local unitName = UnitName(inNameplate)
                if(XFG.Confederate:Contains(guid)) then
                    local _UnitData = XFG.Confederate:Get(guid)
                    if(_UnitData:HasMainName()) then
                        unitName = _UnitData:GetMainName()
                    end
                end
                return unitName
            end)
            
            XFG.ElvUI:AddTag('main:parenthesis', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                if(XFG.Confederate:Contains(guid)) then
                    local _UnitData = XFG.Confederate:Get(guid)
                    if(_UnitData:HasMainName()) then
                        return '(' .. _UnitData:GetMainName() .. ')'
                    end
                end
            end)
            
            XFG.ElvUI:AddTag('team', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                if(XFG.Confederate:Contains(guid)) then
                    return XFG.Confederate:Get(guid):GetTeam():GetName()
                end
            end)
            
            XFG.ElvUI:AddTag('confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
                local guid = UnitGUID(inNameplate)
                local guildName = GetGuildInfo(inNameplate)
                if(XFG.Confederate:Contains(guid) or XFG.Guilds:ContainsName(guildName)) then
                    return XFG.Media:Get(XFG.Icons.Guild):GetTexture()
                end
            end)
        end
        
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end