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
    return object
end
--#endregion

--#region Print
function Order:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function Order:GetID()
    return self.ID
end

function Order:SetID(inOrderID)
    assert(type(inOrderID) == 'number')
    self.ID = inOrderID
end

function Order:GetIconID()
    return self.iconID
end

function Order:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion