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
    object.isOnline = false
    object.realm = nil
    object.faction = nil

    return object
end

function XFC.Friend:Initialize(inID)
    assert(type(inID) == 'number' or type(inID) == 'string')
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        local accountInfo = type(inID) == 'number' and XFF.BNetFriendInfoByID(inID) or XFF.BNetFriendInfoByGUID(inID)
        if(accountInfo ~= nil) then
            self:Key(accountInfo.bnetAccountID)
            self:ID(inID) -- Query ID, this can change between logins, thus why its not key
            self:Name(accountInfo.accountName)
            self:AccountID(accountInfo.bnetAccountID)                
            self:Tag(accountInfo.battleTag)        
            self:IsTrueFriend(accountInfo.isFriend)

            if(self:IsOnline(accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == 'WoW')) then
                self:GameID(accountInfo.gameAccountInfo.gameAccountID)
                self:GUID(accountInfo.gameAccountInfo.playerGuid)
                self:Realm(XFO.Realms:Get(tonumber(accountInfo.gameAccountInfo.realmID)))
                self:Faction(XFO.Factions:Get(accountInfo.gameAccountInfo.factionName))
            end

            self:IsInitialized(true)
        end
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

function XFC.Friend:IsOnline(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isOnline = inBoolean
    end
    return self.isOnline
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
--#endregion

--#region Methods
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:ObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:ObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:ObjectName(), '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    XF:Debug(self:ObjectName(), '  isLinked (' .. type(self.isLinked) .. '): ' .. tostring(self.isLinked))
    XF:Debug(self:ObjectName(), '  isTrueFriend (' .. type(self.isTrueFriend) .. '): ' .. tostring(self.isTrueFriend))
    XF:Debug(self:ObjectName(), '  isOnline (' .. type(self.isOnline) .. '): ' .. tostring(self.isOnline))
    if(self:HasRealm()) then self:Realm():Print() end
    if(self:HasFaction()) then self:Faction():Print() end
end

function XFC.Friend:HasRealm()
    return self:Realm() ~= nil
end

function XFC.Friend:HasFaction()
    return self:Faction() ~= nil
end

function XFC.Friend:IsSameRealm()
    return self:HasRealm() and self:Realm():Equals(XF.Player.Realm)
end

function XFC.Friend:IsSameFaction()
    return self:HasFaction() and self:Faction():Equals(XF.Player.Faction)
end

function XFC.Friend:HasUnit()
    return XFO.Confederate:Contains(self:GUID())
end

function XFC.Friend:Unit()
    return XFO.Confederate:Get(self:GUID())
end

function XFC.Friend:CanLink(inBoolean)
    if(not self:IsOnline() or not self:IsTrueFriend()) then return false end
    if(self:IsSameRealm() and self:IsSameFaction()) then return false end -- addon channel will handle this
    if(self:HasUnit() and self:Unit():IsSameTarget()) then return false end -- GUILD channel will handle this
    return true
end
--#endregion