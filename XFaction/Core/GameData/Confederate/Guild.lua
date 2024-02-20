local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Guild'
local GetClubMembers = C_Club.GetClubMembers

XFC.Guild = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Guild:new()
    local object = XFC.Guild.parent.new(self)
    object.__name = ObjectName
    object.streamID = nil  -- Only the player's guild will have a StreamerID (this is gchat)
    object.initials = nil
    object.realm = nil
    return object
end
--#endregion

--#region Print
function XFC.Guild:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  streamID (' .. type(self.streamID) .. '): ' .. tostring(self.streamID))
    XF:Debug(self:GetObjectName(), '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
    if(self:HasRealm()) then self:GetRealm():Print() end
end

function XFC.Guild:PrintAudit()
    XF:Info('Audit', 'Name,Note,Rank,LastLoginDaysAgo')
    for _, memberID in pairs (GetClubMembers(XF.Player.Guild:GetID(), XF.Player.Guild:GetStreamID())) do
        local unit = Unit:new()
        unit:Initialize(memberID)
        if(unit:IsInitialized()) then
            XF:Info('Audit', '%s,%s,%s,%d', unit:GetName(), unit:GetNote(), unit:GetRank(), unit:GetLastLogin())
        end
    end
end
--#endregion

--#region Accessors
function XFC.Guild:GetInitials()
    return self.initials
end

function XFC.Guild:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end

function XFC.Guild:HasStreamID()
    return self.streamID ~= nil
end

function XFC.Guild:GetStreamID()
    return self.streamID
end

function XFC.Guild:SetStreamID(inStreamID)
    assert(type(inStreamID) == 'number')
    self.streamID = inStreamID
end

function XFC.Guild:HasRealm()
    return self.realm ~= nil
end

function XFC.Guild:GetRealm()
    return self.realm
end

function XFC.Guild:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end
--#endregion

--#region Serialize
function XFC.Guild:Deserialize(inString)
	assert(type(inString) == 'string')

	local realmNumber, factionID, guildName, guildInitials = inString:match('XFg:(.-):(.-):(.-):(.+)')
	local realm = XFO.Realms:GetByID(tonumber(realmNumber))
	
	self:Initialize()
	self:SetKey(guildInitials)
	self:SetName(guildName)
	self:SetRealm(realm)
	self:SetInitials(guildInitials)
    XF:Info(ObjectName, 'Initialized guild [%s:%s:%s]', self:GetInitials(), self:GetName(), self:GetRealm():GetName())
end
--#endregion