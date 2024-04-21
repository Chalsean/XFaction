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

--#region Properties
function XFC.MythicKey:Dungeon(inDungeon)
    assert(type(inDungeon) == 'table' and inDungeon.__name == 'Dungeon' or inDungeon == nil, 'argument must be Dungeon object or nil')
    if(inDungeon ~= nil) then
        self.dungeon = inDungeon
    end
    return self.dungeon
end

function XFC.MythicKey:IsMyKey(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.myKey = inBoolean
    end    
    return self.myKey
end
--#endregion

--#region Methods
function XFC.MythicKey:Print()
    self:ParentPrint()
    if(self:Dungeon() ~= nil) then self:Dungeon():Print() end
end

function XFC.MythicKey:Serialize()
    return self:Dungeon():Key() .. ';' .. self:ID()
end

function XFC.MythicKey:Deserialize(data)
    local key = string.Split(data, ';') 
    if(XFO.Dungeons:Contains(tonumber(key[1]))) then
        self:Dungeon(XFO.Dungeons:Get(tonumber(key[1])))
    end
    self:ID(key[2])
end
--#endregion