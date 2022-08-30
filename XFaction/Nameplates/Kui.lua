local XFG, G = unpack(select(2, ...))
if(KuiNameplates == nil) then
    return
end
if(XFG.Nameplates == nil) then XFG.Nameplates = {} end
XFG.Nameplates.Kui = KuiNameplates:NewPlugin('XFaction')

local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

-- messages ####################################################################
function XFG.Nameplates.Kui:Show(f)
    if(XFG.Config and XFG.Config.Nameplates.Kui.Enable and UnitIsPlayer(f.unit)) then
        if(XFG.Guilds:ContainsName(f.state.guild_text)) then
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

function XFG.Nameplates.Kui:OnEnable()
    self:RegisterMessage('Show')
end