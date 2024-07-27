local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Friend'

XFC.Friend = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Friend:new()
    local object = XFC.Friend.parent.new(self)
    object.__name = ObjectName

    object.accountID = nil  -- This is the only constant ID
    object.gameID = nil     -- This is the game ID you use to send whispers
    object.accountName = nil
    object.tag = nil
    object.target = nil
    object.canLink = false
    object.isLinked = false
    object.guid = nil
    object.realm = nil
    object.faction = nil
    object.target = nil

    return object
end

function XFC.Friend:Deconstructor()
    self:ParentDeconstructor()
    self.accountID = nil  
    self.gameID = nil     
    self.accountName = nil
    self.tag = nil
    self.target = nil
    self.canLink = false
    self.isLinked = false
    self.guid = nil
    self.realm = nil
    self.faction = nil
    self.target = nil
    self:Initialize()
end
--#endregion

--#region Properties
function XFC.Friend:AccountID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(inID ~= nil) then
        self.accountID = inAccountID
    end
    return self.accountID
end

function XFC.Friend:GameID(inGameID)
    assert(type(inGameID) == 'number' or inGameID == nil)
    if(inGameID ~= nil) then
        self.gameID = inGameID
    end
    return self.gameID
end

function XFC.Friend:AccountName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.accountName = inName
    end
    return self.accountName
end

function XFC.Friend:Tag(inTag)
    assert(type(inTag) == 'string' or inTag == nil)
    if(inTag ~= nil) then
        self.tag = inTag
    end
    return self.tag
end

function XFC.Friend:GUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Friend:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil)
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Friend:Faction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil)
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end

function XFC.Friend:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil)
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Friend:IsLinked(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isLinked = inBoolean
    end
    return self.isLinked
end
--#endregion

--#region Methods
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:ObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:ObjectName(), '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(self:ObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:ObjectName(), '  canLink (' .. type(self.canLink) .. '): ' .. tostring(self.canLink))
    XF:Debug(self:ObjectName(), '  isLinked (' .. type(self.isLinked) .. '): ' .. tostring(self.isLinked))
    if(self:HasTarget()) then self:Target():Print() end
    if(self:HasRealm()) then self:Realm():Print() end
    if(self:HasFaction()) then self:Faction():Print() end
end

function XFC.Friend:HasRealm()
    return self.realm ~= nil
end

function XFC.Friend:HasFaction()
    return self.faction ~= nil
end

function XFC.Friend:HasTarget()
    return self.target ~= nil
end

function XFC.Friend:SetFromAccountInfo(inAccountInfo)
    self:Key(inAccountInfo.bnetAccountID)
    self:ID(inAccountInfo.ID)
    self:AccountID(inAccountInfo.bnetAccountID)
    self:GameID(inAccountInfo.gameAccountInfo.gameAccountID)
    self:AccountName(inAccountInfo.accountName)
    self:Tag(inAccountInfo.battleTag)
    self:Name(inAccountInfo.gameAccountInfo.characterName)
    self:Realm(XFO.Realms:Get(inAccountInfo.gameAccountInfo.realmID))
    self:Faction(XFO.Factions:Get(inAccountInfo.gameAccountInfo.factionName))
end
--#endregion