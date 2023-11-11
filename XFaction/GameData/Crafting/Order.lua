local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

XFC.Order = Object:newChildConstructor()

--#region Constructors
function XFC.Order:new()
    local object = XFC.Order.parent.new(self)
    object.__name = 'Order'
    object.item = nil
    object.customerUnit = nil
    object.profession = nil
    object.type = 0
    object.hasDisplayed = false
    object.hasCommunicated = false
    object.state = 0
    return object
end

function XFC.Order:Deconstructor()
    self:ParentDeconstructor()
    self.item = nil
    self.customerUnit = nil
    self.profession = nil
    self.type = 0
    self.hasDisplayed = false
    self.hasCommunicated = false
    self.state = 0
end
--#endregion

--#region Print
function XFC.Order:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:GetObjectName(), '  hasDisplayed (' .. type(self.hasDisplayed) .. '): ' .. tostring(self.hasDisplayed))
    XF:Debug(self:GetObjectName(), '  hasCommunicated (' .. type(self.hasCommunicated) .. '): ' .. tostring(self.hasCommunicated))
    XF:Debug(self:GetObjectName(), '  state (' .. type(self.state) .. '): ' .. tostring(self.state))
    if(self:HasCustomerUnit()) then self:GetCustomerUnit():Print() end
    if(self:HasProfession()) then self:GetProfession():Print() end
    if(self:HasItem()) then self:GetItem():Print() end
end
--#endregion

--#region Accessors
function XFC.Order:HasItem()
    return self.item ~= nil
end

function XFC.Order:GetItem()
    return self.item
end

function XFC.Order:SetItem(inItem)
    assert(type(inItem) == 'table' and inItem.__name ~= nil and inItem.__name == 'Item', 'argument must be Item object')
    self.item = inItem
end

function XFC.Order:HasCustomerUnit()
    return self.customerUnit ~= nil
end

function XFC.Order:GetCustomerUnit()
    return self.customerUnit
end

function XFC.Order:SetCustomerUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argment must be Unit class')
    self.customerUnit = inUnit
end

function XFC.Order:HasProfession()
    return self.profession ~= nil
end

function XFC.Order:GetProfession()
    return self.profession
end

function XFC.Order:SetProfession(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name ~= nil and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession = inProfession
end

function XFC.Order:IsMyOrder()
    return XF.Player.Unit:Equals(self:GetCustomerUnit())
end

function XFC.Order:GetType()
    return self.type
end

function XFC.Order:SetType(inType)
    assert(type(inType) == 'number')
    self.type = inType
end

function XFC.Order:IsPublic()
    return self.type == Enum.CraftingOrderType.Public
end

function XFC.Order:IsGuild()
    return self.type == Enum.CraftingOrderType.Guild
end

function XFC.Order:IsPersonal()
    return self.type == Enum.CraftingOrderType.Personal
end

function XFC.Order:HasDisplayed(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.hasDisplayed = inBoolean
    end    
    return self.hasDisplayed
end

function XFC.Order:HasCommunicated(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.hasCommunicated = inBoolean
    end    
    return self.hasCommunicated
end

function XFC.Order:GetState()
    return self.state
end

function XFC.Order:SetState(inState)
    assert(type(inState) == 'number')
    self.state = inState
end
--#endregion

--#region Networking
function XFC.Order:Encode(inBackup)
    assert(inBackup == nil or type(inBackup) == 'boolean', 'argument must be nil or boolean')
    local data = {}
    data.C = XF:SerializeUnitData(self:GetCustomerUnit())
    data.I = self:GetItem():GetKey()
    data.K = self:GetKey()
    data.O = self:GetID()
    data.P = self:GetProfession():GetKey()
    data.T = self:GetType()
    if(inBackup ~= nil and inBackup == true) then
        data.B = self:HasCommunicated() and 1 or 0
        data.D = self:HasDisplayed() and 1 or 0
        if(self:IsMyOrder()) then
            data.D = 1
        end
    end
    return data
end

function XFC.Order:Decode(inData)
    assert(type(inData) == 'table')
    self:SetKey(inData.K)
    self:SetID(inData.O)
    self:SetType(inData.T)
    self:SetCustomerUnit(XF:DeserializeUnitData(inData.C))    
    self:SetProfession(XF.Professions:Get(inData.P))

    if(inData.B ~= nil) then
        self:HasCommunicated(inData.B == 1)
    end
    if(inData.D ~= nil) then
        self:HasDisplayed(inData.D == 1)
    end

    if(not XFO.Items:Contains(inData.I) or not XFO.Items:Get(inData.I):IsCached()) then
        XFO.Items:Cache(inData.I)
    end
    self:SetItem(XFO.Items:Get(inData.I))

    self:IsInitialized(true)
end

function XFC.Order:Broadcast()
    local message = nil
    try(function ()
        message = XF.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetFrom(XF.Player.Unit:GetGUID())
        message:SetGuild(XF.Player.Guild)
        message:SetUnitName(XF.Player.Unit:GetUnitName())
        message:SetType(XF.Enum.Network.BROADCAST)
        message:SetSubject(XF.Enum.Message.ORDER)
        message:SetData(self:Encode())
        XF.Mailbox.Chat:Send(message)
        self:HasCommunicated(true)
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
    end).
    finally(function ()
        XF.Mailbox.Chat:Push(message)
    end)
end

function XFC.Order:Display()
    try(function()
        if(self:HasDisplayed()) then return end
        if(not XF.Config.Chat.Crafting.Enable) then return end
        if(self:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
        if(self:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
        if(self:IsPersonal() and not XF.Player.Unit:Equals(self:GetCustomerUnit())) then return end
        if(self:HasItem() and not self:GetItem():IsCached()) then return end

        local display = false
        if(not XF.Config.Chat.Crafting.Profession) then
            display = true
        elseif(self:HasProfession() and self:GetProfession():Equals(XF.Player.Unit:GetProfession1())) then
            display = true
        elseif(self:HasProfession() and self:GetProfession():Equals(XF.Player.Unit:GetProfession2())) then
            display = true
        end

        if(display) then
            XF.Frames.System:DisplayOrder(self)
            self:HasDisplayed(true)
        end
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
    end)
end
--#endregion