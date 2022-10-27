local XFG, G = unpack(select(2, ...))
local ObjectName = 'Friend'

Friend = Object:newChildConstructor()

--#region Constructors
function Friend:new()
    local object = Friend.parent.new(self)
    object.__name = ObjectName

    object.ID = nil         -- This the "friend index" you use to look things up
    object.accountID = nil  -- This is the only constant ID
    object.gameID = nil     -- This is the game ID you use to send whispers
    object.accountName = nil
    object.tag = nil
    object.target = nil
    object.isRunningAddon = false
    object.myLink = false

    return object
end
--#endregion

--#region Print
function Friend:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XFG:Debug(ObjectName, '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XFG:Debug(ObjectName, '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XFG:Debug(ObjectName, '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XFG:Debug(ObjectName, '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XFG:Debug(ObjectName, '  myLink (' .. type(self.myLink) .. '): ' .. tostring(self.myLink))
    if(self:HasTarget()) then self:GetTarget():Print() end
end
--#endregion

--#region Accessors
function Friend:GetID()
    return self.ID
end

function Friend:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Friend:GetAccountID()
    return self.accountID
end

function Friend:SetAccountID(inAccountID)
    assert(type(inAccountID) == 'number')
    self.accountID = inAccountID
end

function Friend:GetGameID()
    return self.gameID
end

function Friend:SetGameID(inGameID)
    assert(type(inGameID) == 'number')
    self.gameID = inGameID
end

function Friend:GetAccountName()
    return self.accountName
end

function Friend:SetAccountName(inAccountName)
    assert(type(inAccountName) == 'string')
    self.accountName = inAccountName
end

function Friend:GetTag()
    return self.tag
end

function Friend:SetTag(inTag)
    assert(type(inTag) == 'string')
    self.tag = inTag
end

function Friend:HasTarget()
    return self.target ~= nil
end

function Friend:GetTarget()
    return self.target
end

function Friend:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    self.target = inTarget
end

function Friend:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end
--#endregion

--#region Link
function Friend:CreateLink()
    if(self:IsRunningAddon() and self:HasTarget()) then
        local link = nil
        try(function ()
            link = XFG.Links:Pop()
            local fromNode = XFG.Nodes:Get(XFG.Player.Unit:GetName())
            if(fromNode == nil) then
                fromNode = XFG.Nodes:Pop()
                fromNode:Initialize()
                XFG.Nodes:Add(fromNode)
            end
            link:SetFromNode(fromNode)

            local toNode = XFG.Nodes:Get(self:GetName())
            if(toNode == nil) then
                toNode = XFG.Nodes:Pop()
                toNode:SetKey(self:GetName())
                toNode:SetName(self:GetName())
                toNode:SetTarget(self:GetTarget())
                XFG.Nodes:Add(toNode)
            end
            link:SetToNode(toNode)

            link:Initialize()
            XFG.Links:Add(link)
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
            XFG.Links:Push(link)
        end)
    end
end

function Friend:IsMyLink(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self.myLink = inBoolean
    end
    return self.myLink
end
--#endregion

--#region Network
function Friend:Ping()
    XFG:Debug(ObjectName, 'Sending ping to [%s]', self:GetTag())
    XFG.Lib.BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'PING', _, self:GetGameID())
    XFG.Metrics:Get(XFG.Settings.Metric.BNetSend):Increment() 
end
--#endregion

--#region DataSet
function Friend:SetFromAccountInfo(inAccountInfo)
    self:SetKey(inAccountInfo.bnetAccountID)
    self:SetID(inAccountInfo.ID)
    self:SetAccountID(inAccountInfo.bnetAccountID)
    self:SetGameID(inAccountInfo.gameAccountInfo.gameAccountID)
    self:SetAccountName(inAccountInfo.accountName)
    self:SetTag(inAccountInfo.battleTag)
    self:SetName(inAccountInfo.gameAccountInfo.characterName)

    local realm = XFG.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
    local faction = XFG.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)
    local target = XFG.Targets:GetByRealmFaction(realm, faction)
    self:SetTarget(target)
end
--#endregion

--#region Janitorial
function Friend:FactoryReset()
    self:ParentFactoryReset()
    self.ID = nil         
    self.accountID = nil  
    self.gameID = nil     
    self.accountName = nil
    self.tag = nil
    self.target = nil
    self.isRunningAddon = false
    self.myLink = false
    self:Initialize()
end
--#endregion