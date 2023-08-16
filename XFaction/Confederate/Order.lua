local XFG, G = unpack(select(2, ...))
local ObjectName = 'Order'

Order = Object:newChildConstructor()

--#region Constructors
function Order:new()
    local object = Order.parent.new(self)
    object.__name = ObjectName
    object.ID = 0
    object.itemID = nil
    object.isFulfillable = nil
    object.customerGUID = nil
    object.minQuality = 1
    object.itemHyperlink = nil
    object.itemGUID = nil
    object.isMine = false
    return object
end

function Order:Deconstructor()
    self:ParentDeconstructor()
    self.ID = 0
    self.itemID = nil
    self.isFulfillable = nil
    self.customerGUID = nil
    self.minQuality = 1
    self.itemHyperlink = nil
    self.itemGUID = nil
    self.isMine = false
end
--#endregion

--#region Print
function Order:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  itemID (' .. type(self.itemID) .. '): ' .. tostring(self.itemID))
    XFG:Debug(ObjectName, '  isFulfillable (' .. type(self.isFulfillable) .. '): ' .. tostring(self.isFulfillable))
    XFG:Debug(ObjectName, '  customerGUID (' .. type(self.customerGUID) .. '): ' .. tostring(self.customerGUID))
    XFG:Debug(ObjectName, '  minQuality (' .. type(self.minQuality) .. '): ' .. tostring(self.minQuality))
    XFG:Debug(ObjectName, '  itemHyperlink (' .. type(self.itemHyperlink) .. '): ' .. tostring(self.itemHyperlink))
    XFG:Debug(ObjectName, '  itemGUID (' .. type(self.itemGUID) .. '): ' .. tostring(self.itemGUID))
    XFG:Debug(ObjectName, '  isMine (' .. type(self.isMine) .. '): ' .. tostring(self.isMine))
end
--#endregion

--#region Accessors
function Order:GetID()
    return self.ID
end

function Order:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Order:GetItemID()
    return self.itemID
end

function Order:SetItemID(inItemID)
    assert(type(inItemID) == 'number')
    self.itemID = inItemID
end

function Order:IsFulfillable(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isFulfillable = inBoolean
    end    
    return self.isFulfillable
end

function Order:GetCustomerGUID()
    return self.customerGUID
end

function Order:SetCustomerGUID(inGUID)
    assert(type(inGUID) == 'string')
    self.customerGUID = inGUID
end

function Order:GetMinimumQuantity()
    return self.minQuality
end

function Order:SetMinimumQuantity(inQuantity)
    assert(type(inQuantity) == 'number' and inQuantity >= 0)
    self.minQuality = inQuantity
end

function Order:GetItemHyperlink()
    return self.itemHyperlink
end

function Order:SetItemHyperlink(inLink)
    assert(type(inLink) == 'string')
    self.itemHyperlink = inLink
end

function Order:GetItemGUID()
    return self.itemGUID
end

function Order:SetItemGUID(inGUID)
    assert(type(inGUID) == 'string')
    self.itemGUID = inGUID
end

function Order:IsMyOrder(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isMine = inBoolean
    end    
    return self.isMine
end
--#endregion