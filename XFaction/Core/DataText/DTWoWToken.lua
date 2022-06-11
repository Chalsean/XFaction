local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTToken'
local LogCategory = 'DTToken'

DTToken = {}

function DTToken:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
	self._Price = 0
    
    return _Object
end

function DTToken:Initialize()
	if(self:IsInitialized() == false) then
		--self:SetKey(math.GenerateUID())      
		XFG.Lib.Broker:NewDataObject(XFG.DataText.Token.BrokerName)
		for _, _Event in ipairs (XFG.DataText.Token.Events) do
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
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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

	local _Broker = XFG.Lib.Broker:GetDataObjectByName(XFG.DataText.Token.BrokerName)
	XFG:Debug(LogCategory, 'Checking token price due to event ' .. tostring(inEvent))
	local _Price = C_WowTokenPublic.GetCurrentMarketPrice()
	if(_Price ~= nil and self._Price ~= _Price) then
		XFG.DataText.Token.Broker:SetPrice(floor(_Price / 10000))
 		XFG:Info(LogCategory, format("New token price [%d]", self._Price))
	 	local _Text = format('%s %s', format(XFG.Icons.String, XFG.Icons.WoWToken), XFG.DataText.Token.Broker:GetPrice())
		_Broker.text = _Text
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