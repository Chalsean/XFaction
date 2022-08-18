local XFG, G = unpack(select(2, ...))
local ObjectName = 'Continent'

Continent = Object:newChildConstructor()

function Continent:new()
    local _Object = Continent.parent.new(self)
    _Object.__name = ObjectName
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
end

function Continent:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
        XFG:Debug(ObjectName, '  IDs: ')
        XFG:DataDumper(ObjectName, self._IDs)
    end
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
end

function Continent:AddID(inID)
    assert(type(inID) == 'number')
    self._IDs[#self._IDs + 1] = inID
end

function Continent:GetLocaleName()
    return self._LocaleName or self:GetName()
end

function Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
end