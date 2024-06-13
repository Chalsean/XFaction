local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKeyCollection'

XFC.MythicKeyCollection = XFC.ObjectCollection:newChildConstructor()

-- Additional logic exists in Mainline branch

--#region Constructors
function XFC.MythicKeyCollection:new()
    local object = XFC.MythicKeyCollection.parent.new(self)
    object.__name = ObjectName
    object.myKey = nil
    return object
end
--#endregion

--#region Properties
function XFC.MythicKeyCollection:MyKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name == 'MythicKey' or inKey == nil)
    if(inKey ~= nil) then
        self.myKey = inKey
    end
    return self.myKey
end
--#endregion

--#region Methods
function XFC.MythicKeyCollection:Add(inMythicKey)
    assert(type(inMythicKey) == 'table' and inMythicKey.__name == 'MythicKey')
    if(inMythicKey.IsMyKey()) then
        self:MyKey(inMythicKey)
    end
    if(not self:Contains(inMythicKey:Key())) then
        self.parent.Add(self, inMythicKey)
    end
end

function XFC.MythicKeyCollection:HasMyKey()
    return self.myKey ~= nil
end
--#endregion