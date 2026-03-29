local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local GetRecipeResultItem = C_TooltipInfo.GetRecipeResultItem

XFC.Order = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Order:new()
    local object = XFC.Order.parent.new(self)
    object.__name = 'Order'
    object.customer = nil
    object.profession = nil
    object.type = 0
    object.state = 0
    object.recipeID = 0
    object.quality = nil
    object.crafterGUID = nil
    object.crafterName = nil
    object.link = nil
    return object
end
--#endregion

--#region Properties
function XFC.Order:Customer(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil)
    if(inUnit ~= nil) then
        self.customer = inUnit
    end
    return self.customer
end

function XFC.Order:Profession(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil)
    if(inProfession ~= nil) then
        self.profession = inProfession
    end
    return self.profession
end

function XFC.Order:Type(inType)
    assert(type(inType) == 'number' or inType == nil)
    if(inType ~= nil) then
        self.type = inType
    end
    return self.type
end

function XFC.Order:RecipeID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(inID ~= nil) then
        self.recipeID = inID
    end
    return self.recipeID
end

function XFC.Order:Quality(inQuality)
    assert(type(inQuality) == 'number' or inQuality == nil)
    if(inQuality ~= nil) then
        self.quality = inQuality
    end
    return self.quality
end

function XFC.Order:CrafterGUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.crafterGUID = inGUID
    end
    return self.crafterGUID
end

function XFC.Order:CrafterName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.crafterName = inName
    end
    return self.crafterName
end

function XFC.Order:State(inState)
    assert(type(inState) == 'number' or inState == nil)
    if(inState ~= nil) then
        self.state = inState
    end
    return self.state
end

function XFC.Order:Link(inLink)
    assert(type(inLink) == 'string' or inLink == nil)
    if(inLink ~= nil) then
        self.link = inLink
    end
    return self.link
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
    XF:Debug(self:ObjectName(), '  state (' .. type(self.state) .. '): ' .. tostring(self.state))
    XF:Debug(self:ObjectName(), '  link (' .. type(self.link) .. '): ' .. tostring(self.link))
    if(self:HasCustomer()) then self:Customer():Print() end
    if(self:HasProfession()) then self:Profession():Print() end
end

function XFC.Order:HasCustomer()
    return self:Customer() ~= nil
end

function XFC.Order:HasProfession()
    return self:Profession() ~= nil
end

function XFC.Order:IsMyOrder()
    return self:HasCustomer() and self:Customer():IsPlayer()
end

function XFC.Order:IsPlayerCrafter()
    return self:CrafterGUID() == XF.Player.GUID
end

function XFC.Order:Serialize()
    local data = {}
    data.K = self:Key()
    data.O = self:ID()
    data.P = self:Profession():Serialize()
    data.T = self:Type()
    data.U = self:CrafterGUID()
    data.L = self:Link()
    return pickle(data)
end

function XFC.Order:Deserialize(inData)
    assert(type(inData) == 'string')
    local data = unpickle(inData)
    self:Key(data.K)
    self:ID(data.O)
    self:Type(data.T)
    self:Profession(XFO.Professions:Get(data.P))
    self:CrafterGUID(data.U)
    self:Link(data.L)
    self:IsInitialized(true)
end
--#endregion