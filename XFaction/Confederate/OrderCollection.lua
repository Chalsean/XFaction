local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderCollection'
local GetItemInformation = GetItemInfo

OrderCollection = Factory:newChildConstructor()

--#region Constructors
function OrderCollection:new()
	local object = OrderCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function OrderCollection:NewObject()
	return Order:new()
end
--#endregion

--#region Initializers
function OrderCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Networking
function OrderCollection:Encode()
	local encoded = ""
	for _, order in self:Iterator() do
		if(order:IsMyOrder()) then
			encoded = encoded .. ';' .. order:Serialize()
		end
	end
	return encoded
end

function OrderCollection:Decode(inData)
	local order = nil
	try(function ()
		order = self:Pop()
		order:Decode(inData)
		self:Add(order)
		order:Print()
		-- Notify player of new crafting order
		if(XFG.Config.Chat.Crafting.Enable) then
			local name = ''
			if(XFG.Config.Chat.Crafting.Faction) then  
				name = format('%s ', format(XFG.Icons.String, order:GetCustomerUnit():GetFaction():GetIconID()))
			end
			name = name .. order:GetCustomerName()
			if(XFG.Config.Chat.Crafting.Main and order:HasCustomerUnit() and order:GetCustomerUnit():IsAlt()) then
				name = name .. ' (' .. order:GetCustomerUnit():GetMainName() .. ')'
			end
			name = format('|c%s%s|r', order:GetCustomerClass():GetHex(), name)
			local _, itemLink, itemQuality = GetItemInformation(order:GetItemID())
			local guild = order:GetCustomerUnit():GetGuild():GetName()
			if(XFG.Config.Chat.Crafting.Realm) then
				guild = guild .. ' (' .. order:GetCustomerUnit():GetGuild():GetRealm():GetName() .. ')'
			end
			print(format(XFG.Lib.Locale['NEW_CRAFTING_ORDER'], XFG.Title, name, itemLink, guild))
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
		self:Push(order)
	end)
end

function OrderCollection:Broadcast()
    local message = nil
    try(function ()
        message = XFG.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetFrom(XFG.Player.Unit:GetGUID())
        message:SetGuild(XFG.Player.Guild)
        message:SetUnitName(XFG.Player.Unit:GetUnitName())
        message:SetType(XFG.Enum.Network.BROADCAST)
        message:SetSubject(XFG.Enum.Message.ORDER)
        message:SetData(self:Encode())
        XFG.Mailbox.Chat:Send(message)
    end).
    finally(function ()
        XFG.Mailbox.Chat:Push(message)
    end)
end
--#endregion