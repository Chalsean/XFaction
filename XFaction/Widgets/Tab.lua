local XFG, G = unpack(select(2, ...))
local ObjectName = 'TabWidget'

function XFG.Widgets.NewTab(inFrame, inLabel, inClick)
    -- Tab Button
    local tab = CreateFrame('Button', ObjectName .. inLabel, inFrame, 'UIPanelButtonTemplate')
    tab:SetScript('OnClick', function(self)
        XFG.Widgets.TabClick(self)
        PlaySound(858, 'Master') -- SOUNDKIT.IG_MAINMENU_OPTION_FAER_TAB
    end)
    tab.name = 'Tab' .. inLabel
    tab.label = _G[tab:GetName() .. 'Text']
    tab.label:SetText(inLabel)
    tab:SetWidth(strlen(inLabel) * 10)
    tab.label:SetTextScale(1)
    tab.parent = inFrame
    local tabBackground = tab:CreateTexture()
    tabBackground:SetAllPoints(tab)
    tabBackground:SetColorTexture(0, 0, 0, 1)

    -- Selection Line
    local selectionLine = tab:CreateLine()
    selectionLine:SetColorTexture(1, 0.28, 0, 1)
    selectionLine:SetStartPoint('TOPLEFT', tab)
    selectionLine:SetEndPoint('TOPRIGHT', tab)
    tab.selection = selectionLine
    selectionLine:Hide()

    -- Tab Frame
    local tabFrame = CreateFrame('Frame', ObjectName .. 'Desc', inFrame, BackdropTemplateMixin and 'BackdropTemplate')
    tabFrame.name = 'TabFrame' .. inLabel
    tabFrame:SetPoint('TOPLEFT', tab)
    tabFrame:SetPoint('BOTTOMRIGHT', 0, 5)
    tabFrame:SetHeight(40)
    tabFrame:SetBackdropColor(0, 0, 0, 0.5)
    -- local _Background = _Desc:CreateTexture()
    -- _Background:SetAllPoints(_Desc)
    -- _Background:SetColorTexture(0, 0, 0, 0.5)
    tab.tabframe = tabFrame

    return tab
end

function XFG.Widgets.TabClick(inButton)    
    for _, child in pairs( { inButton.parent:GetChildren() } ) do
        if(child.tabframe ~= nil) then
            child.tabframe:Hide()
            child.selection:Hide()
        end
    end
    inButton.tabframe:Show()
    inButton.selection:Show()
end