local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RaiderIO'

XFC.RaiderIO = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.RaiderIO:new()
    local object = XFC.RaiderIO.parent.new(self)
    object.__name = ObjectName
    object.raid = ''
    object.dungeon = 0
    return object
end
--#endregion

--#region Properties
function XFC.RaiderIO:Raid(inCount, inTotal, inDifficulty)
    assert(type(inCount) == 'number' or inCount == nil)
    assert(type(inTotal) == 'number' or inTotal == nil)
    assert(type(inDifficulty) == 'number' or inDifficulty == nil)

    if(inCount ~= nil and inTotal ~= nil and inDifficulty ~= nil) then
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
    return self.raid
end

function XFC.RaiderIO:Dungeon(inScore)
    assert(type(inScore) == 'number' or inScore == nil)
    if(inScore ~= nil) then
        self.dungeon = inScore
    end
    return self.dungeon
end
--#endregion

--#region Methods
function XFC.RaiderIO:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  raid (' .. type(self.raid) .. '): ' .. tostring(self.raid))
    XF:Debug(self:ObjectName(), '  dungeon (' .. type(self.dungeon) .. '): ' .. tostring(self.dungeon))
end

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