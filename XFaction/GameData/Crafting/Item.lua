local XF, G = unpack(select(2, ...))
local XFC = XF.Class
local ObjectName = 'Item'

XFC.Item = Object:newChildConstructor()

--#region Constructors
function XFC.Item:new()
    local object = XFC.Item.parent.new(self)
    object.__name = ObjectName
    object.link = nil
    object.icon = nil
    object.quality = nil
    object.isCached = false
    return object
end

function XFC.Item:Deconstructor()
    self:ParentDeconstructor()
    self.link = nil
    self.icon = nil
    self.quality = nil
    self.isCached = false
end
--#endregion

--#region Print
function XFC.Item:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  link (' .. type(self.link) .. '): ' .. tostring(self.link))
    XF:Debug(ObjectName, '  icon (' .. type(self.icon) .. '): ' .. tostring(self.icon))
    XF:Debug(ObjectName, '  quality (' .. type(self.quality) .. '): ' .. tostring(self.quality))
    XF:Debug(ObjectName, '  isCached (' .. type(self.isCached) .. '): ' .. tostring(self.isCached))
end
--#endregion

--#region Accessors
function XFC.Item:GetLink()
    return self.link
end

function XFC.Item:GetFormattedLink()
    return format('%s %s', format(XF.Icons.String, self:GetIcon()), self.link)
end

function XFC.Item:SetLink(inLink)
    self.link = inLink
end

function XFC.Item:GetIcon()
    return self.icon
end

function XFC.Item:SetIcon(inIcon)
    self.icon = inIcon
end

function XFC.Item:GetQuality()
    return self.quality
end

function XFC.Item:SetQuality(inQuality)
    assert(type(inQuality) == 'number')
    self.quality = inQuality > 0 and inQuality or 1
end

function XFC.Item:IsCached(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isCached = inBoolean
    end    
    return self.isCached
end

function XFC.Item:Cache()
    try(function()
        local item = Item:CreateFromItemID(self:GetID())
        self:SetLink(item:GetItemLink())
        self:SetIcon(item:GetItemIcon())
        self:SetQuality(item:GetItemQuality())
        self:SetName(item:GetItemName())
        self:IsCached(true)
    end).
    catch(function(inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion

--#region Networking
function XFC.Item:Encode()
    local data = {}
    data.K = self:GetKey()
    data.I = self:GetID()
    data.L = self:GetLink()
    data.O = self:GetIcon()
    data.N = self:GetName()
    data.Q = self:GetQuality()
    data.C = self:IsCached()
    return data
end

function XFC.Item:Decode(inData)
    assert(type(inData) == 'table')
    self:SetKey(inData.K)
    self:SetID(inData.I)
    self:IsCached(inData.C)
    if(inData.L ~= nil) then self:SetLink(inData.L) end
    if(inData.O ~= nil) then self:SetIcon(inData.O) end
    if(inData.Q ~= nil) then self:SetQuality(inData.Q) end
    if(inData.N ~= nil) then self:SetName(inData.N) end
end
--#endregion