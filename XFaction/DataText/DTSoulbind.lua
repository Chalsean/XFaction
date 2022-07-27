local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTSoulbind'
local LogCategory = 'DTSoulbind'

local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"

local menuFrame = CreateFrame("Frame", "DTSoulbind_Menu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = "", isTitle = true, notCheckable = true },
	{ notCheckable = false },
	{ notCheckable = false },
	{ notCheckable = false }
}

DTSoulbind = {}

function DTSoulbind:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
	self._HeaderFont = nil
	self._RegularFont = nil
	self._LDBObject = nil
	self._Tooltip = nil
    
    return _Object
end

function DTSoulbind:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTSOULBIND_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTSOULBIND_NAME'],
		    OnEnter = function(this) XFG.DataText.Soulbind:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Soulbind:OnLeave(this) end,
			OnClick = function(this, button) XFG.DataText.Soulbind:OnClick(this, button) end,
		})

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTSoulbind:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTSoulbind:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
	XFG:Debug(LogCategory, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
	XFG:Debug(LogCategory, "  _Count (" .. type(self._Count) .. "): ".. tostring(self._Count))
	XFG:Debug(LogCategory, "  _LDBObject (" .. type(self._LDBObject) .. ")")
	XFG:Debug(LogCategory, "  _Tooltip (" .. type(self._Tooltip) .. ")")
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTSoulbind:RefreshBroker()
	if(XFG.Initialized) then
		if(XFG.Player.Unit and XFG.Player.Unit:HasCovenant()) then
			local ActiveCovenant = XFG.Player.Unit:GetCovenant()
			local _CovenantIconID = ActiveCovenant:GetIconID()

			if(XFG.Player.Unit:HasSoulbind()) then
				local ActiveSoulbind = XFG.Player.Unit:GetSoulbind()				
				local _SoulbindName = ActiveSoulbind:GetName()
				self._LDBObject.text = format('%s %s', format(XFG.Icons.String, _CovenantIconID), _SoulbindName)
			else
				self._LDBObject.text = format(XFG.Lib.Locale['DTSOULBIND_NO_SOULBIND'], format(XFG.Icons.String, _CovenantIconID))
			end
		else
			self._LDBObject.text = XFG.Lib.Locale['DTSOULBIND_NO_COVENANT']
		end
	end
end

function DTSoulbind:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(not XFG.Player.Unit or not XFG.Player.Unit:HasCovenant() or not XFG.Player.Unit:HasSoulbind()) then return end
	
	local _Tooltip
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, 1, "LEFT")
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, self._Tooltip)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()

	local ActiveCovenant = XFG.Player.Unit:GetCovenant()
	local ActiveSoulbind = XFG.Player.Unit:GetSoulbind()

	self._Tooltip:AddLine(format('%s %s', format(XFG.Icons.String, ActiveCovenant:GetIconID()), ActiveCovenant:GetName()))
	self._Tooltip:AddSeparator()
	self._Tooltip:AddLine(' ')

	local _SoulbindIDs = ActiveCovenant:GetSoulbindIDs()
	for _, _SoulbindID in pairs (_SoulbindIDs) do
		local _Soulbind = XFG.Soulbinds:GetSoulbind(_SoulbindID)
		local _SoulbindName = _Soulbind:GetName()
		if(ActiveSoulbind:GetKey() == _Soulbind:GetKey()) then
			self._Tooltip:AddLine(format(XFG.Lib.Locale['DTSOULBIND_ACTIVE'], _SoulbindName))
		else
			self._Tooltip:AddLine(format(XFG.Lib.Locale['DTSOULBIND_INACTIVE'], _SoulbindName))
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

	self._Tooltip:AddLine(' ')
	self._Tooltip:AddSeparator()
	
	self._Tooltip:AddLine(XFG.Lib.Locale['DTSOULBIND_LEFT_CLICK'])
	self._Tooltip:AddLine(XFG.Lib.Locale['DTSOULBIND_RIGHT_CLICK'])

	self._Tooltip:Show()
end

function DTSoulbind:OnClick(this, inButton)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if(inButton == 'LeftButton') then
		self._Tooltip:Hide()
		LoadAddOn("Blizzard_Soulbinds") 
		local SoulbindFrame = SoulbindViewer 
		if SoulbindFrame:IsVisible() then 
			SoulbindFrame:Hide() 
		else 
			SoulbindFrame:Open()
		end
	elseif(inButton == 'RightButton') then
		if(XFG.Player.Unit:HasCovenant()) then
			self._Tooltip:Hide()
			local _Covenant = XFG.Player.Unit:GetCovenant()
			local _CovenantName = _Covenant:GetName()
			local _CovenantIconID = _Covenant:GetIconID()
			menuList[1].text = format('%s %s', format(XFG.Icons.String, _CovenantIconID), _CovenantName)

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
			EasyMenu(menuList, menuFrame, 'cursor', 0, 0, 'MENU', 0)
		end
	end
end

function DTSoulbind:OnLeave(this)
	local _IsMouseOver = true
	local _Status, _Error = pcall(function () _IsMouseOver = MouseIsOver(self._Tooltip) end)
	if(_Status and _IsMouseOver == false) then 
		if XFG.Lib.QT:IsAcquired(ObjectName) then self._Tooltip:Clear() end
		self._Tooltip:Hide()
		XFG.Lib.QT:Release(ObjectName)
		self._Tooltip = nil
	end
end