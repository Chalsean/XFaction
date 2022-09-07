local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaidIO'  -- Because RaiderIO is taken

RaidIO = Object:newChildConstructor()

--#region Constructors
function RaidIO:new()
    local object = RaidIO.parent.new(self)
    object.__name = ObjectName
    object.raid = ''
    object.dungeon = 0
    return object
end
--#endregion

--#region Print
function RaidIO:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  raid (' .. type(self.raid) .. '): ' .. tostring(self.raid))
        XFG:Debug(ObjectName, '  dungeon (' .. type(self.dungeon) .. '): ' .. tostring(self.dungeon))
    end
end
--#endregion

--#region Accessors
function RaidIO:GetRaid()
    return self.raid
end

function RaidIO:SetRaid(inCount, inTotal, inDifficulty)
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

function RaidIO:GetDungeon()
    return self.dungeon
end

function RaidIO:SetDungeon(inScore)
    assert(type(inScore) == 'number')
    self.dungeon = inScore
end
--#endregion

--#region Operators
function RaidIO:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetObjectName() ~= inObject:GetObjectName()) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    if(self:GetRaid() ~= inObject:GetRaid()) then return false end
    if(self:GetDungeon() ~= inObject:GetDungeon()) then return false end
    return true
end
--#endregion

--#region Janitorial
function RaidIO:FactoryReset()
    self:ParentFactoryReset()
    self.raid = ''
    self.dungeon = 0
    self:Initialize()
end
--#endregion