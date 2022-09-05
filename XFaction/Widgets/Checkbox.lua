local XFG, G = unpack(select(2, ...))
local ObjectName = 'CheckboxWidget'

function XFG.Widgets.NewCheckbox(inFrame, inLabel, inDescription, inClick)
    local check = CreateFrame('CheckButton', ObjectName .. inLabel, inFrame, 'InterfaceOptionsCheckButtonTemplate')
    check:SetScript('OnClick', function(self)
        local selected = self:GetChecked()
        inClick(self, selected and true or false)
        if(selected) then
            PlaySound(856, 'Master') -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857, 'Master') -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)
    check.label = _G[check:GetName() .. 'Text']
    check.label:SetText(inLabel)
    check.label:SetTextScale(1.5)
    check.tooltipText = inLabel
    check.tooltipRequirement = inDescription
    return check
end