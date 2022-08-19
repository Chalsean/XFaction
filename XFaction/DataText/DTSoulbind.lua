local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTSoulbind'

local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"

local menuFrame = CreateFrame("Frame", "DTSoulbind_Menu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = "", isTitle = true, notCheckable = true },
	{ notCheckable = false },
	{ notCheckable = false },
	{ notCheckable = false }
}

DTSoulbind = Object:newChildConstructor()

function DTSoulbind:new()
    local _Object = DTGuild.parent.new(self)
    _Object.__name = ObjectName
	_Object._HeaderFont = nil
	_Object._RegularFont = nil
	_Object._LDBObject = nil
	_Object._Tooltip = nil
    return _Object
end

function DTSoulbind:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
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

function DTSoulbind:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
		XFG:Debug(ObjectName, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
		XFG:Debug(ObjectName, "  _Count (" .. type(self._Count) .. "): ".. tostring(self._Count))
		XFG:Debug(ObjectName, "  _LDBObject (" .. type(self._LDBObject) .. ")")
		XFG:Debug(ObjectName, "  _Tooltip (" .. type(self._Tooltip) .. ")")
	end
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
	if(not XFG.Initialized) then return end
	if(not XFG.Player.Unit or not XFG.Player.Unit:HasCovenant() or not XFG.Player.Unit:HasSoulbind()) then return end
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, 1, "LEFT")
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function () DTSoulbind:OnLeave() end)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()

	local ActiveCovenant = XFG.Player.Unit:GetCovenant()
	local ActiveSoulbind = XFG.Player.Unit:GetSoulbind()

	self._Tooltip:AddLine(format('%s %s', format(XFG.Icons.String, ActiveCovenant:GetIconID()), ActiveCovenant:GetName()))
	self._Tooltip:AddSeparator()
	self._Tooltip:AddLine(' ')

	for _, _SoulbindID in ActiveCovenant:SoulbindIterator() do
		local _Soulbind = XFG.Soulbinds:GetObject(_SoulbindID)
		local _SoulbindName = _Soulbind:GetName()
		if(ActiveSoulbind:GetKey() == _Soulbind:GetKey()) then
			self._Tooltip:AddLine(format(XFG.Lib.Locale['DTSOULBIND_ACTIVE'], _SoulbindName))
		else
			self._Tooltip:AddLine(format(XFG.Lib.Locale['DTSOULBIND_INACTIVE'], _SoulbindName))
		end
	end

	self._Tooltip:AddLine(' ')
	self._Tooltip:AddSeparator()
	
	self._Tooltip:AddLine(XFG.Lib.Locale['DTSOULBIND_LEFT_CLICK'])
	self._Tooltip:AddLine(XFG.Lib.Locale['DTSOULBIND_RIGHT_CLICK'])

	self._Tooltip:Show()
end

function DTSoulbind:OnClick(this, inButton)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if(inButton == 'LeftButton') then
		if(self._Tooltip) then self._Tooltip:Hide() end
		LoadAddOn("Blizzard_Soulbinds") 
		local SoulbindFrame = SoulbindViewer 
		if SoulbindFrame:IsVisible() then 
			SoulbindFrame:Hide() 
		else 
			SoulbindFrame:Open()
		end
	elseif(inButton == 'RightButton') then
		if(XFG.Player.Unit:HasCovenant()) then
			if(self._Tooltip) then self._Tooltip:Hide() end
			local _Covenant = XFG.Player.Unit:GetCovenant()
			local _CovenantName = _Covenant:GetName()
			local _CovenantIconID = _Covenant:GetIconID()
			menuList[1].text = format('%s %s', format(XFG.Icons.String, _CovenantIconID), _CovenantName)

			if(XFG.Player.Unit:HasSoulbind()) then
				local _ActiveSoulbind = XFG.Player.Unit:GetSoulbind()
				for i, _SoulbindID in _Covenant:SoulbindIterator() do
					local _Soulbind = XFG.Soulbinds:GetObject(_SoulbindID)
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
	if self._Tooltip and MouseIsOver(self._Tooltip) then
	    return
	else
        XFG.Lib.QT:Release(self._Tooltip)
        self._Tooltip = nil
	end
end