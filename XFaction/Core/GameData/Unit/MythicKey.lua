local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKey'

XFC.MythicKey = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.MythicKey:new()
    local object = XFC.MythicKey.parent.new(self)
    object.__name = ObjectName
    object.dungeon = nil
    return object
end
--#endregion

--#region Properties
function XFC.MythicKey:Dungeon(inDungeon)
    assert(type(inDungeon) == 'table' and inDungeon.__name == 'Dungeon' or inDungeon == nil)
    if(inDungeon ~= nil) then
        self.dungeon = inDungeon
    end
    return self.dungeon
end
--#endregion

--#region Methods
function XFC.MythicKey:Print()
    self:ParentPrint()
    if(self:HasDungeon()) then self:Dungeon():Print() end
end

function XFC.MythicKey:HasDungeon()
    return self:Dungeon() ~= nil
end

function XFC.MythicKey:Deserialize(data)
    local key = string.Split(data, '.') 
    if(XFO.Dungeons:Contains(tonumber(key[2]))) then
        self:Dungeon(XFO.Dungeons:Get(tonumber(key[2])))
    end
    self:ID(key[1])
    self:Key(data)
end
--#endregion