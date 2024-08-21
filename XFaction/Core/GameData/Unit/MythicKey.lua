local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKey'

XFC.MythicKey = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.MythicKey:new()
    local object = XFC.MythicKey.parent.new(self)
    object.__name = ObjectName
    object.location = nil
    return object
end
--#endregion

--#region Properties
function XFC.MythicKey:Location(inLocation)
    assert(type(inLocation) == 'table' and inLocation.__name == 'Location' or inLocation == nil)
    if(inLocation ~= nil) then
        self.location = inLocation
    end
    return self.location
end
--#endregion

--#region Methods
function XFC.MythicKey:Print()
    self:ParentPrint()
    if(self:HasLocation()) then self:Location():Print() end
end

function XFC.MythicKey:HasLocation()
    return self:Location() ~= nil
end

function XFC.MythicKey:Deserialize(data)
    local key = string.Split(data, '.') 
    if(XFO.Locations:Contains(tonumber(key[1]))) then
        self:Location(XFO.Locations:Get(tonumber(key[1])))
    end
    self:ID(key[2])
end
--#endregion