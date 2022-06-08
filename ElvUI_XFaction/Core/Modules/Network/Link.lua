local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Link'
local LogCategory = 'NLink'

Link = {}

function Link:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._FromUnitName = nil
    self._FromRealm = nil
    self._FromFaction = nil
    self._ToUnitName = nil
    self._ToRealm = nil
    self._ToFaction = nil
    self._Initialized = false

    return _Object
end

-- Key is important here because it helps us avoid duplicate entries when both nodes broadcast the link
local function GetLinkKey(inFromUnitName, inToUnitName)
	assert(type(inFromUnitName) == 'string')
    assert(type(inToUnitName) == 'string')
    local _Key = (inFromUnitName < inToUnitName) and inFromUnitName .. ':' .. inToUnitName or inToUnitName .. ':' .. inFromUnitName
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
        self:SetFromUnitName(XFG.Player.Unit:GetName())
        self:SetFromRealm(XFG.Player.Realm)
        self:SetFromFaction(XFG.Player.Faction)
        self:SetKey(GetLinkKey(self:GetFromUnitName(), self:GetToUnitName()))
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Link:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _FromUnitName (" .. type(self._FromUnitName) .. "): ".. tostring(self._FromUnitName))
    XFG:Debug(LogCategory, "  _ToUnitName (" .. type(self._ToUnitName) .. "): ".. tostring(self._ToUnitName))
    XFG:Debug(LogCategory, "  _FromRealm (" .. type(self._FromRealm) .. ")")
    if(self:HasFromRealm()) then
        self._FromRealm:Print()
    end
    XFG:Debug(LogCategory, "  _FromFaction (" .. type(self._FromFaction) .. ")")
    if(self:HasFromFaction()) then
        self._FromFaction:Print()
    end
    XFG:Debug(LogCategory, "  _ToRealm (" .. type(self._ToRealm) .. ")")
    if(self:HasToRealm()) then
        self._ToRealm:Print()
    end
    XFG:Debug(LogCategory, "  _ToFaction (" .. type(self._ToFaction) .. ")")
    if(self:HasToFaction()) then
        self._ToFaction:Print()
    end
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
    return self:HasFromUnitName() and self:GetFromUnitName() == XFG.Player.Unit:GetUnitName()
end

function Link:HasFromUnitName()
    return self._FromUnitName ~= nil
end

function Link:GetFromUnitName()
    return self._FromUnitName
end

function Link:SetFromUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._FromUnitName = inUnitName
    return self:GetFromUnitName()
end

function Link:HasFromRealm()
    return self._FromRealm ~= nil
end

function Link:GetFromRealm()
    return self._FromRealm
end

function Link:SetFromRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._FromRealm = inRealm
    return self:GetFromRealm()
end

function Link:HasFromFaction()
    return self._FromFaction ~= nil
end


function Link:GetFromFaction()
    return self._FromFaction
end

function Link:SetFromFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._FromFaction = inFaction
    return self:GetFromFaction()
end

function Link:HasToUnitName()
    return self._ToUnitName ~= nil
end

function Link:GetToUnitName()
    return self._ToUnitName
end

function Link:SetToUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._ToUnitName = inUnitName
    return self:GetToUnitName()
end

function Link:HasToRealm()
    return self._ToRealm ~= nil
end

function Link:GetToRealm()
    return self._ToRealm
end

function Link:SetToRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._ToRealm = inRealm
    return self:GetToRealm()
end

function Link:HasToFaction()
    return self._ToFaction ~= nil
end


function Link:GetToFaction()
    return self._ToFaction
end

function Link:SetToFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._ToFaction = inFaction
    return self:GetToFaction()
end

function Link:GetString()
    local _FromRealm = self:GetFromRealm()
    local _ToRealm = self:GetToRealm()
    local _FromFaction = self:GetFromFaction()
    local _ToFaction = self:GetToFaction()
    return self:GetFromUnitName() .. ':' .. _FromRealm:GetID() .. ':' .. _FromFaction:GetID() .. ';' .. self:GetToUnitName() .. ':' .. _ToRealm:GetID() .. ':' .. _ToFaction:GetID()
end

function Link:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')    
    local _Nodes = string.Split(inLinkString, ';')

    local _FromNodeIDs = string.Split(_Nodes[1], ':')    
    self:SetFromUnitName(_FromNodeIDs[1])
    self:SetFromRealm(XFG.Realms:GetRealmByID(_FromNodeIDs[2]))
    self:SetFromFaction(XFG.Factions:GetFaction(_FromNodeIDs[3]))

    local _ToNodeIDs = string.Split(_Nodes[2], ':')
    self:SetToUnitName(_ToNodeIDs[1])
    self:SetToRealm(XFG.Realms:GetRealmByID(_ToNodeIDs[2]))
    self:SetToFaction(XFG.Factions:GetFaction(_ToNodeIDs[3]))

    local _Key = GetLinkKey(self:GetFromUnitName(), self:GetToUnitName())
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