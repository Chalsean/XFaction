local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTLinks'
local CombatLockdown = InCombatLockdown

XFC.DTLinks = XFC.Object:newChildConstructor()
	
--#region Constructors
function XFC.DTLinks:new()
	local object = XFC.DTLinks.parent.new(self)
    object.__name = ObjectName
    object.headerFont = nil
	object.regularFont = nil
	object.ldbObject = nil
	object.tooltip = nil
	object.count = 0    
    return object
end
--#endregion

--#region Initializers
function XFC.DTLinks:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTLINKS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTLINKS_NAME'],
		    OnEnter = function(this) XFO.DTLinks:OnEnter(this) end,
			OnLeave = function(this) XFO.DTLinks:OnLeave(this) end,
		})
		self.headerFont = CreateFont('headerFont')
		self.headerFont:SetTextColor(0.4,0.78,1)
		self.regularFont = CreateFont('regularFont')
		self.regularFont:SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFC.DTLinks:PostInitialize()
	XFO.DTLinks:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTLinks:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTLinks:RefreshBroker()
end
--#endregion

--#region Print
function XFC.DTLinks:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Accessors
function XFC.DTLinks:GetBroker()
	return self.ldbObject
end

function XFC.DTLinks:GetHeaderFont()
	return self.headerFont
end

function XFC.DTLinks:GetRegularFont()
	return self.regularFont
end

function XFC.DTLinks:RefreshBroker()
	local text = ''
	if(XF.Config.DataText.Link.Label) then
		text = XF.Lib.Locale['LINKS'] .. ': '
	end

	local guild = 0
	local chat = 0
	local bnet = 0

	for _, target in XFO.Targets:Iterator() do
		if(target:IsMyTarget()) then 
			guild = target:Count()
		else
			chat = chat + target:Count()
		end
		bnet = bnet + target:LinkCount()
	end

	text = format('|cff3CE13F%d|r|cffFFFFFF - |r|cff%s%d|r|cffFFFFFF - |r|cffFFF468%d|r', guild, XF.Player.Faction:GetHex(), chat, bnet)
	XFO.DTLinks:GetBroker().text = text
end
--#endregion

--#region OnEnter
function XFC.DTLinks:OnEnter(this)
	if(not XF.Initialized) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	local tarCount = XFO.Targets:Count() + 1
	
	if XF.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XF.Lib.QT:Acquire(ObjectName, tarCount)
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTLinks:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	local guildName = XFO.Confederate:Name()
	self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], guildName), self.headerFont, 'LEFT', tarCount)
	line = self.tooltip:AddLine()
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	local columns = {}
	for _, target in XFO.Targets:Iterator() do
		table.insert(columns, target:Guild():Initials())
	end
	sort(columns, function(a, b) return a < b end)

	local targetColumn = {
		Player = 1
	}
	self.tooltip:SetCell(line, 1, XF.Lib.Locale['PLAYER'])
	local i = 2
	for _, column in ipairs(columns) do
		self.tooltip:SetCell(line, i, column)
		targetColumn[column] = i
		i = i + 1
	end

	line = self.tooltip:AddLine()
	self.tooltip:AddSeparator()
	line = self.tooltip:AddLine()
	--#endregion

	--#region Populate Table
	if(XF.Initialized) then
		-- Player first
		self.tooltip:SetCell(line, 1, XF.Player.Unit:UnitName(), self.regularFont)
		for _, target in XFO.Targets:Iterator() do
			if(target:IsMyTarget()) then
				self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F%s|r', target:Count()), self.regularFont, 'CENTER')
			elseif(target:Count() > 0) then
				self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cff%s%s|r', XF.Player.Faction:GetHex(), target:Count()), self.regularFont, 'CENTER')
			elseif(target:LinkCount() > 0) then
			 	self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFF468%s|r', target:LinkCount()), self.regularFont, 'CENTER')
			else
				self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFFFFF0|r'), self.regularFont, 'CENTER')
			end
		end

		line = self.tooltip:AddLine()
		self.tooltip:AddSeparator()
		line = self.tooltip:AddLine()

		local units = {}
		for _, unit in XFO.Confederate:Iterator() do
			if(not unit:IsPlayer() and unit:IsOnline() and unit:IsRunningAddon()) then
				units[unit:UnitName()] = unit
			end
		end

		for unitName, unit in PairsByKeys(units) do
			line = self.tooltip:AddLine()
			self.tooltip:SetCell(line, 1, unitName, self.regularFont)
			for _, target in XFO.Targets:Iterator() do
				if(unit:TargetGuildCount(target:Key()) > 0) then
					self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F%s|r', unit:TargetGuildCount(target:Key())), self.regularFont, 'CENTER')
				elseif(unit:TargetChannelCount(target:Key()) > 0) then
					self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cff%s%s|r', unit:Faction():GetHex(), unit:TargetChannelCount(target:Key())), self.regularFont, 'CENTER')
				elseif(unit:TargetBNetCount(target:Key()) > 0) then
					self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFF468%s|r', unit:TargetBNetCount(target:Key())), self.regularFont, 'CENTER')
				elseif(unit:Target():Equals(target)) then
					self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F0|r'), self.regularFont, 'CENTER')
				else
					self.tooltip:SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFFFFF0|r'), self.regularFont, 'CENTER')
				end
			end
		end
		line = self.tooltip:AddLine()
	end
	--#endregion

	self.tooltip:UpdateScrolling(XF.Config.DataText.Guild.Size)
	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function XFC.DTLinks:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
        return
    else
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion