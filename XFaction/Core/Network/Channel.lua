local XFG, G = unpack(select(2, ...))
local ObjectName = 'Channel'
local LogCategory = 'NChannel'

Channel = {}

function Channel:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._ShortName = nil
    self._Type = nil
    self._FrameID = nil
    self._OnFrame = false
    
    return _Object
end

function Channel:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _ShortName (" ..type(self._ShortName) .. "): ".. tostring(self._ShortName))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _FrameID (" ..type(self._FrameID) .. "): ".. tostring(self._FrameID))
    XFG:Debug(LogCategory, "  _OnFrame (" ..type(self._OnFrame) .. "): ".. tostring(self._OnFrame))
end

function Channel:GetKey()
    return self._Key
end

function Channel:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Channel:GetName()
    return self._Name
end

function Channel:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Channel:GetShortName()
    return self._ShortName
end

function Channel:SetShortName(inShortName)
    assert(type(inShortName) == 'string')
    self._ShortName = inShortName
    return self:GetShortName()
end

function Channel:GetID()
    return self._ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Channel:SetType(inType)
    assert(type(inType) == 'number')
    self._Type = inType
    return true
end

function Channel:HasFrameID()
    return self._FrameID ~= nil
end

function Channel:GetFrameID()
    return self._FrameID
end

function Channel:SetFrameID(inID)
    assert(type(inID) == 'number')
    self._FrameID = inID
    return self:GetFrameID()
end

function Channel:IsOnFrame(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._OnFrame = inBoolean
        if(self._OnFrame == false and self:HasFrameID()) then
            -- Store the frame id incase the user reactivates in a different session
            if(XFG.Config.Channel.Frames == nil) then
                XFG.Config.Channel.Frames = {}
            end
            XFG.Config.Channel.Frames[self:GetKey()] = self:GetFrameID()
        end
    end
    return self._OnFrame
end