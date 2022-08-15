local XFG, G = unpack(select(2, ...))

Zone = Object:newChildConstructor()

function Zone:new()
    local _Object = Zone.parent.new(self)
    _Object.__name = 'Zone'
    _Object._IDs = nil
    _Object._LocaleName = nil
    _Object._Continent = nil
    return _Object
end

function Zone:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self._IDs = {}
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Zone:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
    XFG:Debug(self:GetObjectName(), '  IDs: ')
    XFG:DataDumper(self:GetObjectName(), self._IDs)
    if(self:HasContinent()) then self:GetContinent():Print() end
end

function Zone:HasID()
    return #self._IDs > 0
end

function Zone:GetID()
    if(self:HasID()) then
        return self._IDs[1]
    end
end

function Zone:AddID(inID)
    assert(type(inID) == 'number')
    table.insert(self._IDs, inID)
    return self:GetID()
end

function Zone:GetLocaleName()
    return self._LocaleName or self:GetName()
end

function Zone:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
    return self:GetLocaleName()
end

function Zone:HasContinent()
    return self._Continent ~= nil
end


function Zone:GetContinent()
    return self._Continent
end

function Zone:SetContinent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name ~= nil and inContinent.__name == 'Continent', 'argument must be Continent object')
    self._Continent = inContinent
    return self:GetContinent()
end

function Zone:IDIterator()
	return next, self._IDs, nil
end