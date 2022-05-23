local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Zone'
local LogCategory = 'UZone'

Zone = {}

function Zone:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

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
        self._ID = nil
		self._Name = nil
        self._Initialized = false
    end

    return Object
end

function Zone:Initialize()
    if(self:IsInitialized() == false) then        
        if(self._Name ~= nil and self._ID == nil) then
            self:SetKey(self._Name)
            if(self._Name == "?") then
                self:SetID(0)
            else
                local _, _ZoneID = CON.Lib.ZoneInfo:GetZoneInfoByName(self._Name)
                self:SetID(tonumber(_ZoneID))
            end
        end
        self:IsInitialized(true)
    end
end

function Zone:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Zone:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Zone:GetKey()
    return self._Key
end

function Zone:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Zone:GetName()
    return self._Name
end

function Zone:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Zone:GetID()
    return self._ID
end

function Zone:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Zone:Equals(inZone)
    if(inZone == nil) then return false end
    if(type(inZone) ~= 'table' or inZone.__name == nil or inZone.__name ~= 'Zone') then return false end
    if(self:GetKey() ~= inZone:GetKey()) then return false end
    return true
end