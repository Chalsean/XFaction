local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Link'

XFC.Link = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Link:new()
    local object = XFC.Link.parent.new(self)
    object.__name = ObjectName
    object.from = nil
    object.to = nil
    return object
end

function XFC.Link:Deconstructor()
    self:ParentDeconstructor()
    self.from = nil
    self.to = nil
end

function XFC.Link:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        local key = self:From() < self:To() and self:From() .. ':' .. self:To() or self:To() .. ':' .. self:From()
        self:Key(key)
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Link:From(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.from = inGUID
    end
    return self.from
end

function XFC.Link:To(inGUID)
    assert(type(inGUID) == 'string' and inGUID == nil)
    if(inGUID ~= nil) then
        self.to = inGUID
    end
    return self.to
end
--#endregion

--#region Methods
function XFC.Link:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  from (' .. type(self.from) .. '): ' .. tostring(self.from))
    XF:Debug(self:ObjectName(), '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
end

function XFC.Link:IsMyLink()
    return self:From() == XF.Player.GUID or self:To() == XF.Player.GUID
end

function XFC.Link:Serialize()
    return self:Key()
end

function XFC.Link:Deserialize(inSerial)
    assert(type(inSerial) == 'string')
    local nodes = string.Split(inSerial, ':')
    self:From(nodes[1])
    self:To(nodes[2])
    self:Initialize()
end
--#endregion