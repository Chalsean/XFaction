local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaidIO'  -- Because RaiderIO is taken

RaidIO = Object:newChildConstructor()

function RaidIO:new()
    local _Object = RaidIO.parent.new(self)
    _Object.__name = ObjectName
    _Object._Raid = ''
    _Object._Dungeon = 0
    return _Object
end

function RaidIO:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _Raid (' .. type(self._Raid) .. '): ' .. tostring(self._Raid))
        XFG:Debug(ObjectName, '  _Dungeon (' .. type(self._Dungeon) .. '): ' .. tostring(self._Dungeon))
    end
end

function RaidIO:GetRaid()
    return self._Raid
end

function RaidIO:SetRaid(inCount, inTotal, inDifficulty)
    assert(type(inCount) == 'number')
    assert(type(inTotal) == 'number')
    assert(type(inDifficulty) == 'number')
    local _Letter = nil
    if(inDifficulty == 3) then
        _Letter = 'M'
    elseif(inDifficulty == 2) then
        _Letter = 'H'
    else
        _Letter = 'N'
    end
    self._Raid = tostring(inCount) .. '/' .. tostring(inTotal) .. ' ' .. _Letter
end

function RaidIO:GetDungeon()
    return self._Dungeon
end

function RaidIO:SetDungeon(inScore)
    assert(type(inScore) == 'number')
    self._Dungeon = inScore
end

function RaidIO:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetObjectName() ~= inObject:GetObjectName()) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    if(self:GetRaid() ~= inObject:GetRaid()) then return false end
    if(self:GetDungeon() ~= inObject:GetDungeon()) then return false end
    return true
end