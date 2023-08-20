local XFG, G = unpack(select(2, ...))
local ObjectName = 'Order'

Order = Object:newChildConstructor()

--#region Constructors
function Order:new()
    local object = Order.parent.new(self)
    object.__name = ObjectName
    object.ID = 0
    object.itemID = nil
    object.skillLineAbilityID = nil
    object.isFulfillable = false
    object.customerGUID = nil
    object.customerName = nil
    object.customerGuild = nil
    object.minQuality = 1
    object.isLatestOrder = false
    object.profession = nil
    return object
end

function Order:Deconstructor()
    self:ParentDeconstructor()
    self.ID = 0
    self.itemID = nil
    self.skillLineAbilityID = nil
    self.isFulfillable = false
    self.customerGUID = nil
    self.customerName = nil
    self.customerGuild = nil
    self.minQuality = 1
    self.isLatestOrder = false
    self.profession = nil
end
--#endregion

--#region Print
function Order:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  itemID (' .. type(self.itemID) .. '): ' .. tostring(self.itemID))
    XFG:Debug(ObjectName, '  skillLineAbilityID (' .. type(self.skillLineAbilityID) .. '): ' .. tostring(self.skillLineAbilityID))
    XFG:Debug(ObjectName, '  isFulfillable (' .. type(self.isFulfillable) .. '): ' .. tostring(self.isFulfillable))
    XFG:Debug(ObjectName, '  customerGUID (' .. type(self.customerGUID) .. '): ' .. tostring(self.customerGUID))
    XFG:Debug(ObjectName, '  customerName (' .. type(self.customerName) .. '): ' .. tostring(self.customerName))
    XFG:Debug(ObjectName, '  minQuality (' .. type(self.minQuality) .. '): ' .. tostring(self.minQuality))
    XFG:Debug(ObjectName, '  isLatestOrder (' .. type(self.isLatestOrder) .. '): ' .. tostring(self.isLatestOrder))
    if(self:HasCustomerGuild()) then
        self:GetCustomerGuild():Print()
    end
    if(self:HasProfession()) then
        self:GetProfession():Print()
    end
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

function Order:GetItemID()
    return self.itemID
end

function Order:SetItemID(inItemID)
    assert(type(inItemID) == 'number')
    self.itemID = inItemID
end

function Order:GetSkillLineAbilityID()
    return self.skillLineAbilityID
end

function Order:SetSkillLineAbilityID(inSkillLineAbilityID)
    assert(type(inSkillLineAbilityID) == 'number')
    self.skillLineAbilityID = inSkillLineAbilityID
end

function Order:GetCustomerGUID()
    return self.customerGUID
end

function Order:SetCustomerGUID(inCustomerGUID)
    assert(type(inCustomerGUID) == 'string')
    self.customerGUID = inCustomerGUID
end

function Order:GetCustomerName()
    return self.customerName
end

function Order:SetCustomerName(inCustomerName)
    assert(type(inCustomerName) == 'string')
    self.customerName = inCustomerName
end

function Order:HasCustomerGuild()
    return self.customerGuild ~= nil
end

function Order:GetCustomerGuild()
    return self.customerGuild
end

function Order:SetCustomerGuild(inCustomerGuild)
    assert(type(inCustomerGuild) == 'table' and inCustomerGuild.__name ~= nil and inCustomerGuild.__name == 'Guild', 'argument must be Guild object')
    self.customerGuild = inCustomerGuild
end

function Order:HasProfession()
    return self.profession ~= nil
end

function Order:GetProfession()
    return self.profession
end

function Order:SetProfession(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name ~= nil and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession = inProfession
end

function Order:GetMinimumQuality()
    return self.minQuality
end

function Order:SetMinimumQuality(inQuality)
    assert(type(inQuality) == 'number')
    self.minQuality = inQuality
end

function Order:IsFulfillable(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isFulfillable = inBoolean
    end    
    return self.isFulfillable
end

function Order:IsMyOrder()
    return self:GetCustomerGUID() == XFG.Player.Unit:GetGUID()
end

function Order:IsLatestOrder(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLatestOrder = inBoolean
    end    
    return self.isLatestOrder
end
--#endregion

--#region Networking
function Order:Encode()
    local data = {}
    data.K = self:GetKey()
    data.I = self:GetItemID()
    data.C = self:GetCustomerGUID()
    data.N = self:GetCustomerName()
    data.Q = self:GetMinimumQuality()
    data.G = self:GetCustomerGuild():GetKey()
    data.P = self:GetProfession():GetKey()
    data.S = self:GetSkillLineAbilityID()
    return data
end

function Order:Decode(inData)
    assert(type(inData) == 'table')
    if(self:IsInitialized()) then
        self:Deconstructor()
    end
    self:SetKey(inData.K)
    self:SetID(inData.K)
    self:SetItemID(inData.I)
    self:SetCustomerGUID(inData.C)
    self:SetCustomerName(inData.N)
    self:SetMinimumQuality(inData.Q)
    self:SetCustomerGuild(XFG.Guilds:Get(inData.G))
    self:SetProfession(XFG.Professions:Get(inData.P))
    self:SetSkillLineAbilityID(inData.S)
    self:IsInitialized(true)
end

function Order:Serialize()
    return pickle(self:Encode())
end

function Order:Deserialize(inData)
    self:Decode(unpickle(inData))
end

function Order:Broadcast()
    local message = nil
    try(function ()
        message = XFG.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetFrom(XFG.Player.Unit:GetGUID())
        message:SetGuild(XFG.Player.Guild)
        message:SetUnitName(XFG.Player.Unit:GetUnitName())
        message:SetType(XFG.Enum.Network.BROADCAST)
        message:SetSubject(XFG.Enum.Message.ORDER)
        message:SetData(self:Serialize())
        XFG.Mailbox.Chat:Send(message)
    end).
    finally(function ()
        XFG.Mailbox.Chat:Push(message)
    end)
end
--#endregion