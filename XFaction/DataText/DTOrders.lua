local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTOrders'
local CombatLockdown = InCombatLockdown

DTOrders = Object:newChildConstructor()
local LDB_ANCHOR

--#region Constructors
function DTOrders:new()
	local object = DTOrders.parent.new(self)
    object.__name = ObjectName
	object.headerFont = nil
	object.regularFont = nil
	object.ldbObject = nil
	object.tooltip = nil
	object.isReverseSort = false
	object.sortColumn = nil    
    return object
end
--#endregion

--#region Initializers
function DTOrders:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTORDERS_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTORDERS_NAME'],
		    OnEnter = function(this) XFG.DataText.Orders:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Orders:OnLeave(this) end,
			OnClick = function(this, button) XFG.DataText.Orders:OnClick(this, button) end,
		})
		LDB_ANCHOR = self.ldbObject
		self.headerFont = CreateFont('headerFont')
		self.headerFont:SetTextColor(0.4,0.78,1)
		self.regularFont = CreateFont('regularFont')
		self.regularFont:SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTOrders:PostInitialize()
	XFG.DataText.Orders:GetHeaderFont():SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	XFG.DataText.Orders:GetRegularFont():SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	XFG.DataText.Orders:RefreshBroker()
end
--#endregion

--#region Print
function DTOrders:Print()
	self:ParentPrint()
	XFG:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XFG:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XFG:Debug(ObjectName, '  isReverseSort (' .. type(self.isReverseSort) .. '): ' .. tostring(self.isReverseSort))
	XFG:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XFG:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Accessors
function DTOrders:GetBroker()
	return self.ldbObject
end

function DTOrders:GetHeaderFont()
	return self.headerFont
end

function DTOrders:GetRegularFont()
	return self.regularFont
end

function DTOrders:RefreshBroker()
	if(XFG.Initialized) then
		local text = ''  
		-- if(XFG.Config.DataText.Guild.Label) then
		-- 	text = XFG.Lib.Locale['GUILD'] .. ': '
		-- end
		text = format('%s|cff3CE13F%d', text, XFG.Orders:GetCount())
		XFG.DataText.Orders:GetBroker().text = text
	end
end
--#endregion

--#region Sorting
function DTOrders:IsReverseSort(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self.isReverseSort = inBoolean
	end
	return self.isReverseSort
end

function DTOrders:GetSort()
	return self.sortColumn == nil and self:SetSort(XFG.Config.DataText.Orders.Sort) or self.sortColumn
end

function DTOrders:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self.sortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local list = {}
	for _, order in XFG.Orders:Iterator() do
		local orderData = {}
		if(order:HasProfession()) then
			orderData.Profession = order:GetProfession():GetIconID()
		end
		orderData.Guild = order:GetCustomerGuild():GetName()
		orderData.Customer = order:GetCustomerName()
		if(order:HasCustomer()) then
			orderData.Class = order:GetCustomer():GetClass():GetHex()
			if(order:GetCustomer():IsAlt() and order:GetCustomer():HasMainName() and XFG.Config.DataText.Orders.Main) then
				orderData.Customer = order:GetCustomer():GetName() .. ' (' .. order:GetCustomer():GetMainName() .. ')'
			end
		end

		list[#list + 1] = orderData
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	if(XFG.DataText.Orders:GetSort() == inColumnName and XFG.DataText.Orders:IsReverseSort()) then
		XFG.DataText.Orders:IsReverseSort(false)
	elseif(XFG.DataText.Orders:GetSort() == inColumnName) then
		XFG.DataText.Orders:IsReverseSort(true)
	else
		XFG.DataText.Orders:SetSort(inColumnName)
		XFG.DataText.Orders:IsReverseSort(false)
	end
	XFG.DataText.Orders:OnEnter(LDB_ANCHOR)
end
--#endregion

--#region OnEnter
local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XFG.Confederate:Get(inUnitGUID)
	local link = unit:GetLink()
	if(link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(unit:GetUnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(unit:GetUnitName())
 	elseif(inMouseButton == 'LeftButton' or inMouseButton == 'RightButton') then
		SetItemRef(link, unit:GetName(), inMouseButton)
	end
end

function DTOrders:OnEnter(this)
	if(not XFG.Initialized) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	local orderEnabled = {}
	XFG.Cache.DTOrdersTotalEnabled = 0
	XFG.Cache.DTOrdersTextEnabled = 0
	for columnName, isEnabled in pairs (XFG.Config.DataText.Orders.Enable) do
		if(isEnabled) then
			local orderKey = columnName .. 'Order'
			local alignmentKey = columnName .. 'Alignment'

			if(XFG.Config.DataText.Orders.Order[orderKey] ~= 0) then
				XFG.Cache.DTOrdersTotalEnabled = XFG.Cache.DTOrdersTotalEnabled + 1
				local index = tostring(XFG.Config.DataText.Orders.Order[orderKey])
				orderEnabled[index] = {
					ColumnName = columnName,
					Alignment = string.upper(XFG.Config.DataText.Orders.Alignment[alignmentKey]),
					Icon = (columnName == 'Profession' or columnName == 'Faction'),
				}
				if(not orderEnabled[index].Icon) then
					XFG.Cache.DTOrdersTextEnabled = XFG.Cache.DTOrdersTextEnabled + 1
				end
			end
		end		
	end
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName)

		for i = 1, XFG.Cache.DTOrdersTotalEnabled do
			self.tooltip:AddColumn(orderEnabled[tostring(i)].Alignment)
		end
		
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() DTOrders:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
		self.tooltip:SetFrameStrata('FULLSCREEN_DIALOG')
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	
	if(XFG.Config.DataText.Orders.GuildName and XFG.Cache.DTOrdersTotalEnabled > 4) then
		local guildName = XFG.Player.Guild:GetName()
		guildName = guildName .. ' <' .. XFG.Player.Guild:GetInitials() .. '>'
		self.tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_GUILD'], guildName), self.headerFont, 'LEFT', 4)
	end

	if(XFG.Config.DataText.Orders.Confederate and XFG.Cache.DTOrdersTotalEnabled > 8) then
		self.tooltip:SetCell(line, 6, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], XFG.Confederate:GetName()), self.headerFont, 'LEFT', -1)	
	end

	if(XFG.Config.DataText.Orders.GuildName or XFG.Config.DataText.Orders.Confederate) then
		line = self.tooltip:AddLine()
		self.tooltip:AddSeparator()
		line = self.tooltip:AddLine()		
	end

	line = self.tooltip:AddLine()	
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	for i = 1, XFG.Cache.DTOrdersTotalEnabled do
		local columnName = orderEnabled[tostring(i)].ColumnName
		if(not orderEnabled[tostring(i)].Icon) then
			line = self.tooltip:SetCell(line, i, XFG.Lib.Locale[string.upper(columnName)], self.headerFont, 'CENTER')
		end
		self.tooltip:SetCellScript(line, i, 'OnMouseUp', SetSortColumn, columnName)
	end
	self.tooltip:AddSeparator()
	--#endregion

	--#region Populate Table
	if(XFG.Initialized) then

		local list = PreSort()
		sort(list, function(a, b) if(XFG.DataText.Orders:IsReverseSort()) then return a[XFG.DataText.Orders:GetSort()] > b[XFG.DataText.Orders:GetSort()] 
																	      else return a[XFG.DataText.Orders:GetSort()] < b[XFG.DataText.Orders:GetSort()] end end)

		for _, orderData in ipairs (list) do
			line = self.tooltip:AddLine()

			for i = 1, XFG.Cache.DTOrdersTotalEnabled do
				local columnName = orderEnabled[tostring(i)].ColumnName
				local cellValue = ''
				if(orderEnabled[tostring(i)].Icon) then
					if(columnName == 'Profession') then
						if(orderData.Profession ~= nil) then
							cellValue = format('%s', format(XFG.Icons.String, orderData.Profession))
						end
					elseif(orderData[columnName] ~= nil) then
						cellValue = format('%s', format(XFG.Icons.String, orderData[columnName]))
					end
				elseif(columnName == 'Customer') then
					cellValue = format('|c%s%s|r', orderData.Class, orderData.Customer)
				elseif(orderData[columnName] ~= nil) then
					cellValue = format('|cffffffff%s|r', orderData[columnName])
				end
				self.tooltip:SetCell(line, i, cellValue, self.regularFont)
			end

			self.tooltip:SetLineScript(line, "OnMouseUp", LineClick, orderData.GUID)
		end
	end
	--#endregion

	--self.tooltip:UpdateScrolling(XFG.Config.DataText.Guild.Size)
	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function DTOrders:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
	    return
	else
        XFG.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion

--#region OnClick
function DTOrders:OnClick(this, inButton)
	if(InCombatLockdown()) then return end
	if(inButton == 'LeftButton') then
		ToggleGuildFrame()
	elseif(inButton == 'RightButton') then
		if not InterfaceOptionsFrame or not InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Show()
			InterfaceOptionsFrame_OpenToCategory(XFG.Name)
		else
			InterfaceOptionsFrame:Hide()
		end
	end
end
--#endregion