local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTLinks'
local CombatLockdown = InCombatLockdown

DTLinks = XFC.Object:newChildConstructor()
	
--#region Constructors
function DTLinks:new()
	local object = DTGuild.parent.new(self)
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
function DTLinks:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTLINKS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTLINKS_NAME'],
		    OnEnter = function(this) XF.DataText.Links:OnEnter(this) end,
			OnLeave = function(this) XF.DataText.Links:OnLeave(this) end,
		})
		self.headerFont = CreateFont('headerFont')
		self.headerFont:SetTextColor(0.4,0.78,1)
		self.regularFont = CreateFont('regularFont')
		self.regularFont:SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTLinks:PostInitialize()
	XF.DataText.Links:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Links:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Links:RefreshBroker()
end
--#endregion

--#region Print
function DTLinks:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Accessors
function DTLinks:GetBroker()
	return self.ldbObject
end

function DTLinks:GetHeaderFont()
	return self.headerFont
end

function DTLinks:GetRegularFont()
	return self.regularFont
end

function DTLinks:RefreshBroker()
	local text = ''
	if(XF.Config.DataText.Link.Label) then
		text = XF.Lib.Locale['LINKS'] .. ': '
	end

	local names = {}
	local allianceCount = 0
	local hordeCount = 0

	for _, link in XFO.Links:Iterator() do
		if(names[link:GetFromNode():Name()] == nil) then
			if(link:GetFromNode():GetTarget():GetFaction():IsAlliance()) then
				allianceCount = allianceCount + 1
			else
				hordeCount = hordeCount + 1
			end
			names[link:GetFromNode():Name()] = true
		end
		if(names[link:GetToNode():Name()] == nil) then
			if(link:GetToNode():GetTarget():GetFaction():IsAlliance()) then
				allianceCount = allianceCount + 1
			else
				hordeCount = hordeCount + 1
			end
			names[link:GetToNode():Name()] = true
		end
	end

	if(XF.Config.DataText.Link.Faction) then
		text = format('%s|cffffffff%d|r \(|cff00FAF6%d|r\|||cffFF4700%d|r\)', text, XFO.Links:Count(), allianceCount, hordeCount)
	else
		text = format('%s|cffffffff%d|r', text, XFO.Links:Count())
	end
	XF.DataText.Links:GetBroker().text = text
end
--#endregion

--#region OnEnter
function DTLinks:OnEnter(this)
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
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() DTLinks:OnLeave() end)
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
	self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DTLINKS_HEADER_LINKS'], XFO.Links:Count()), self.headerFont, 'LEFT', tarCount)

	line = self.tooltip:AddLine()
	line = self.tooltip:AddLine()
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	local targetColumn = {}
	local i = 1
	for _, target in XFO.Targets:Iterator() do
		local tarName = format('%s%s', format(XF.Icons.String, target:GetFaction():IconID()), target:GetRealm():Name())
		self.tooltip:SetCell(line, i, tarName)
		targetColumn[target:Key()] = i
		i = i + 1
	end

	line = self.tooltip:AddLine()
	self.tooltip:AddSeparator()
	line = self.tooltip:AddLine()
	--#endregion

	--#region Populate Table
	if(XF.Initialized) then
		for _, link in XFO.Links:Iterator() do
			local fromName = format('|cffffffff%s|r', link:GetFromNode():Name())
			if(link:IsMyLink() and link:GetFromNode():IsMyNode()) then
				fromName = format('|cffffff00%s|r', link:GetFromNode():Name())
			end

			local toName = format('|cffffffff%s|r', link:GetToNode():Name())
			if(link:IsMyLink() and link:GetToNode():IsMyNode()) then
				toName = format('|cffffff00%s|r', link:GetToNode():Name())
			end

			self.tooltip:SetCell(line, targetColumn[link:GetFromNode():GetTarget():Key()], fromName, self.regularFont)
			self.tooltip:SetCell(line, targetColumn[link:GetToNode():GetTarget():Key()], toName, self.regularFont)
			
			line = self.tooltip:AddLine()
		end
	end
	--#endregion

	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function DTLinks:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
        return
    else
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion