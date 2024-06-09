local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RaiderIO'

XFRaiderIO = XFC.Object:newChildConstructor()

--#region Constructors
function XFRaiderIO:new()
    local object = XFRaiderIO.parent.new(self)
    object.__name = ObjectName
    object.raid = ''
    object.dungeon = 0
    return object
end

function XFRaiderIO:Deconstructor()
    self:ParentDeconstructor()
    self.raid = ''
    self.dungeon = 0
end
--#endregion

--#region Print
function XFRaiderIO:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  raid (' .. type(self.raid) .. '): ' .. tostring(self.raid))
    XF:Debug(ObjectName, '  dungeon (' .. type(self.dungeon) .. '): ' .. tostring(self.dungeon))
end
--#endregion

--#region Accessors
function XFRaiderIO:GetRaid()
    return self.raid
end

function XFRaiderIO:SetRaid(inCount, inTotal, inDifficulty)
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

function XFRaiderIO:GetDungeon()
    return self.dungeon
end

function XFRaiderIO:SetDungeon(inScore)
    assert(type(inScore) == 'number')
    self.dungeon = inScore
end
--#endregion

--#region Operators
function XFRaiderIO:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:ObjectName() ~= inObject:ObjectName()) then return false end
    if(self:Key() ~= inObject:Key()) then return false end
    if(self:GetRaid() ~= inObject:GetRaid()) then return false end
    if(self:GetDungeon() ~= inObject:GetDungeon()) then return false end
    return true
end
--#endregion