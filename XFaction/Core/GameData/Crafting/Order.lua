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
    return self:Customer():Key() == XF.Player.Unit:Key()
end

function XFC.Order:IsMyCraft()
    return XF.Player.Unit:GUID() == self.crafterGUID
end

--#region Deprecated, remove after 4.13
function XFC.Order:Encode(inBackup)
    assert(type(inBackup) == 'boolean' or inBackup == nil)
    local data = {}
    data.C = self:Customer():LegacySerialize()
    data.K = self:Key()
    data.O = self:ID()
    data.P = self:Profession():Key()
    data.Q = self:Quality()
    data.R = self:RecipeID()
    data.T = self:Type()
    data.U = self:CrafterGUID()
    return data
end

function XFC.Order:Decode(inData)
    assert(type(inData) == 'table')
    self:Key(inData.K)
    self:ID(inData.O)
    self:Type(inData.T)

    local unit = XFO.Confederate:Pop()
    try(function()
        unit:LegacyDeserialize(inData.C)
        XFO.Confederate:Add(unit)
        self:Customer(unit)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
        XFO.Confederate:Push(unit)
    end)
    self:Profession(XFO.Professions:Get(tonumber(inData.P)))
    if(inData.Q ~= nil) then
        self:Quality(tonumber(inData.Q))
    end
    self:RecipeID(tonumber(inData.R))
    if(inData.U ~= nil) then
        self:CrafterGUID(inData.U)
    end
    self:IsInitialized(true)
end
--#endregion

function XFC.Order:Display()
    try(function()
        if(not XF.Config.Chat.Crafting.Enable) then return end
        -- TODO this will not work in classic
        if(self:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
        if(self:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
        if(self:IsPersonal() and not self:IsMyOrder() and not self:IsMyCraft()) then return end

        local display = false
        if(not XF.Config.Chat.Crafting.Profession) then
            display = true
        elseif(self:HasProfession() and self:Profession():Equals(XF.Player.Unit:Profession1())) then
            display = true
        elseif(self:HasProfession() and self:Profession():Equals(XF.Player.Unit:Profession2())) then
            display = true
        end

        if(display) then
            XFO.SystemFrame:DisplayOrder(self)
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion