local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

XFC.Dungeon = Object:newChildConstructor()

--#region Constructors
function XFC.Dungeon:new()
    local object = XFC.Dungeon.parent.new(self)
    object.__name = 'Dungeon'
    object.shortName = nil
    return object
end
--#endregion

--#region Print
function XFC.Dungeon:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  shortName (' .. type(self.shortName) .. '): ' .. tostring(self.shortName))
end
--#endregion

--#region Accessors
function XFC.Dungeon:GetShortName()
    return self.shortName
end

function XFC.Dungeon:SetShortName(inName)
    assert(type(inName) == 'string')
    self.shortName = inName
end
--#endregion