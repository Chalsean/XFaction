local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKeyCollection'

XFC.MythicKeyCollection = XFC.ObjectCollection:newChildConstructor()

-- Additional logic exists in Mainline branch

--#region Constructors
function XFC.MythicKeyCollection:new()
    local object = XFC.MythicKeyCollection.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.MythicKeyCollection:Deserialize(inKey)
    assert(type(inKey) == 'string')
    if(not self:Contains(inKey)) then
        local key = XFC.MythicKey:new()
        key:Initialize()
        key:Key(inKey)
        self:Add(key)
    end
    return self:Get(inKey)
end
--#endregion