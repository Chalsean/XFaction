local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local GetProfessionForSkill = C_TradeSkillUI.GetProfessionNameForSkillLineAbility

XFC.Order = Object:newChildConstructor()

--#region Constructors
function XFC.Order:new()
    local object = XFC.Order.parent.new(self)
    object.__name = 'Order'
    object.item = nil
    object.skillLineAbilityID = nil
    object.customerUnit = nil
    object.profession = nil
    object.type = 0
    object.hasDisplayed = false
    object.hasCommunicated = false
    return object
end

function XFC.Order:Deconstructor()
    self:ParentDeconstructor()
    self.item = nil
    self.skillLineAbilityID = nil
    self.customerUnit = nil
    self.profession = nil
    self.type = 0
    self.hasDisplayed = false
    self.hasCommunicated = false
end
--#endregion

--#region Print
function XFC.Order:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  skillLineAbilityID (' .. type(self.skillLineAbilityID) .. '): ' .. tostring(self.skillLineAbilityID))
    XF:Debug(self:GetObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:GetObjectName(), '  hasDisplayed (' .. type(self.hasDisplayed) .. '): ' .. tostring(self.hasDisplayed))
    XF:Debug(self:GetObjectName(), '  hasCommunicated (' .. type(self.hasCommunicated) .. '): ' .. tostring(self.hasCommunicated))
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

function XFC.Order:GetSkillLineAbilityID()
    return self.skillLineAbilityID
end

function XFC.Order:SetSkillLineAbilityID(inSkillLineAbilityID)
    assert(type(inSkillLineAbilityID) == 'number')
    self.skillLineAbilityID = inSkillLineAbilityID
    local professionName = GetProfessionForSkill(inSkillLineAbilityID)
    if(professionName ~= nil and type(professionName) == 'string') then
        local profession = XF.Professions:GetByName(professionName)
        if(profession ~= nil) then
            self:SetProfession(profession)
        end
    end
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
--#endregion

--#region Networking
function XFC.Order:Encode()
    local data = {}
    data.C = XF:SerializeUnitData(self:GetCustomerUnit())
    data.I = self:GetItem():GetKey()
    data.K = self:GetKey()
    data.O = self:GetID()
    data.P = self:GetProfession():GetKey()
    data.S = self:GetSkillLineAbilityID()
    data.T = self:GetType()     
    return data
end

function XFC.Order:Decode(inData)
    assert(type(inData) == 'table')
    self:SetKey(inData.K)
    self:SetID(inData.O)
    self:SetType(inData.T)
    self:SetSkillLineAbilityID(inData.S)
    self:SetCustomerUnit(XF:DeserializeUnitData(inData.C))    
    self:SetProfession(XF.Professions:Get(inData.P))

    XFO.Items:Cache(inData.I)
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
    end).
    finally(function ()
        XF.Mailbox.Chat:Push(message)
        self:HasCommunicated(true)
    end)
end

function XFC.Order:Display()
    try(function()
        if(not XF.Config.Chat.Crafting.Enable) then return end
        if(self:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
        if(self:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
        if(self:IsPersonal() and not XF.Player.Unit:Equals(self:GetCustomerUnit())) then return end
        if(XF.Config.Chat.Crafting.Profession and self:HasProfession() and not self:GetProfession():Equals(XF.Player.Unit:GetProfession1() and not self:GetProfession():Equals(XF.Player.Unit:GetProfession2()))) then return end
        XF.Frames.System:DisplayOrder(self)
    end).
    finally(function()
        self:HasDisplayed(true)
    end)
end
--#endregion