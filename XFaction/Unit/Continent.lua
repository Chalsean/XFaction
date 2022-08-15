local XFG, G = unpack(select(2, ...))

Continent = Object:newChildConstructor()

function Continent:new()
    local _Object = Continent.parent.new(self)
    _Object.__name = 'Continent'
    _Object._IDs = nil
    _Object._LocaleName = nil
    return _Object
end

function Continent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self._IDs = {}
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Continent:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
    XFG:Debug(self:GetObjectName(), '  IDs: ')
    XFG:DataDumper(self:GetObjectName(), self._IDs)
end

function Continent:HasID(inID)
    assert(type(inID) == 'number')
    for _, _ID in ipairs(self._IDs) do
        if(_ID == inID) then
            return true
        end
    end
    return false
end

function Continent:GetID()
    if(#self._IDs > 0) then
        return self._IDs[1]
    end
    return nil
end

function Continent:AddID(inID)
    assert(type(inID) == 'number')
    table.insert(self._IDs, inID)
    return self:GetID()
end

function Continent:GetLocaleName()
    return self._LocaleName or self:GetName()
end

function Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
    return self:GetLocaleName()
end