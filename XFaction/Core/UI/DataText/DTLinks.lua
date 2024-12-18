local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTLinks'

XFC.DTLinks = XFC.Object:newChildConstructor()
	
--#region Constructors
function XFC.DTLinks:new()
	local object = XFC.DTLinks.parent.new(self)
    object.__name = ObjectName
    object.headerFont = nil
	object.regularFont = nil
	object.broker = nil
	object.tooltip = nil
    return object
end

function XFC.DTLinks:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:Broker(XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTLINKS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTLINKS_NAME'],
		    OnEnter = function(this) XFO.DTLinks:CallbackOnEnter(this) end,
			OnLeave = function(this) XFO.DTLinks:CallbackOnLeave(this) end,
		}))
		self:HeaderFont(XFF.UICreateFont('headerFont'))
		self:HeaderFont():SetTextColor(0.4,0.78,1)
		self:RegularFont(XFF.UICreateFont('regularFont'))
		self:RegularFont():SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFC.DTLinks:PostInitialize()
	self:HeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RefreshBroker()
end
--#endregion

--#region Properties
function XFC.DTLinks:Broker(inBroker)
	if(inBroker ~= nil) then
		self.broker = inBroker
	end
	return self.broker
end

function XFC.DTLinks:HeaderFont(inFont)
	if(inFont ~= nil) then
		self.headerFont = inFont
	end
	return self.headerFont
end

function XFC.DTLinks:RegularFont(inFont)
	if(inFont ~= nil) then
		self.regularFont = inFont
	end
	return self.regularFont
end

function XFC.DTLinks:Tooltip(inTooltip)
	local self = XFO.DTLinks
	if(inTooltip ~= nil) then
		self.tooltip = inTooltip
	end
	return self.tooltip
end
--#endregion

--#region Methods
function XFC.DTLinks:RefreshBroker()
	local self = XFO.DTLinks
	try(function()
		local text = ''
		if(XF.Config.DataText.Link.Label) then
			text = XF.Lib.Locale['LINKS'] .. ': '
		end

		local chat = 0
		local bnet = 0

		for _, target in XFO.Targets:Iterator() do
			if(not target:IsMyTarget()) then
				chat = chat + target:Count()
			end
			bnet = bnet + target:LinkCount()
		end

		text = format('|cff3CE13F%d|r|cffFFFFFF - |r|cff%s%d|r|cffFFFFFF - |r|cffFFF468%d|r', XFO.Channels:GuildChannel():Count(), XF.Player.Faction:GetHex(), chat, bnet)
		self:Broker().text = text
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.DTLinks:CallbackOnEnter(this)
	local self = XFO.DTLinks
	if(not XF.Initialized) then return end
	if(XFF.PlayerIsInCombat()) then return end

	try(function()

		--#region Configure Tooltip
		local tarCount = XFO.Targets:Count() + 1
		
		if XF.Lib.QT:IsAcquired(ObjectName) then
			self:Tooltip(XF.Lib.QT:Acquire(ObjectName))
		else
			self:Tooltip(XF.Lib.QT:Acquire(ObjectName, tarCount))
			self:Tooltip():SetHeaderFont(self.headerFont)
			self:Tooltip():SetFont(self.regularFont)
			self:Tooltip():SmartAnchorTo(this)
			self:Tooltip():SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTLinks:CallbackOnLeave() end)
			self:Tooltip():EnableMouse(true)
			self:Tooltip():SetClampedToScreen(false)
		end

		self:Tooltip():Clear()
		--#endregion

		--#region Header
		local line = self:Tooltip():AddLine()
		self:Tooltip():SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XFO.Confederate:Name()), self:HeaderFont(), 'LEFT', tarCount)
		line = self:Tooltip():AddLine()
		line = self:Tooltip():AddHeader()
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
		self:Tooltip():SetCell(line, 1, XF.Lib.Locale['PLAYER'])
		local i = 2
		for _, column in ipairs(columns) do
			self:Tooltip():SetCell(line, i, column)
			targetColumn[column] = i
			i = i + 1
		end

		line = self:Tooltip():AddLine()
		self:Tooltip():AddSeparator()
		line = self:Tooltip():AddLine()
		--#endregion

		--#region Populate Table
		if(XF.Initialized) then
			-- Player first
			self:Tooltip():SetCell(line, 1, XF.Player.Unit:UnitName(), self:RegularFont())
			for _, target in XFO.Targets:Iterator() do
				if(target:IsMyTarget()) then
					self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F%s|r', XFO.Channels:GuildChannel():Count()), self:RegularFont(), 'CENTER')
				elseif(target:LinkCount() > 0) then
					self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFF468%s|r', target:LinkCount()), self:RegularFont(), 'CENTER')
				elseif(target:Count() > 0) then
					self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cff%s%s|r', XF.Player.Faction:GetHex(), target:Count()), self:RegularFont(), 'CENTER')				
				else
					self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFFFFF0|r'), self:RegularFont(), 'CENTER')
				end
			end

			line = self:Tooltip():AddLine()
			self:Tooltip():AddSeparator()
			line = self:Tooltip():AddLine()

			local units = {}
			for _, unit in XFO.Confederate:Iterator() do
				if(not unit:IsPlayer() and unit:IsOnline() and unit:IsRunningAddon()) then
					units[unit:UnitName()] = unit
				end
			end

			for unitName, unit in PairsByKeys(units) do
				line = self:Tooltip():AddLine()
				self:Tooltip():SetCell(line, 1, unitName, self:RegularFont())
				for _, target in XFO.Targets:Iterator() do
					if(unit:TargetGuildCount(target:Key()) > 0) then
						self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F%s|r', unit:TargetGuildCount(target:Key())), self:RegularFont(), 'CENTER')
					elseif(unit:TargetBNetCount(target:Key()) > 0) then
						self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFF468%s|r', unit:TargetBNetCount(target:Key())), self:RegularFont(), 'CENTER')
					elseif(unit:TargetChannelCount(target:Key()) > 0) then
						self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cff%s%s|r', unit:Faction():GetHex(), unit:TargetChannelCount(target:Key())), self:RegularFont(), 'CENTER')					
					elseif(unit:Target():Equals(target)) then
						self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cff3CE13F0|r'), self:RegularFont(), 'CENTER')
					else
						self:Tooltip():SetCell(line, targetColumn[target:Guild():Initials()], format('|cffFFFFFF0|r'), self:RegularFont(), 'CENTER')
					end
				end
			end
			line = self:Tooltip():AddLine()
		end
		--#endregion

		self:Tooltip():UpdateScrolling(XF.Config.DataText.Guild.Size)
		self:Tooltip():Show()
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.DTLinks:CallbackOnLeave()
	local self = XFO.DTLinks
	try(function()
		if self:Tooltip() and XFF.UIIsMouseOver(self:Tooltip()) then
			return
		else
			XF.Lib.QT:Release(self:Tooltip())
			self.tooltip = nil
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion