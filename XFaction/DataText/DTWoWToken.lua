local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTToken'

local GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice

DTToken = Object:newChildConstructor()
local Events = { 'PLAYER_ENTERING_WORLD', 'PLAYER_LOGIN', 'TOKEN_MARKET_PRICE_UPDATED' }

function DTToken:new()
	local _Object = DTGuild.parent.new(self)
    _Object.__name = ObjectName
    _Object._LDBObject = nil
	_Object._Price = 0    
    return _Object
end

function DTToken:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTTOKEN_NAME'])
		for _, _Event in ipairs (Events) do
			XFG.Events:Add('DTToken' .. _Event, _Event, XFG.DataText.Token.OnEvent)
			XFG:Info(ObjectName, "Registered for %s events", _Event)
		end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTToken:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, "  _Price (" .. type(self._Price) .. "): ".. tostring(self._Price))
		XFG:Debug(ObjectName, "  _LDBObject (" .. type(self._LDBObject) .. ")")
	end
end

function DTToken:GetPrice()
	return self._Price
end

function DTToken:SetPrice(inPrice)
	assert(type(inPrice) == 'number')
	self._Price = inPrice
	return self:GetPrice()
end

function DTToken:OnEvent(inEvent)
	local _Broker = XFG.Lib.Broker:GetDataObjectByName(XFG.Lib.Locale['DTTOKEN_NAME'])
	local _Price = GetCurrentMarketPrice()
	if(_Price ~= nil) then
		_Price = floor(_Price / 10000)
		if(XFG.DataText.Token:GetPrice() ~= _Price) then
			XFG.DataText.Token:SetPrice(_Price)
 			XFG:Info(ObjectName, format("New token price [%d]", XFG.DataText.Token:GetPrice()))
	 		local _Text = format('%s %s %s', format(XFG.Icons.String, XFG.Icons.WoWToken), FormatCurrency(XFG.DataText.Token:GetPrice()), XFG.Icons.Gold)
			_Broker.text = _Text
		end
	 end
end

function DTToken:OnClick(self, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if button == "LeftButton" then
		ToggleStoreUI()
		TokenFrame_LoadUI()
	end
end