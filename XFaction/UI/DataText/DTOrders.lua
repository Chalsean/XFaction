local XF, G = unpack(select(2, ...))
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
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTORDERS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTORDERS_NAME'],
		    OnEnter = function(this) XF.DataText.Orders:OnEnter(this) end,
			OnLeave = function(this) XF.DataText.Orders:OnLeave(this) end,
			OnClick = function(this, button) XF.DataText.Orders:OnClick(this, button) end,
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
	XF.DataText.Orders:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Orders:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Orders:RefreshBroker()
end
--#endregion

--#region Print
function DTOrders:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  isReverseSort (' .. type(self.isReverseSort) .. '): ' .. tostring(self.isReverseSort))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
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
	if(XF.Initialized) then
		local text = ''  
		-- if(XF.Config.DataText.Guild.Label) then
		-- 	text = XF.Lib.Locale['GUILD'] .. ': '
		-- end
		text = format('%s|cff3CE13F%d', text, XF.Orders:GetCount())
		XF.DataText.Orders:GetBroker().text = text
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
	return self.sortColumn == nil and self:SetSort(XF.Config.DataText.Orders.Sort) or self.sortColumn
end

function DTOrders:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self.sortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local list = {}
	for _, order in XF.Orders:Iterator() do
		local orderData = {}
		if(order:HasProfession()) then
			orderData.Profession = order:GetProfession():GetIconID()
		end
		orderData.Guild = order:GetCustomerGuild():GetName()
		orderData.Customer = order:GetCustomerName()
		if(order:HasCustomer()) then
			orderData.Class = order:GetCustomer():GetClass():GetHex()
			if(order:GetCustomer():IsAlt() and order:GetCustomer():HasMainName() and XF.Config.DataText.Orders.Main) then
				orderData.Customer = order:GetCustomer():GetName() .. ' (' .. order:GetCustomer():GetMainName() .. ')'
			end
		end

		list[#list + 1] = orderData
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	if(XF.DataText.Orders:GetSort() == inColumnName and XF.DataText.Orders:IsReverseSort()) then
		XF.DataText.Orders:IsReverseSort(false)
	elseif(XF.DataText.Orders:GetSort() == inColumnName) then
		XF.DataText.Orders:IsReverseSort(true)
	else
		XF.DataText.Orders:SetSort(inColumnName)
		XF.DataText.Orders:IsReverseSort(false)
	end
	XF.DataText.Orders:OnEnter(LDB_ANCHOR)
end
--#endregion

--#region OnEnter
local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XF.Confederate:Get(inUnitGUID)
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
	if(not XF.Initialized) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	local orderEnabled = {}
	XF.Cache.DTOrdersTotalEnabled = 0
	XF.Cache.DTOrdersTextEnabled = 0
	for columnName, isEnabled in pairs (XF.Config.DataText.Orders.Enable) do
		if(isEnabled) then
			local orderKey = columnName .. 'Order'
			local alignmentKey = columnName .. 'Alignment'

			if(XF.Config.DataText.Orders.Order[orderKey] ~= 0) then
				XF.Cache.DTOrdersTotalEnabled = XF.Cache.DTOrdersTotalEnabled + 1
				local index = tostring(XF.Config.DataText.Orders.Order[orderKey])
				orderEnabled[index] = {
					ColumnName = columnName,
					Alignment = string.upper(XF.Config.DataText.Orders.Alignment[alignmentKey]),
					Icon = (columnName == 'Profession' or columnName == 'Faction'),
				}
				if(not orderEnabled[index].Icon) then
					XF.Cache.DTOrdersTextEnabled = XF.Cache.DTOrdersTextEnabled + 1
				end
			end
		end		
	end
	
	if XF.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)

		for i = 1, XF.Cache.DTOrdersTotalEnabled do
			self.tooltip:AddColumn(orderEnabled[tostring(i)].Alignment)
		end
		
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() DTOrders:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
		self.tooltip:SetFrameStrata('FULLSCREEN_DIALOG')
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	
	if(XF.Config.DataText.Orders.GuildName and XF.Cache.DTOrdersTotalEnabled > 4) then
		local guildName = XF.Player.Guild:GetName()
		guildName = guildName .. ' <' .. XF.Player.Guild:GetInitials() .. '>'
		self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_GUILD'], guildName), self.headerFont, 'LEFT', 4)
	end

	if(XF.Config.DataText.Orders.Confederate and XF.Cache.DTOrdersTotalEnabled > 8) then
		self.tooltip:SetCell(line, 6, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XF.Confederate:GetName()), self.headerFont, 'LEFT', -1)	
	end

	if(XF.Config.DataText.Orders.GuildName or XF.Config.DataText.Orders.Confederate) then
		line = self.tooltip:AddLine()
		self.tooltip:AddSeparator()
		line = self.tooltip:AddLine()		
	end

	line = self.tooltip:AddLine()	
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	for i = 1, XF.Cache.DTOrdersTotalEnabled do
		local columnName = orderEnabled[tostring(i)].ColumnName
		if(not orderEnabled[tostring(i)].Icon) then
			line = self.tooltip:SetCell(line, i, XF.Lib.Locale[string.upper(columnName)], self.headerFont, 'CENTER')
		end
		self.tooltip:SetCellScript(line, i, 'OnMouseUp', SetSortColumn, columnName)
	end
	self.tooltip:AddSeparator()
	--#endregion

	--#region Populate Table
	if(XF.Initialized) then

		local list = PreSort()
		sort(list, function(a, b) if(XF.DataText.Orders:IsReverseSort()) then return a[XF.DataText.Orders:GetSort()] > b[XF.DataText.Orders:GetSort()] 
																	      else return a[XF.DataText.Orders:GetSort()] < b[XF.DataText.Orders:GetSort()] end end)

		for _, orderData in ipairs (list) do
			line = self.tooltip:AddLine()

			for i = 1, XF.Cache.DTOrdersTotalEnabled do
				local columnName = orderEnabled[tostring(i)].ColumnName
				local cellValue = ''
				if(orderEnabled[tostring(i)].Icon) then
					if(columnName == 'Profession') then
						if(orderData.Profession ~= nil) then
							cellValue = format('%s', format(XF.Icons.String, orderData.Profession))
						end
					elseif(orderData[columnName] ~= nil) then
						cellValue = format('%s', format(XF.Icons.String, orderData[columnName]))
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

	--self.tooltip:UpdateScrolling(XF.Config.DataText.Guild.Size)
	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function DTOrders:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
	    return
	else
        XF.Lib.QT:Release(self.tooltip)
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
			InterfaceOptionsFrame_OpenToCategory(XF.Name)
		else
			InterfaceOptionsFrame:Hide()
		end
	end
end
--#endregion