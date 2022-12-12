local XFG, G = unpack(select(2, ...))
local ObjectName = 'Kui'
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

if(KuiNameplates == nil) then return end
XFG.Addons.Kui = KuiNameplates:NewPlugin('XFaction')

function XFG.Addons.Kui:OnShow(f)
    try(function()
        if(XFG.Initialized and XFG.Config.Addons.Kui.Enable and UnitIsPlayer(f.unit)) then
            if(XFG.Config.Addons.Kui.MainName) then
                local guid = UnitGUID(f.unit)
                if(guid and XFG.Confederate:Contains(guid)) then
                    local unit = XFG.Confederate:Get(guid)
                    if(unit:HasMainName()) then
                        f.state.name = f.state.name .. ' (' .. unit:GetMainName() .. ')'
                    end
                end
            end

            if(f.state.guild_text and XFG.Guilds:ContainsName(f.state.guild_text)) then
                if(XFG.Config.Addons.Kui.Icon) then
                    f.state.name = XFG.Media:Get(XFG.Icons.Guild):GetTexture() .. f.state.name
                end
                if(XFG.Config.Addons.Kui.GuildName == 'GuildInitials') then
                    f.state.guild_text = XFG.Guilds:GetByName(f.state.guild_text):GetInitials()
                elseif(XFG.Config.Addons.Kui.GuildName == 'Confederate') then
                    f.state.guild_text = XFG.Confederate:GetName()
                elseif(XFG.Config.Addons.Kui.GuildName == 'ConfederateInitials') then
                    f.state.guild_text = XFG.Confederate:GetKey()
                elseif(XFG.Config.Addons.Kui.GuildName == 'Team') then  
                    local guid = UnitGUID(f.unit)              
                    if(XFG.Confederate:Contains(guid)) then
                        f.state.guild_text = XFG.Confederate:Get(guid):GetTeam():GetName()
                    else
                        f.state.guild_text = 'Unknown'
                    end
                end
            elseif(XFG.Config.Addons.Kui.Hide) then
                f.state.guild_text = ''
            end
        end
    end).
    catch(function ()
        XFG:Warn(ObjectName, 'Failed to update Kui nameplate')
    end)
end

function XFG.Addons.Kui:UNIT_NAME_UPDATE(event,frame)
    self:OnShow(frame)
end

function XFG.Addons.Kui:OnEnable()
    self:RegisterMessage('Show', 'OnShow')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')
end