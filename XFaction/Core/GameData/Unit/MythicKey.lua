local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKey'

XFC.MythicKey = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.MythicKey:new()
    local object = XFC.MythicKey.parent.new(self)
    object.__name = ObjectName
    object.dungeon = nil
    object.isMyKey = false
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

function XFC.MythicKey:Key(inKey)
    assert(type(inKey) == 'string' or inKey == nil)    
    if(inKey ~= nil) then
        self:Deserialize(inKey)
        self.key = inKey
    elseif(self.key == nil) then
        self.key = self:Serialize()
    end
    return self.key
end

function XFC.MythicKey:IsMyKey(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isMyKey = inBoolean
    end
    --return self.isMyKey
end
--#endregion

--#region Methods
function XFC.MythicKey:Print()
    self:ParentPrint()
    if(self:HasDungeon()) then self:Dungeon():Print() end
end

function XFC.MythicKey:Refresh()
    local level = XFF.PlayerGetKeyLevel()
    if(level ~= nil) then
        self:ID(level)
    end
    
    local mapID = XFF.PlayerGetKeyMap()
    if(mapID ~= nil) then
        if(XFO.Dungeons:Contains(mapID)) then
            self:Dungeon(XFO.Dungeons:Get(mapID))
        end        
    end
end

function XFC.MythicKey:HasDungeon()
    return self.dungeon ~= nil
end

function XFC.MythicKey:Serialize()
    return self:HasDungeon() and self:Dungeon():Key() .. ';' .. self:ID() or nil
end

function XFC.MythicKey:Deserialize(data)
    local key = string.Split(data, ';') 
    if(XFO.Dungeons:Contains(tonumber(key[1]))) then
        self:Dungeon(XFO.Dungeons:Get(tonumber(key[1])))
    end
    self:ID(key[2])
end
--#endregion