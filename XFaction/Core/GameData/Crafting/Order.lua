local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

XFC.Order = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Order:new()
    local object = XFC.Order.parent.new(self)
    object.__name = 'Order'
    object.customer = nil
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
    self.customer = nil
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

--#region Properties
function XFC.Order:Customer(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil, 'argment must be Unit class or nil')
    if(inUnit ~= nil) then
        self.customer = inUnit
    end
    return self.customer
end

function XFC.Order:Profession(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil, 'argument must be Profession object or nil')
    if(inProfession ~= nil) then
        self.profession = inProfession
    end
    return self.profession
end

function XFC.Order:IsMyOrder()
    return XF.Player.Unit:Equals(self:Customer())
end

function XFC.Order:Type(inType)
    assert(type(inType) == 'number' or inType == nil, 'argument must be number or nil')
    if(inType ~= nil) then
        self.type = inType
    end
    return self.type
end

function XFC.Order:RecipeID(inID)
    assert(type(inID) == 'number' or inID == nil, 'argument must be number or nil')
    if(inID ~= nil) then
        self.recipeID = inID
    end
    return self.recipeID
end

function XFC.Order:Quality(inQuality)
    assert(type(inQuality) == 'number' or inQuality == nil, 'argument must be number or nil')
    if(inQuality ~= nil) then
        self.quality = inQuality
    end
    return self.quality
end

function XFC.Order:CrafterGUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil, 'argument must be string or nil')
    if(inGUID ~= nil) then
        self.crafterGUID = inGUID
    end
    return self.crafterGUID
end

function XFC.Order:IsPlayerCrafter()
    return XF.Player.Unit:GetGUID() == self.crafterGUID
end

function XFC.Order:CrafterName(inName)
    assert(type(inName) == 'string' or inName == nil, 'argument must be string or nil')
    if(inName ~= nil) then
        self.crafterName = inName
    end
    return self.crafterName
end

function XFC.Order:State(inState)
    assert(type(inState) == 'number' or inState == nil, 'argument must be number or nil')
    if(inState ~= nil) then
        self.state = inState
    end
    return self.state
end
--#endregion

--#region Methods
function XFC.Order:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  recipeID (' .. type(self.recipeID) .. '): ' .. tostring(self.recipeID))
    XF:Debug(self:ObjectName(), '  quality (' .. type(self.quality) .. '): ' .. tostring(self.quality))
    XF:Debug(self:ObjectName(), '  crafterGUID (' .. type(self.crafterGUID) .. '): ' .. tostring(self.crafterGUID))
    XF:Debug(self:ObjectName(), '  crafterName (' .. type(self.crafterName) .. '): ' .. tostring(self.crafterName))
    XF:Debug(self:ObjectName(), '  hasDisplayed (' .. type(self.hasDisplayed) .. '): ' .. tostring(self.hasDisplayed))
    XF:Debug(self:ObjectName(), '  hasCommunicated (' .. type(self.hasCommunicated) .. '): ' .. tostring(self.hasCommunicated))
    XF:Debug(self:ObjectName(), '  state (' .. type(self.state) .. '): ' .. tostring(self.state))
    if(self:Customer() ~= nil) then self:Customer():Print() end
    if(self:Profession() ~= nil) then self:Profession():Print() end
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
        elseif(XF:ObjectsEquals(self:Profession(), XF.Player.Unit:Profession1())) then
            display = true
        elseif(XF:ObjectsEquals(self:Profession(), XF.Player.Unit:Profession2())) then
            display = true
        end

        if(display) then
            XFO.SystemFrame:DisplayOrderMessage(XF.Enum.Message.ORDER, self:Customer(), self)
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Order:Serialize()
    local data = {}
    data.K = self:Key()
    data.O = self:ID()
    data.P = self:Profession():Key()
    data.Q = self:Quality()
    data.R = self:RecipeID()
    data.T = self:Type()
    data.U = self:CrafterGUID()
    return data
end

function XFC.Order:Deserialize(inData)
    self:Key(inData.K)
    self:ID(inData.O)
    self:Type(inData.T)
    self:Profession(XFO.Professions:Get(inData.P))
    if(inData.Q ~= nil) then
        self:Quality(inData.Q)
    end
    self:RecipeID(inData.R)
    if(inData.U ~= nil) then
        self:CrafterGUID(inData.U)
    end
    self:IsInitialized(true)
end

function XFC.Order:Broadcast()
    local message = nil
    try(function ()
        message = XFO.Chat:Pop()
        message:Initialize()
        message:Type(XF.Enum.Network.BROADCAST)
        message:Subject(XF.Enum.Message.ORDER)
        message:Data(self:Serialize())
        XFO.Chat:Send(message)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end).
    finally(function ()
        XFO.Chat:Push(message)
    end)
end
--#endregion