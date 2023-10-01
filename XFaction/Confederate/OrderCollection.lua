local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderCollection'
local IsItemCached = C_Item.IsItemDataCachedByID
local RequestItemCached = C_Item.RequestLoadItemDataByID

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

--#region Accessors
function OrderCollection:HasPending()
	for _, order in self:Iterator() do
		if(not order:HasItemLink()) then
			return true
		end
	end
	return false
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
		if(order:IsGuild() or (order:IsPersonal() and XFG.Player.Unit:Equals(order:GetCustomerUnit()))) then
			self:Add(order)
			if(IsItemCached(order:GetItemID())) then
				local item = Item:CreateFromItemID(order:GetItemID())
				order:SetItemLink(item:GetItemLink())
				order:SetItemIcon(item:GetItemIcon())
				order:Display()
			else
				XFG:Debug(ObjectName, 'Requesting item from server: %d', order:GetItemID())
				XFG.Events:Get('ItemLoaded'):Start()
				RequestItemCached(order:GetItemID())
			end
		else
			self:Push(order)
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