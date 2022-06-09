local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local LogCategory = 'DTSoulbind'

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local IconNumbers = {3257748, 3257751, 3257750, 3257749} -- Kyrian, Venthyr, Night Fae, Necrolord
local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"

local menuFrame = CreateFrame("Frame", "DTSoulbind_Menu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = "", isTitle = true, notCheckable = true },
	{ notCheckable = false },
	{ notCheckable = false },
	{ notCheckable = false }
}

local function OnEnable(self, event, ...)
	self.text:SetFormattedText('No Covenant')	
end

local function OnEvent(self, event, ...)
	if(XFG.Initialized and event == 'ELVUI_FORCE_UPDATE') then
		if(XFG.Player.Unit:HasCovenant()) then
			local ActiveCovenant = XFG.Player.Unit:GetCovenant()
			local _CovenantIconID = ActiveCovenant:GetIconID()

			if(XFG.Player.Unit:HasSoulbind()) then
				local ActiveSoulbind = XFG.Player.Unit:GetSoulbind()				
				local _SoulbindName = ActiveSoulbind:GetName()
				self.text:SetFormattedText(format('%s %s', format(IconTokenString, _CovenantIconID), _SoulbindName))
			else
				self.text:SetFormattedText(format('%s No Soulbind', format(IconTokenString, _CovenantIconID)))
			end
		else
			self.text:SetFormattedText('No Covenant')
		end
	end
end

local function OnEnter(self)
	if(XFG.Initialized == false) then return end
	local ActiveCovenant = XFG.Player.Unit:GetCovenant()
	local ActiveSoulbind = XFG.Player.Unit:GetSoulbind()

	DT:SetupTooltip(self)

	DT.tooltip:AddLine(format('%s %s', format(IconTokenString, ActiveCovenant:GetIconID()), ActiveCovenant:GetName()))
	DT.tooltip:AddLine(' ')

	local _SoulbindIDs = ActiveCovenant:GetSoulbindIDs()
	for _, _SoulbindID in pairs (_SoulbindIDs) do
		local _Soulbind = XFG.Soulbinds:GetSoulbind(_SoulbindID)
		local _SoulbindName = _Soulbind:GetName()
		if(ActiveSoulbind:GetKey() == _Soulbind:GetKey()) then
			DT.tooltip:AddLine(format('|cffFFFFFF%s: %s', _SoulbindName, ActiveString))
		else
			DT.tooltip:AddLine(format('|cffFFFFFF%s: %s', _SoulbindName, InactiveString))
		end
	end

	-- DT.tooltip:AddLine(' ')
	-- for i = 1, table.getn(SB.SoulbindData[SB.ActiveSoulbindID].tree.nodes) do
	-- 	if(SB.SoulbindData[SB.ActiveSoulbindID].tree.nodes[i].state == Enum.SoulbindNodeState.Selected and
	-- 	   SB.SoulbindData[SB.ActiveSoulbindID].tree.nodes[i].conduitRank == 0) then
	-- 		local IconID = SB.SoulbindData[SB.ActiveSoulbindID].tree.nodes[i].icon
	-- 		local IconString = format(IconTokenString, IconID)
	-- 		local SpellID = SB.SoulbindData[SB.ActiveSoulbindID].tree.nodes[i].spellID
	-- 		local SpellName = GetSpellInfo(SpellID)
	-- 		DT.tooltip:AddLine(format('%s %s', IconString, SpellName))
	-- 	end
	-- end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Open Soulbind Frame"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Soulbind"])

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if button == "LeftButton" then
		LoadAddOn("Blizzard_Soulbinds") 
		local SoulbindFrame = SoulbindViewer 
		if SoulbindFrame:IsVisible() then 
			SoulbindFrame:Hide() 
		else 
			SoulbindFrame:Open()
		end
	elseif button == "RightButton" then
		if(XFG.Player.Unit:HasCovenant()) then
			local _Covenant = XFG.Player.Unit:GetCovenant()
			local _CovenantName = _Covenant:GetName()
			local _CovenantIconID = _Covenant:GetIconID()
			menuList[1].text = format('%s %s', format(IconTokenString, _CovenantIconID), _CovenantName)

			if(XFG.Player.Unit:HasSoulbind()) then
				local _ActiveSoulbind = XFG.Player.Unit:GetSoulbind()
				local _Soulbinds = _Covenant:GetSoulbindIDs()
				for i, _SoulbindID in pairs (_Soulbinds) do
					local _Soulbind = XFG.Soulbinds:GetSoulbind(_SoulbindID)
					menuList[i+1].text = _Soulbind:GetName()
					menuList[i+1].func = function() C_Soulbinds.ActivateSoulbind(_SoulbindID) end
					if(_Soulbind:GetKey() == _ActiveSoulbind:GetKey()) then
						menuList[i+1].checked = true
					else
						menuList[i+1].checked = false
					end
				end
			end
			EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
		end
	end
end

DT:RegisterDatatext(XFG.DataText.Soulbind.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, nil, OnClick, OnEnter)