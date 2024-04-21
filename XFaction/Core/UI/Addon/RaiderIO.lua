local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'RaiderIO'

XFC.RaiderIO = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.RaiderIO:new()
    local object = XFC.RaiderIO.parent.new(self)
    object.__name = ObjectName
    object.raid = ''
    object.dungeon = 0
    return object
end

function XFC.RaiderIO:Deconstructor()
    self:ParentDeconstructor()
    self.raid = ''
    self.dungeon = 0
end
--#endregion

--#region Print
function XFC.RaiderIO:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  raid (' .. type(self.raid) .. '): ' .. tostring(self.raid))
    XF:Debug(ObjectName, '  dungeon (' .. type(self.dungeon) .. '): ' .. tostring(self.dungeon))
end
--#endregion

--#region Accessors
function XFC.RaiderIO:GetRaid()
    return self.raid
end

function XFC.RaiderIO:SetRaid(inCount, inTotal, inDifficulty)
    assert(type(inCount) == 'number')
    assert(type(inTotal) == 'number')
    assert(type(inDifficulty) == 'number')
    local letter = nil
    if(inDifficulty == 3) then
        letter = 'M'
    elseif(inDifficulty == 2) then
        letter = 'H'
    else
        letter = 'N'
    end
    self.raid = tostring(inCount) .. '/' .. tostring(inTotal) .. ' ' .. letter
end

function XFC.RaiderIO:GetDungeon()
    return self.dungeon
end

function XFC.RaiderIO:SetDungeon(inScore)
    assert(type(inScore) == 'number')
    self.dungeon = inScore
end
--#endregion

--#region Operators
function XFC.RaiderIO:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:ObjectName() ~= inObject:ObjectName()) then return false end
    if(self:Key() ~= inObject:Key()) then return false end
    if(self:Raid() ~= inObject:Raid()) then return false end
    if(self:Dungeon() ~= inObject:Dungeon()) then return false end
    return true
end
--#endregion