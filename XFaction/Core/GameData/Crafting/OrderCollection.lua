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
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.firstQuery = inBoolean
    end    
    return self.firstQuery
end
--#endregion

--#region Methods
function XFC.OrderCollection:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    local order = nil
    try(function ()
        order = self:Pop()
        order:Deserialize(inMessage:Data())
        order:Customer(inMessage:FromUnit())
        XFO.SystemFrame:DisplayOrder(order)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end).
    finally(function()
        self:Push(order)
    end)
end
--#endregion