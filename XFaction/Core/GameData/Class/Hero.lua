local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Hero'

XFC.Hero = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Hero:new()
    local object = XFC.Hero.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.class = nil
    object.spellID = nil
    return object
end
--#endregion

--#region Properties
function XFC.Hero:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil)
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end

function XFC.Hero:Class(inClass)
    assert(type(inClass) == 'table' and inClass.__name == 'Class' or inClass == nil)
    if(inClass ~= nil) then
        self.class = inClass
    end
    return self.class
end

function XFC.Hero:SpellID(inSpellID)
    assert(type(inSpellID) == 'number' or inSpellID == nil)
    if(inSpellID ~= nil) then
        self.spellID = inSpellID
    end
    return self.spellID
end
--#endregion

--#region Methods
function XFC.Hero:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    if(self:HasClass()) then self:Class():Print() end
end

function XFC.Hero:HasClass()
    return self.class ~= nil
end
--#endregion