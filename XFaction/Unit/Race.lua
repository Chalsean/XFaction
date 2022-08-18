local XFG, G = unpack(select(2, ...))
local ObjectName = 'Race'

Race = Object:newChildConstructor()

function Race:new()
    local _Object = Race.parent.new(self)
    _Object.__name = ObjectName
    _Object._LocaleName = nil
	_Object._ID = nil
    _Object._Faction = nil
    return _Object
end

function Race:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
        if(self:HasFaction()) then self:GetFaction():Print() end
    end
end

function Race:GetLocaleName()
    return self._LocaleName
end

function Race:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
end

function Race:GetID()
    return self._ID
end

function Race:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
end

function Race:HasFaction()
    return self._Faction ~= nil
end

function Race:GetFaction()
    return self._Faction
end

function Race:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', 'argument must be Faction object')
    self._Faction = inFaction
end