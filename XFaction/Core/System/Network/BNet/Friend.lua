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
    object.isLinked = false
    object.guid = nil
    object.isTrueFriend = false
    object.realm = nil
    object.faction = nil

    return object
end

function XFC.Friend:Deconstructor()
    self:ParentDeconstructor()
    self.accountID = nil  
    self.gameID = nil
    self.tag = nil
    self.isLinked = false    
    self.guid = nil
    self.isTrueFriend = false
    self.realm = nil
    self.faction = nil
end

function XFC.Friend:Initialize(inID)
    assert(type(inID) == 'number')
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        local accountInfo = XFF.BNetFriendInfo(inID)
        self:Key(accountInfo.bnetAccountID)
        self:ID(inID) -- Query ID, this can change between logins, thus why its not key
        self:Name(accountInfo.accountName)
        self:AccountID(accountInfo.bnetAccountID)
        self:GameID(accountInfo.gameAccountInfo.gameAccountID)        
        self:Tag(accountInfo.battleTag)
        self:GUID(accountInfo.playerGuid)
        self:IsTrueFriend(accountInfo.isFriend)

        self:IsInitialized(true)
    end
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

function XFC.Friend:IsLinked(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isLinked = inBoolean
    end
    return self.isLinked
end

function XFC.Friend:IsTrueFriend(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isTrueFriend = inBoolean
    end
    return self.isTrueFriend
end

function XFC.Friend:Realm(inRealm)
    assert(type(inRealm) == 'Realm' or inRealm == nil)
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Friend:Faction(inFaction)
    assert(type(inFaction) == 'Faction' or inFaction == nil)
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end
--#endregion

--#region Methods
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:ObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:ObjectName(), '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(self:ObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:ObjectName(), '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    XF:Debug(self:ObjectName(), '  isLinked (' .. type(self.isLinked) .. '): ' .. tostring(self.isLinked))
    XF:Debug(self:ObjectName(), '  isTrueFriend (' .. type(self.isTrueFriend) .. '): ' .. tostring(self.isTrueFriend))
    if(self:HasRealm()) then self:Realm():Print() end
    if(self:HasFaction()) then self:Faction():Print() end
end

function XFC.Friend:HasRealm()
    return self:Realm() ~= nil
end

function XFC.Friend:HasFaction()
    return self:Faction() ~= nil
end

function XFC.Friend:HasUnit()
    return XFO.Confederate:Contains(self:GUID())
end

function XFC.Friend:Unit()
    return XFO.Confederate:Get(self:GUID())
end

function XFC.Friend:CanLink(inBoolean)
    if(not self:IsTrueFriend()) then return false end
    if(self:HasFaction() and self:Faction():Equals(XF.Player.Faction)) then return false end -- Whispers will handle this    
    if(self:HasUnit() and self:Unit():IsSameGuild()) then return false end -- GUILD channel will handle this    
    return true
end
--#endregion