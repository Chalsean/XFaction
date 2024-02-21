local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'MythicKeyCollection'
local GetKeyLevel = C_MythicPlus.GetOwnedKeystoneLevel
local GetKeyMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID

--#region Initializers
function XFC.MythicKeyCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = 'Mythic', 
            event = 'CHALLENGE_MODE_COMPLETED', 
            callback = XFO.Keys.RefreshMyKey, 
            instance = true
        })
        self:RefreshMyKey()
        self:IsInitialized(true)
    end
end
--#endregion

--#region Accessors
function XFC.MythicKeyCollection:RefreshMyKey()
    local self = XFO.Keys

    local level = GetKeyLevel()    
    local mapID = GetKeyMapID()

    if(level ~= nil and mapID ~= nil and XFO.Dungeons:Contains(mapID)) then    
        local key = nil
        if(self:HasMyKey()) then
            key = self:GetMyKey()
        else
            key = XFC.MythicKey:new()
            key:Initialize()
            key:IsMyKey(true)
        end

        key:SetID(level)
        key:SetDungeon(XFO.Dungeons:Get(mapID))
        key:SetKey(key:GetID() .. '.' .. key:GetDungeon():GetKey())

        self:Add(key)
        XF.Player.Unit:SetMythicKey(key)
    end
end
--#endregion