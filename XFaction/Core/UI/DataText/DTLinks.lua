local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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
	object.links = nil
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
		self.links = {}
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFC.DTLinks:PostInitialize()
	local self = XFO.DTLinks
	self:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RefreshBroker()
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

function XFC.DTLinks:AddLink()

end

function XFC.DTLinks:RemoveLink()

end

function XFC.DTLinks:RefreshBroker()
	local text = ''
	if(XF.Config.DataText.Link.Label) then
		text = XF.Lib.Locale['LINKS'] .. ': '
	end

	local names = {}
	local hordeCount = 0
	local allianceCount = 0

	-- FIX
	-- for _, link in XFO.Links:Iterator() do
	-- 	if(names[link:From():Name()] == nil) then
	-- 		if(link:From():Race():Faction():IsAlliance()) then
	-- 			allianceCount = allianceCount + 1
	-- 		else
	-- 			hordeCount = hordeCount + 1
	-- 		end
	-- 		names[link:From():Name()] = true
	-- 	end
	-- 	if(names[link:To():Name()] == nil) then
	-- 		if(link:To():Race():Faction():IsAlliance()) then
	-- 			allianceCount = allianceCount + 1
	-- 		else
	-- 			hordeCount = hordeCount + 1
	-- 		end
	-- 		names[link:To():Name()] = true
	-- 	end
	-- end

	-- if(XF.Config.DataText.Link.Faction) then
	-- 	text = format('%s|cffffffff%d|r \(|cff00FAF6%d|r\|||cffFF4700%d|r\)', text, XFO.Links:Count(), allianceCount, hordeCount)
	-- else
		text = format('%s|cffffffff%d|r', text, #self.links)
	-- end
	self:GetBroker().text = text
end
--#endregion

--#region OnEnter
function XFC.DTLinks:OnEnter(this)
	if(not XF.Initialized) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	local targetCount = XFO.Targets:Count() + 1
	
	if XF.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XF.Lib.QT:Acquire(ObjectName, targetCount)
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
	-- local line = self.tooltip:AddLine()
	-- local guildName = XFO.Confederate:Name()
	-- self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], guildName), self.headerFont, 'LEFT', targetCount)
	-- line = self.tooltip:AddLine()
	-- self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DTLINKS_HEADER_LINKS'], XFO.Links:Count()), self.headerFont, 'LEFT', targetCount)

	-- line = self.tooltip:AddLine()
	-- line = self.tooltip:AddLine()
	-- line = self.tooltip:AddHeader()
	-- --#endregion

	-- --#region Column Headers
	-- local targetColumn = {}
	-- local i = 1
	-- for _, target in XFO.Targets:Iterator() do
	-- 	local targetName = format('%s%s', format(XF.Icons.String, target:Faction():IconID()), target:Realm():Name())
	-- 	self.tooltip:SetCell(line, i, targetName)
	-- 	targetColumn[target:Key()] = i
	-- 	i = i + 1
	-- end

	-- line = self.tooltip:AddLine()
	-- self.tooltip:AddSeparator()
	-- line = self.tooltip:AddLine()
	-- --#endregion

	-- --#region Populate Table
	-- if(XF.Initialized) then
	-- 	for _, link in XFO.Links:Iterator() do
	-- 		local fromName = format('|cffffffff%s|r', link:From():Name())
	-- 		if(link:From():IsPlayer()) then
	-- 			fromName = format('|cffffff00%s|r', link:From():Name())
	-- 		end

	-- 		local toName = format('|cffffffff%s|r', link:To():Name())
	-- 		if(link:To():IsPlayer()) then
	-- 			toName = format('|cffffff00%s|r', link:To():Name())
	-- 		end

	-- 		self.tooltip:SetCell(line, targetColumn[link:From():Target():Key()], fromName, self.regularFont)
	-- 		self.tooltip:SetCell(line, targetColumn[link:To():Target():Key()], toName, self.regularFont)
			
	-- 		line = self.tooltip:AddLine()
	-- 	end
	-- end
	--#endregion

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