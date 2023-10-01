local XFG, G = unpack(select(2, ...))
local ObjectName = 'Order'
local GetProfessionForSkill = C_TradeSkillUI.GetProfessionNameForSkillLineAbility
local ServerTime = GetServerTime

Order = Object:newChildConstructor()

--#region Constructors
function Order:new()
    local object = Order.parent.new(self)
    object.__name = ObjectName
    object.ID = 0
    object.itemID = nil
    object.itemLink = nil
    object.itemIcon = nil
    object.skillLineAbilityID = nil
    object.isFulfillable = false
    object.customerUnit = nil
    object.quality = 1
    object.isLatestOrder = false
    object.profession = nil
    object.type = 0
    return object
end

function Order:Deconstructor()
    self:ParentDeconstructor()
    self.ID = 0
    self.itemID = nil
    self.itemLink = nil
    self.itemIcon = nil
    self.skillLineAbilityID = nil
    self.isFulfillable = false
    self.customerUnit = nil
    self.quality = 1
    self.profession = nil
    self.type = 0
end
--#endregion

--#region Print
function Order:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  itemID (' .. type(self.itemID) .. '): ' .. tostring(self.itemID))
    XFG:Debug(ObjectName, '  itemLink (' .. type(self.itemLink) .. '): ' .. tostring(self.itemLink))
    XFG:Debug(ObjectName, '  itemIcon (' .. type(self.itemIcon) .. '): ' .. tostring(self.itemIcon))
    XFG:Debug(ObjectName, '  skillLineAbilityID (' .. type(self.skillLineAbilityID) .. '): ' .. tostring(self.skillLineAbilityID))
    XFG:Debug(ObjectName, '  isFulfillable (' .. type(self.isFulfillable) .. '): ' .. tostring(self.isFulfillable))
    XFG:Debug(ObjectName, '  quality (' .. type(self.quality) .. '): ' .. tostring(self.quality))
    XFG:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    if(self:HasCustomerUnit()) then
        self:GetCustomerUnit():Print()
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

function Order:HasItemLink()
    return self.itemLink ~= nil
end

function Order:GetItemLink()
    return format('%s %s', format(XFG.Icons.String, self:GetItemIcon()), self.itemLink)
end

function Order:SetItemLink(inLink)
    self.itemLink = inLink
end

function Order:HasItemIcon()
    return self.itemIcon ~= nil
end

function Order:GetItemIcon()
    return self.itemIcon
end

function Order:SetItemIcon(inIcon)
    self.itemIcon = inIcon
end

function Order:GetSkillLineAbilityID()
    return self.skillLineAbilityID
end

function Order:SetSkillLineAbilityID(inSkillLineAbilityID)
    assert(type(inSkillLineAbilityID) == 'number')
    self.skillLineAbilityID = inSkillLineAbilityID
    local professionName = GetProfessionForSkill(inSkillLineAbilityID)
    if(professionName ~= nil and type(professionName) == 'string') then
        local profession = XFG.Professions:GetByName(professionName)
        if(profession ~= nil) then
            self:SetProfession(profession)
        end
    end
end

function Order:HasCustomerUnit()
    return self.customerUnit ~= nil
end

function Order:GetCustomerUnit()
    return self.customerUnit
end

function Order:SetCustomerUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argment must be Unit class')
    self.customerUnit = inUnit
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

function Order:GetQuality()
    return self.quality
end

function Order:SetQuality(inQuality)
    assert(type(inQuality) == 'number')
    self.quality = inQuality > 0 and inQuality or 1
end

function Order:IsFulfillable(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isFulfillable = inBoolean
    end    
    return self.isFulfillable
end

function Order:IsMyOrder()
    return XFG.Player.Unit:Equals(self:GetCustomerUnit())
end

function Order:GetType()
    return self.type
end

function Order:SetType(inType)
    assert(type(inType) == 'number')
    self.type = inType
end

function Order:IsPublic()
    return self.type == Enum.CraftingOrderType.Public
end

function Order:IsGuild()
    return self.type == Enum.CraftingOrderType.Guild
end

function Order:IsPersonal()
    return self.type == Enum.CraftingOrderType.Personal
end
--#endregion

--#region Networking
function Order:Encode()
    local data = {}
    data.C = XFG:SerializeUnitData(self:GetCustomerUnit())
    data.I = self:GetItemID()
    data.K = self:GetKey()
    data.O = self:GetID()
    data.Q = self:GetQuality()
    data.S = self:GetSkillLineAbilityID()
    data.T = self:GetType()     
    return data
end

function Order:Decode(inData)
    assert(type(inData) == 'table')
    self:SetKey(inData.K)
    self:SetID(inData.O)
    self:SetItemID(inData.I)
    self:SetQuality(inData.Q or 1)
    self:SetType(inData.T)
    self:SetSkillLineAbilityID(inData.S)
    self:SetCustomerUnit(XFG:DeserializeUnitData(inData.C))    
    self:IsInitialized(true)
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
        message:SetData(self:Encode())
        XFG.Mailbox.Chat:Send(message)
        -- Because Order broadcast contains unit information, reset the heartbeat timer
        XFG.Player.LastBroadcast = ServerTime()
    end).
    finally(function ()
        XFG.Mailbox.Chat:Push(message)
    end)
end

function Order:Display()
    if(not XFG.Config.Chat.Crafting.Enable) then return end
    if(self:IsGuild() and not XFG.Config.Chat.Crafting.GuildOrder) then return end
    if(self:IsPersonal() and not XFG.Config.Chat.Crafting.PersonalOrder) then return end
    if(self:IsPersonal() and not XFG.Player.Unit:Equals(self:GetCustomerUnit())) then return end
    if(XFG.Config.Chat.Crafting.Profession and self:HasProfession() and not self:GetProfession():Equals(XFG.Player.Unit:GetProfession1() and not self:GetProfession():Equals(XFG.Player.Unit:GetProfession2()))) then return end
    XFG.Frames.System:DisplayOrder(self)
end
--#endregion