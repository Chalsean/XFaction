local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'OrderCollection'

XFC.OrderCollection = Factory:newChildConstructor()

--#region Constructors
function XFC.OrderCollection:new()
	local object = XFC.OrderCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.OrderCollection:NewObject()
	return XFC.Order:new()
end
--#endregion

--#region Initializers
function XFC.OrderCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.OrderCollection:Display()
	for _, order in self:Iterator() do
		if(not order:IsMyOrder() and not order:HasDisplayed() and order:HasItem() and order:GetItem():IsCached()) then
			order:Display()
		end
	end
end
--#endregion

--#region Networking
function XFC.OrderCollection:Decode(inData)
	local order = nil
	try(function ()
		order = self:Pop()
		order:Decode(inData)
		if(order:IsGuild() or (order:IsPersonal() and XF.Player.Unit:Equals(order:GetCustomerUnit()))) then
			self:Add(order)
		else
			self:Push(order)
		end
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
		self:Push(order)
	end)
end

function XFC.OrderCollection:Broadcast()
    for _, order in self:Iterator() do
		if(order:IsMyOrder() and not order:HasCommunicated()) then
			order:Broadcast()
		end
	end
end
--#endregion

--#region System
function XFC.OrderCollection:Backup()
	try(function ()
        if(self:IsInitialized()) then
            for _, order in self:Iterator() do
				XF.Cache.Backup.Orders[order:GetKey()] = order:Encode()
            end
        end
    end).
    catch(function (inErrorMessage)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create item backup before reload: ' .. inErrorMessage
    end)
end

function XFC.OrderCollection:Restore()
	for key, data in pairs (XF.Cache.Backup.Orders) do
		local order = nil
        try(function ()
            order = self:Pop()
			order:Decode(data)
			self:Add(order)
			XF:Info(self:GetObjectName(), '  Restored %s order information from backup', order:GetKey())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
			self:Push(order)
        end)
    end
    XF.Cache.Backup.Orders = {}
end
--#endregion