local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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

--#region Hash
function XFC.MythicKeyCollection:Add(inMythicKey)
    assert(type(inMythicKey) == 'table' and inMythicKey.__name ~= nil and inMythicKey.__name == 'MythicKey', 'argument must be MythicKey object')
    if(inMythicKey.IsMyKey()) then
        self:SetMyKey(inMythicKey)
    end
    self.parent.Add(self, inMythicKey)
end
--#endregion

--#region Accessors
function XFC.MythicCollection:HasMyKey()
    return self.myKey ~= nil
end

function XFC.MythicCollection:GetMyKey()
    return self.myKey
end

function XFC.MythicCollection:SetMyKey(inMythicKey)
    assert(type(inMythicKey) == 'table' and inMythicKey.__name ~= nil and inMythicKey.__name == 'MythicKey', 'argument must be MythicKey object')
    self.myKey = inMythicKey
end
--#endregion