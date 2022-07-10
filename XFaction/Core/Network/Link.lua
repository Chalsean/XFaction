local XFG, G = unpack(select(2, ...))
local ObjectName = 'Link'
local LogCategory = 'NLink'

Link = {}

function Link:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._FromNode = nil
    self._ToNode = nil
    self._EpochTime = 0
    self._Initialized = false

    return _Object
end

-- Key is important here because it helps us avoid duplicate entries when both nodes broadcast the link
local function GetLinkKey(inFromName, inToName)
	assert(type(inFromName) == 'string')
    assert(type(inToName) == 'string')
    local _Key = (inFromName < inToName) and inFromName .. ':' .. inToName or inToName .. ':' .. inFromName
	return _Key
end

function Link:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Link:Initialize()
    if(self:IsInitialized() == false) then
        local _EpochTime = GetServerTime()
        self:SetTimeStamp(_EpochTime)
        local _Key = GetLinkKey(self:GetFromNode():GetName(), self:GetToNode():GetName())
        self:SetKey(_Key)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Link:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _EpochTime (" .. type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    self._FromNode:Print()
    self._ToNode:Print()
end

function Link:GetKey()
    return self._Key
end

function Link:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Link:IsMyLink()
    return self._FromNode:IsMyNode() or self._ToNode:IsMyNode()
end

function Link:GetFromNode()
    return self._FromNode
end

function Link:SetFromNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self._FromNode = inNode
    return self:GetFromNode()
end

function Link:GetToNode()
    return self._ToNode
end

function Link:SetToNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self._ToNode = inNode
    return self:GetToNode()
end

function Link:GetString()
    return self:GetFromNode():GetString() .. ';' .. self:GetToNode():GetString()
end

function Link:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')
    local _Nodes = string.Split(inLinkString, ';')

    local _FromNode = Node:new(); _FromNode:Initialize(_Nodes[1])
    if(not XFG.Nodes:Contains(_FromNode:GetKey())) then
        XFG.Nodes:AddNode(_FromNode)
    end
    self:SetFromNode(XFG.Nodes:GetNode(_FromNode:GetKey()))

    local _ToNode = Node:new(); _ToNode:Initialize(_Nodes[2])
    if(not XFG.Nodes:Contains(_ToNode:GetKey())) then
        XFG.Nodes:AddNode(_ToNode)
    end
    self:SetToNode(XFG.Nodes:GetNode(_ToNode:GetKey()))
    
    local _EpochTime = GetServerTime()
    self:SetTimeStamp(_EpochTime)

    local _Key = GetLinkKey(self:GetFromNode():GetName(), self:GetToNode():GetName())
    self:SetKey(_Key)
    self:IsInitialized(true)
    return self:IsInitialized()
end

function Link:Equals(inLink)
    if(inLink == nil) then return false end
    if(type(inLink) ~= 'table' or inLink.__name == nil or inLink.__name ~= 'Link') then return false end
    if(self:GetKey() ~= inLink:GetKey()) then return false end
    return true
end

function Link:GetTimeStamp()
    return self._EpochTime
end

function Link:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
    return self:GetTimeStamp()
end