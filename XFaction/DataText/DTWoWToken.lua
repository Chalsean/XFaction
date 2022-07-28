local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTToken'
local LogCategory = 'DTToken'

DTToken = {}
local Events = { 'PLAYER_ENTERING_WORLD', 'PLAYER_LOGIN', 'TOKEN_MARKET_PRICE_UPDATED' }

function DTToken:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
	self._LDBObject = nil
	self._Price = 0
    
    return _Object
end

function DTToken:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())      
		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTTOKEN_NAME'])
		for _, _Event in ipairs (Events) do
			XFG:RegisterEvent(_Event, self.OnEvent)
			XFG:Info(LogCategory, "Registered for %s events", _Event)
		end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTToken:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTToken:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _Price (" .. type(self._Price) .. "): ".. tostring(self._Price))
	XFG:Debug(LogCategory, "  _LDBObject (" .. type(self._LDBObject) .. ")")
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTToken:GetKey()
	return self._Key
end

function DTToken:SetKey(inKey)
	assert(type(inKey) == 'string')
	self._Key = inKey
	return self:GetKey()
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
	local _Price = C_WowTokenPublic.GetCurrentMarketPrice()
	if(_Price ~= nil) then
		_Price = floor(_Price / 10000)
		if(XFG.DataText.Token:GetPrice() ~= _Price) then
			XFG.DataText.Token:SetPrice(_Price)
 			XFG:Info(LogCategory, format("New token price [%d]", XFG.DataText.Token:GetPrice()))
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
	elseif button == "RightButton" then
		--C_WowTokenUI.StartTokenSell()
	end
end