local XFG, G = unpack(select(2, ...))
local ObjectName = 'OrderCollection'

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
	local orders = string.Split(inData, ';')
    for _, serializedOrder in pairs (orders) do
		local order = nil
    	try(function ()
			order = XFG.Orders:Pop()
			order:Deserialize(serializedOrder)
			self:Add(order)
		end).
		catch(function ()
			XFG.Orders:Push(order)
		end)
    end
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