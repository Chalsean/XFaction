local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local _G = _G
local LogCategory = 'DTToken'

local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local IconTokenString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local IconTokenNumber = 1121394
local IconGold = E:TextureString(E.Media.Textures.Coins, ':14:14:0:0:64:32:22:42:1:20')
local TokenPrice = 0

local function OnEvent(self, event, ...)

	if (not self.text) then
		local text = self:CreateFontString(nil, 'OVERLAY')
		text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
		local formattedText = format('%s', format(IconTokenString, IconTokenNumber))
		text:SetFormattedText(formattedText)
		self.text = text
	end
	
	XFG:Debug(LogCategory, format("Checking token price due to event [%s]", event))
	local price = C_WowTokenPublic.GetCurrentMarketPrice()
	if(price ~= nil and (TokenPrice ~= price or event == 'ELVUI_FORCE_UPDATE')) then
		if(TokenPrice ~= price) then
			TokenPrice = price
			XFG:Info(LogCategory, format("New token price [%d]", TokenPrice))	
		end
		local gold = floor(TokenPrice / 10000)
		local goldText = E:FormatLargeNumber(gold, ",") .. " " .. IconGold
		local formattedText = format('%s %s', format(IconTokenString, IconTokenNumber), goldText)
		self.text:SetFormattedText(formattedText)
	end
end

local function OnClick(self, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if button == "LeftButton" then
		ToggleStoreUI()
		TokenFrame_LoadUI()
	elseif button == "RightButton" then
		--C_WowTokenUI.StartTokenSell()
	end
end

local events = {
	'PLAYER_ENTERING_WORLD',
	'PLAYER_LOGIN',
	'TOKEN_MARKET_PRICE_UPDATED',
	'ELVUI_FORCE_UPDATE'
}

DT:RegisterDatatext('WoW Token (X)', XFG.Category, events, OnEvent, nil, OnClick)