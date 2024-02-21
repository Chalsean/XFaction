local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'MythicKey'

XFC.MythicKey = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.MythicKey:new()
    local object = XFC.MythicKey.parent.new(self)
    object.__name = ObjectName
    object.dungeon = nil
    object.myKey = false
    return object
end
--#endregion

--#region Print
function XFC.MythicKey:Print()
    self:ParentPrint()
    if(self:HasDungeon()) then self:GetDungeon():Print() end
end
--#endregion

--#region Accessors
function XFC.MythicKey:HasDungeon()
    return self.dungeon ~= nil
end

function XFC.MythicKey:GetDungeon()
    return self.dungeon
end

function XFC.MythicKey:SetDungeon(inDungeon)
    assert(type(inDungeon) == 'table' and inDungeon.__name ~= nil and inDungeon.__name == 'Dungeon', 'argument must be Dungeon object')
    self.dungeon = inDungeon
end

function XFC.MythicKey:IsMyKey(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.myKey = inBoolean
    end    
    return self.myKey
end
--#endregion

--#region Serialize
function XFC.MythicKey:Serialize()
    return self:HasDungeon() and self:GetDungeon():GetKey() .. ';' .. self:GetID() or nil
end

function XFC.MythicKey:Deserialize(data)
    local key = string.Split(data, ';') 
    if(XFO.Dungeons:Contains(tonumber(key[1]))) then
        self:SetDungeon(XFO.Dungeons:Get(tonumber(key[1])))
    end
    self:SetID(key[2])
end
--#endregion