local XFG, G = unpack(select(2, ...))
if(KuiNameplates == nil) then return end
XFG.Nameplates.Kui = KuiNameplates:NewPlugin('XFaction')

local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

function XFG.Nameplates.Kui:Show(f)
    if(XFG.Config and XFG.Config.Nameplates.Kui.Enable and UnitIsPlayer(f.unit)) then
        if(XFG.Config.Nameplates.Kui.MainName) then
            local _GUID = UnitGUID(f.unit)
            if(_GUID and XFG.Confederate:Contains(_GUID)) then
                local _Unit = XFG.Confederate:Get(_GUID)
                if(_Unit:HasMainName()) then
                    f.state.name = f.state.name .. ' (' .. _Unit:GetMainName() .. ')'
                end
            end
        end

        if(f.state.guild_text and XFG.Guilds:ContainsName(f.state.guild_text)) then
            if(XFG.Config.Nameplates.Kui.Icon) then
                f.state.name = XFG.Media:Get(XFG.Icons.Guild):GetTexture() .. f.state.name
            end
            if(XFG.Config.Nameplates.Kui.GuildName == 'GuildInitials') then
                f.state.guild_text = XFG.Guilds:GetByName(f.state.guild_text):GetInitials()
            elseif(XFG.Config.Nameplates.Kui.GuildName == 'Confederate') then
                f.state.guild_text = XFG.Confederate:GetName()
            elseif(XFG.Config.Nameplates.Kui.GuildName == 'ConfederateInitials') then
                f.state.guild_text = XFG.Confederate:GetKey()
            elseif(XFG.Config.Nameplates.Kui.GuildName == 'Team') then  
                local _GUID = UnitGUID(f.unit)              
                if(XFG.Confederate:Contains(_GUID)) then
                    f.state.guild_text = XFG.Confederate:Get(_GUID):GetTeam():GetName()
                else
                    f.state.guild_text = 'Unknown'
                end
            end
        elseif(XFG.Config.Nameplates.Kui.Hide) then
            f.state.guild_text = ''
        end
    end
end

function XFG.Nameplates.Kui:UNIT_NAME_UPDATE(event,frame)
    self:Show(frame)
end

function XFG.Nameplates.Kui:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')
end