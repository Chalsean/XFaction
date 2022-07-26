local XFG, G = unpack(select(2, ...))
local ObjectName = 'Metric'
local LogCategory = 'MMetric'

Metric = {}

function Metric:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Data = nil
    self._Count = 0

    return Object
end

function Metric:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _Count (' .. type(self._Count) .. '): ' .. tostring(self._Count))
    XFG:DataDumper(LogCategory, self._Data)
end

function Metric:GetKey()
    return self._Key
end

function Metric:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Metric:GetName()
    return self._Name
end

function Metric:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Metric:Increment()
    self:AddData(1)
end

function Metric:AddData(inData)
    assert(type(inPath) == 'number')
    if(self._Data == nil) then self._Data = {} end
    local _Time = GetServerTime()
    self._Data[_Time] = inData
    self._Count = self._Count + 1
end

function Metric:GetCount()
    return self._Count
end

function Metric:GetTotal()
    local _Total = 0
    for _, _Data in pairs (self._Data) do
        _Total = _Total + _Data
    end
    return _Total
end

function Metric:GetAverage()
    if(self:GetCount() == 0) then return 0 end
    return self:GetTotal() / self:GetCount()
end

function Metric:Purge(inEpochTime)
    for _Time, _ in pairs (self._Data) do
        if(_Time < inEpochTime) then
            self._Data[_Time] = nil
            self._Total = self._Total - 1
        end
    end
end