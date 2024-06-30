local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Kui'
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

if(KuiNameplates == nil) then return end
XF.Addons.Kui = KuiNameplates:NewPlugin('XFaction')

function XF.Addons.Kui:OnShow(f)
    try(function()
        if(XF.Initialized and XF.Config.Addons.Kui.Enable and UnitIsPlayer(f.unit)) then
            if(XF.Config.Addons.Kui.MainName) then
                local guid = UnitGUID(f.unit)
                if(guid and XFO.Confederate:Contains(guid)) then
                    local unit = XFO.Confederate:Get(guid)
                    if(unit:HasMainName()) then
                        f.state.name = f.state.name .. ' (' .. unit:GetMainName() .. ')'
                    end
                end
            end

            if(f.state.guild_text and XFO.Guilds:ContainsName(f.state.guild_text)) then
                if(XF.Config.Addons.Kui.Icon) then
                    f.state.name = XF.Media:Get(XF.Icons.Guild):GetTexture() .. f.state.name
                end
                if(XF.Config.Addons.Kui.GuildName == 'GuildInitials') then
                    f.state.guild_text = XFO.Guilds:GetByName(f.state.guild_text):GetInitials()
                elseif(XF.Config.Addons.Kui.GuildName == 'Confederate') then
                    f.state.guild_text = XFO.Confederate:Name()
                elseif(XF.Config.Addons.Kui.GuildName == 'ConfederateInitials') then
                    f.state.guild_text = XFO.Confederate:Key()
                elseif(XF.Config.Addons.Kui.GuildName == 'Team') then  
                    local guid = UnitGUID(f.unit)              
                    if(XFO.Confederate:Contains(guid)) then
                        f.state.guild_text = XFO.Confederate:Get(guid):GetTeam():Name()
                    else
                        f.state.guild_text = 'Unknown'
                    end
                end
            elseif(XF.Config.Addons.Kui.Hide) then
                f.state.guild_text = ''
            end
        end
    end).
    catch(function ()
        XF:Warn(ObjectName, 'Failed to update Kui nameplate')
    end)
end

function XF.Addons.Kui:UNIT_NAME_UPDATE(event,frame)
    self:OnShow(frame)
end

function XF.Addons.Kui:OnEnable()
    self:RegisterMessage('Show', 'OnShow')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')
end