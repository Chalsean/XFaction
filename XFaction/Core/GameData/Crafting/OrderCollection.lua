local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'OrderCollection'

XFC.OrderCollection = XFC.Factory:newChildConstructor()

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

--#region System
function XFC.OrderCollection:Backup()
	try(function ()
        if(self:IsInitialized()) then
            for _, order in self:Iterator() do
				XF.Cache.Backup.Orders[order:Key()] = order:Encode(true)
            end
        end
    end).
    catch(function (inErrorMessage)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create item backup before reload: ' .. inErrorMessage
    end)
end

function XFC.OrderCollection:Restore()
	if(XF.Cache.Backup.Orders == nil) then XF.Cache.Backup.Orders = {} end
	for key, data in pairs (XF.Cache.Backup.Orders) do
		local order = nil
        try(function ()
            order = self:Pop()
			order:Decode(data)
			self:Add(order)
			XF:Info(self:ObjectName(), '  Restored %s order information from backup', order:Key())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
			self:Push(order)
        end)
    end
    XF.Cache.Backup.Orders = {}
end
--#endregion