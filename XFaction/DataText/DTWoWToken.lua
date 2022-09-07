local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTToken'
local GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice
local CombatLockdown = InCombatLockdown

DTToken = Object:newChildConstructor()
local Events = { 'PLAYER_ENTERING_WORLD', 'PLAYER_LOGIN', 'TOKEN_MARKET_PRICE_UPDATED' }

--#region Constructors
function DTToken:new()
	local object = DTGuild.parent.new(self)
    object.__name = ObjectName
    object.ldbObject = nil
	object.price = 0    
    return object
end
--#endregion

--#region Initializers
function DTToken:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTTOKEN_NAME'])
		for _, event in ipairs (Events) do
			XFG.Events:Add('DTToken' .. event, event, XFG.DataText.Token.OnEvent)
			XFG:Info(ObjectName, 'Registered for %s events', event)
		end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Print
function DTToken:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  price (' .. type(self.price) .. '): ' .. tostring(self.price))
		XFG:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	end
end
--#endregion

--#region Accessors
function DTToken:GetPrice()
	return self.price
end

function DTToken:SetPrice(inPrice)
	assert(type(inPrice) == 'number')
	self.price = inPrice
end
--#endregion

--#region OnEvent
function DTToken:OnEvent(inEvent)
	local broker = XFG.Lib.Broker:GetDataObjectByName(XFG.Lib.Locale['DTTOKEN_NAME'])
	local price = GetCurrentMarketPrice()
	if(price ~= nil) then
		price = floor(price / 10000)
		if(XFG.DataText.Token:GetPrice() ~= price) then
			XFG.DataText.Token:SetPrice(price)
 			XFG:Info(ObjectName, format("New token price [%d]", XFG.DataText.Token:GetPrice()))
	 		local text = format('%s %s %s', format(XFG.Icons.String, XFG.Icons.WoWToken), FormatCurrency(XFG.DataText.Token:GetPrice()), XFG.Icons.Gold)
			broker.text = text
		end
	 end
end
--#endregion

--#region OnClick
function DTToken:OnClick(self, inButton)
	if CombatLockdown() then return end
	if(inButton == 'LeftButton') then
		ToggleStoreUI()
		TokenFrame_LoadUI()
	end
end
--#endregion