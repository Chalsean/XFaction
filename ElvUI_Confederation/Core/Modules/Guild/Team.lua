local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Team'
local LogCategory = 'O' .. ObjectName

Team = {}

function Team:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._Units = {}
        self._NumberOfUnits = 0
    end

    return Object
end

function Team:Print(inPrintOffline)
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Team Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    CON:DataDumper(LogCategory, self._Units)
    -- for _Key, _Unit in pairs (self._Units) do
    --     if(inPrintOffline == true or _Unit:IsOnline()) then    
    --         _Unit:Print()
    --     end
    -- end
end

function Team:ShallowPrint()
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Team Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
end

function Team:GetKey()
    return self._Key
end

function Team:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Team:GetName()
    return self._Name
end

function Team:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Team:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Team:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:Contains(inUnit:GetKey()) == false) then
        --inUnit:Print()
        table.insert(self._Units, { [inUnit:GetKey()] = inUnit })
        --self._Units[inUnit:GetKey()] = inUnit
        self._NumberOfUnits = self._NumberOfUnits + 1
    end

    return self:Contains(inUnit:GetKey())
end