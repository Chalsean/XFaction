local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTLinks'
local LogCategory = 'DTLinks'

DTLinks = {}

function DTLinks:new()
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
	self._Count = 0
    
    return _Object
end

function DTLinks:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTLINKS_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTLINKS_NAME'],
		    OnEnter = function(this) XFG.DataText.Links:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Links:OnLeave(this) end,
		})

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTLinks:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTLinks:Print()
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

function DTLinks:CountLinks()
	self._Count =  XFG.Links:GetCount()
end

function DTLinks:RefreshBroker()
	if(XFG.Initialized) then
		self:CountLinks()
		self._LDBObject.text = format('|cffffffff%d', self._Count)
	end
end

function DTLinks:OnEnter(this)
	if(XFG.Initialized == false) then return end

	local _TargetCount = XFG.Targets:GetCount() + 1
	
	local _Tooltip
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, _TargetCount)
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, self._Tooltip)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()

	local line = self._Tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _GuildName), self._HeaderFont, "LEFT", _TargetCount)
	line = self._Tooltip:AddLine()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTLINKS_HEADER_LINKS'], self._Count), self._HeaderFont, "LEFT", _TargetCount)

	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddHeader()

	-- Targets collection does not contain player's current realm/faction
	local _TargetColumn = {}
	local _TargetName = format('%s%s', format(XFG.Icons.String, XFG.Player.Faction:GetIconID()), XFG.Player.Realm:GetName())
	self._Tooltip:SetCell(line, 1, _TargetName)
	local _Key = XFG.Player.Realm:GetID() .. ':' .. XFG.Player.Faction:GetID()
	_TargetColumn[_Key] = 1
	local i = 2

	for _, _Target in XFG.Targets:Iterator() do
		local _Realm = _Target:GetRealm()
		local _Faction = _Target:GetFaction()
		local _TargetName = format('%s%s', format(XFG.Icons.String, _Faction:GetIconID()), _Realm:GetName())
		self._Tooltip:SetCell(line, i, _TargetName)
		_TargetColumn[_Target:GetKey()] = i
		i = i + 1
	end

	line = self._Tooltip:AddLine()
	self._Tooltip:AddSeparator()
	line = self._Tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Link in XFG.Links:Iterator() do
			--if((XFG.Config.DataText.Links.OnlyMine and _Link:IsMyLink()) or XFG.Config.DataText.Links.OnlyMine == false) then
				local _FromRealm = _Link:GetFromRealm()
				local _FromFaction = _Link:GetFromFaction()
				local _ToRealm = _Link:GetToRealm()
				local _ToFaction = _Link:GetToFaction()

				_FromKey = _FromRealm:GetID() .. ':' .. _FromFaction:GetID()
				_ToKey = _ToRealm:GetID() .. ':' .. _ToFaction:GetID()

				local _FromName = format("|cffffffff%s|r", _Link:GetFromName())
				if(_Link:IsMyLink() and _Link:GetFromName() == XFG.Player.Unit:GetName()) then
					_FromName = format("|cffffff00%s|r", _Link:GetFromName())
				end

				local _ToName = format("|cffffffff%s|r", _Link:GetToName())
				if(_Link:IsMyLink() and _Link:GetToName() == XFG.Player.Unit:GetName()) then
					_ToName = format("|cffffff00%s|r", _Link:GetToName())
				end

				self._Tooltip:SetCell(line, _TargetColumn[_FromKey], _FromName)
				self._Tooltip:SetCell(line, _TargetColumn[_ToKey], _ToName)
				
				line = self._Tooltip:AddLine()
			--end
		end
	end

	self._Tooltip:Show()
end

function DTLinks:OnLeave()
	local _IsMouseOver = true
	local _Status, _Error = pcall(function () _IsMouseOver = MouseIsOver(self._Tooltip) end)
	if(_Status and _IsMouseOver == false) then 
		if XFG.Lib.QT:IsAcquired(ObjectName) then self._Tooltip:Clear() end
		self._Tooltip:Hide()
		XFG.Lib.QT:Release(ObjectName)
		self._Tooltip = nil
	end
end