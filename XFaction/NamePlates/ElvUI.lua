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

        XFG.ElvUI:AddTag('confederate', 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE', function(inNameplate) 
            if(UnitIsPlayer(inNameplate)) then
                local _GuildName = XFG.Player.Guild:GetName()
                if(XFG.Config.Nameplates.Confederate.Enable) then
                    _GuildName = XFG.Confederate:GetName()
                end
                return _GuildName
            end 
        end)

        XFG.ElvUI:AddTag('confederate:brackets', 'PLAYER_GUILD_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            local _GuildName = GetGuildInfo(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                _GuildName = XFG.Confederate:GetName()
            end
            if(_GuildName) then
                return format('<%s>', _GuildName)
            end 
        end)
        
        XFG.ElvUI:AddTag('name:main', 'UNIT_NAME_UPDATE', function(inNameplate) 
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
        
        XFG.ElvUI:AddTag('name:main-paren', 'UNIT_NAME_UPDATE', function(inNameplate) 
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
        
        XFG.ElvUI:AddTag('team-paren', 'UNIT_NAME_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                return '(' .. XFG.Confederate:GetUnit(_GUID):GetTeam():GetName() .. ')'
            end
        end)
        
        XFG.ElvUI:AddTag('confederate:team', 'UNIT_NAME_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            local _GuildName = GetGuildInfo(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                _GuildName = XFG.Confederate:GetName() .. ':' .. XFG.Confederate:GetUnit(_GUID):GetTeam():GetName()
            end
            return _GuildName
        end)
        
        XFG.ElvUI:AddTag('confederate:team:brackets', 'UNIT_NAME_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            local _GuildName = GetGuildInfo(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                _GuildName = XFG.Confederate:GetName() .. ':' .. XFG.Confederate:GetUnit(_GUID):GetTeam():GetName()
            end
            if(_GuildName) then
                return '<' .. _GuildName .. '>'
            end
        end)

        XFG.ElvUI:AddTag('confederate-init:team:brackets', 'UNIT_NAME_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            local _GuildName = GetGuildInfo(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                _GuildName = XFG.Confederate:GetKey() .. ':' .. XFG.Confederate:GetUnit(_GUID):GetTeam():GetName()
            end
            if(_GuildName) then
                return '<' .. _GuildName .. '>'
            end
        end)
        
        XFG.ElvUI:AddTag('confederate:icon', 'UNIT_NAME_UPDATE', function(inNameplate) 
            local _GUID = UnitGUID(inNameplate)
            if(XFG.Confederate:Contains(_GUID)) then
                return XFG.Icons.Guild
            end
        end)
        
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end