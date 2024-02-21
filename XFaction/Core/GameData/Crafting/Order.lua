local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

XFC.Order = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Order:new()
    local object = XFC.Order.parent.new(self)
    object.__name = 'Order'
    object.customerUnit = nil
    object.profession = nil
    object.type = 0
    object.hasDisplayed = false
    object.hasCommunicated = false
    object.state = 0
    object.recipeID = 0
    object.quality = nil
    object.crafterGUID = nil
    object.crafterName = nil
    return object
end

function XFC.Order:Deconstructor()
    self:ParentDeconstructor()
    self.customerUnit = nil
    self.profession = nil
    self.type = 0
    self.hasDisplayed = false
    self.hasCommunicated = false
    self.state = 0
    self.recipeID = 0
    self.quality = nil
    self.crafterGUID = nil
    self.crafterName = nil
end
--#endregion

--#region Print
function XFC.Order:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:GetObjectName(), '  recipeID (' .. type(self.recipeID) .. '): ' .. tostring(self.recipeID))
    XF:Debug(self:GetObjectName(), '  quality (' .. type(self.quality) .. '): ' .. tostring(self.quality))
    XF:Debug(self:GetObjectName(), '  crafterGUID (' .. type(self.crafterGUID) .. '): ' .. tostring(self.crafterGUID))
    XF:Debug(self:GetObjectName(), '  crafterName (' .. type(self.crafterName) .. '): ' .. tostring(self.crafterName))
    XF:Debug(self:GetObjectName(), '  hasDisplayed (' .. type(self.hasDisplayed) .. '): ' .. tostring(self.hasDisplayed))
    XF:Debug(self:GetObjectName(), '  hasCommunicated (' .. type(self.hasCommunicated) .. '): ' .. tostring(self.hasCommunicated))
    XF:Debug(self:GetObjectName(), '  state (' .. type(self.state) .. '): ' .. tostring(self.state))
    if(self:HasCustomerUnit()) then self:GetCustomerUnit():Print() end
    if(self:HasProfession()) then self:GetProfession():Print() end
end
--#endregion

--#region Accessors
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

function XFC.Order:GetRecipeID()
    return self.recipeID
end

function XFC.Order:SetRecipeID(inID)
    assert(type(inID) == 'number')
    self.recipeID = inID
end

function XFC.Order:GetQuality()
    return self.quality
end

function XFC.Order:SetQuality(inQuality)
    assert(type(inQuality) == 'number')
    self.quality = inQuality
end

function XFC.Order:GetCrafterGUID()
    return self.crafterGUID
end

function XFC.Order:SetCrafterGUID(inGUID)
    assert(type(inGUID) == 'string')
    self.crafterGUID = inGUID
end

function XFC.Order:IsPlayerCrafter()
    return XF.Player.Unit:GetGUID() == self.crafterGUID
end

function XFC.Order:GetCrafterName()
    return self.crafterName
end

function XFC.Order:SetCrafterName(inName)
    assert(type(inName) == 'string')
    self.crafterName = inName
end

function XFC.Order:GetState()
    return self.state
end

function XFC.Order:SetState(inState)
    assert(type(inState) == 'number')
    self.state = inState
end

function XFC.Order:Display()
    try(function()
        if(not XF.Config.Chat.Crafting.Enable) then return end
        if(self:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
        if(self:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
        if(self:IsPersonal() and not self:IsMyOrder() and not self:IsPlayerCrafter()) then return end

        local display = false
        if(not XF.Config.Chat.Crafting.Profession) then
            display = true
        elseif(self:HasProfession() and self:GetProfession():Equals(XF.Player.Unit:GetProfession1())) then
            display = true
        elseif(self:HasProfession() and self:GetProfession():Equals(XF.Player.Unit:GetProfession2())) then
            display = true
        end

        if(display) then
            XFO.SystemFrame:DisplayOrder(self)
        end
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
    end)
end
--#endregion

--#region Networking
function XFC.Order:Serialize()
    local data = {}
    data.K = self:GetKey()
    data.O = self:GetID()
    data.P = self:GetProfession():GetKey()
    data.Q = self:GetQuality()
    data.R = self:GetRecipeID()
    data.T = self:GetType()
    data.U = self:GetCrafterGUID()
    return data
end

function XFC.Order:Deserialize(inData)
    assert(type(inData) == 'table')
    self:SetKey(inData.K)
    self:SetID(inData.O)
    self:SetType(inData.T)
    self:SetProfession(XFO.Professions:Get(inData.P))
    if(inData.Q ~= nil) then
        self:SetQuality(inData.Q)
    end
    self:SetRecipeID(inData.R)
    if(inData.U ~= nil) then
        self:SetCrafterGUID(inData.U)
    end
    self:IsInitialized(true)
end

function XFC.Order:Broadcast()
    local message = nil
    try(function ()
        message = XF.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetType(XF.Enum.Network.BROADCAST)
        message:SetSubject(XF.Enum.Message.ORDER)
        message:SetData(self:Serialize())
        XFO.Chat:Send(message)
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
    end).
    finally(function ()
        XFO.Chat:Push(message)
    end)
end
--#endregion