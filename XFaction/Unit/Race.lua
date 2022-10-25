local XFG, G = unpack(select(2, ...))
local ObjectName = 'Race'

Race = Object:newChildConstructor()

--#region Constructors
function Race:new()
    local object = Race.parent.new(self)
    object.__name = ObjectName
	object.ID = nil
    object.faction = nil
    return object
end
--#endregion

--#region Print
function Race:Print()
    if(XFG.Verbosity) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        if(self:HasFaction()) then self:GetFaction():Print() end
    end
end
--#endregion

--#region Accessors
function Race:GetID()
    return self.ID
end

function Race:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Race:HasFaction()
    return self.faction ~= nil
end

function Race:GetFaction()
    return self.faction
end

function Race:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end
--#endregion