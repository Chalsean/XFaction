local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
function XFC.OrderCollection:Backup()
	try(function ()
        if(self:IsInitialized()) then
            for _, order in self:Iterator() do
				XF.Cache.Backup.Orders[order:Key()] = order:Encode(true)
            end
        end
    end).
    catch(function (err)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create item backup before reload: ' .. err
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
        catch(function (err)
            XF:Warn(ObjectName, err)
			self:Push(order)
        end)
    end
    XF.Cache.Backup.Orders = {}
end
--#endregion