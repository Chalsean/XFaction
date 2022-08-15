local XFG, G = unpack(select(2, ...))

Race = Object:newChildConstructor()

function Race:new()
    local _Object = Race.parent.new(self)
    _Object.__name = 'Race'
    _Object._LocaleName = nil
	_Object._ID = nil
    _Object._Faction = nil
    return _Object
end

function Race:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(self:GetObjectName(), '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
    if(self:HasFaction()) then self:GetFaction():Print() end
end

function Race:GetLocaleName()
    return self._LocaleName
end

function Race:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
    return self:GetLocaleName()
end

function Race:GetID()
    return self._ID
end

function Race:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
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
    return self:GetFaction()
end