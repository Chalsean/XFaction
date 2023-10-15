local XF, G = unpack(select(2, ...))
local ObjectName = 'Friend'

Friend = Object:newChildConstructor()

--#region Constructors
function Friend:new()
    local object = Friend.parent.new(self)
    object.__name = ObjectName

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
    XF:Debug(ObjectName, '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(ObjectName, '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(ObjectName, '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(ObjectName, '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(ObjectName, '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(ObjectName, '  myLink (' .. type(self.myLink) .. '): ' .. tostring(self.myLink))
    if(self:HasTarget()) then self:GetTarget():Print() end
end

function Friend:Deconstructor()
    self:ParentDeconstructor()
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

--#region Accessors
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
            link = XF.Links:Pop()
            local fromNode = XF.Nodes:Get(XF.Player.Unit:GetName())
            if(fromNode == nil) then
                fromNode = XF.Nodes:Pop()
                fromNode:Initialize()
                XF.Nodes:Add(fromNode)
            end
            link:SetFromNode(fromNode)

            local toNode = XF.Nodes:Get(self:GetName())
            if(toNode == nil) then
                toNode = XF.Nodes:Pop()
                toNode:SetKey(self:GetName())
                toNode:SetName(self:GetName())
                toNode:SetTarget(self:GetTarget())
                XF.Nodes:Add(toNode)
            end
            link:SetToNode(toNode)

            link:Initialize()
            XF.Links:Add(link)
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
            XF.Links:Push(link)
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
    XF:Debug(ObjectName, 'Sending ping to [%s]', self:GetTag())
    XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'PING', _, self:GetGameID())
    XF.Metrics:Get(XF.Enum.Metric.BNetSend):Increment() 
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

    local realm = XF.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
    local faction = XF.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)
    local target = XF.Targets:GetByRealmFaction(realm, faction)
    self:SetTarget(target)
end
--#endregion