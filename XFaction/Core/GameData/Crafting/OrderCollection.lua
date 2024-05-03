local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'OrderCollection'

XFC.OrderCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.OrderCollection:new()
	local object = XFC.OrderCollection.parent.new(self)
	object.__name = ObjectName
    object.firstQuery = true
    return object
end

function XFC.OrderCollection:NewObject()
	return XFC.Order:new()
end
--#endregion

--#region Properties
function XFC.OrderCollection:IsFirstQuery(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.firstQuery = inBoolean
    end    
    return self.firstQuery
end
--#endregion

--#region Methods
function XFC.OrderCollection:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message', 'ProcessMessage method requires Message object as parameter')
    if(XFO.WoW:IsRetail()) then
        local order = nil
        try(function ()
            order = self:Pop()
            order:Deserialize(inMessage:Data())
            XFO.SystemFrame:DisplayOrder(order, inMessage:Faction(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild())
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)            
        end).
        finally(function()
            self:Push(order)
        end)
    end
end

function XFC.OrderCollection:Backup()
	try(function ()
        if(self:IsInitialized()) then
            for _, order in self:Iterator() do
				XF.Cache.Backup.Orders[order:Key()] = order:Serialize()
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
			order:Deserialize(data)
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