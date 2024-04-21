local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKeyCollection'

--#region Initializers
function XFC.MythicKeyCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = 'Mythic', 
            event = 'CHALLENGE_MODE_COMPLETED', 
            callback = XFO.Keys.RefreshMyKey, 
            instance = true,
            start = true
        })
        self:RefreshMyKey()
        self:IsInitialized(true)
    end
end
--#endregion

--#region Accessors
function XFC.MythicKeyCollection:RefreshMyKey()
    local self = XFO.Keys

    local level = XFF.MythicGetKeyLevel()    
    local mapID = XFF.MythicGetKeyMapID()

    if(level ~= nil and mapID ~= nil and XFO.Dungeons:Contains(mapID)) then    
        local key = nil
        if(self:HasMyKey()) then
            key = self:MyKey()
        else
            key = XFC.MythicKey:new()
            key:Initialize()
            key:IsMyKey(true)
        end

        key:ID(level)
        key:Dungeon(XFO.Dungeons:Get(mapID))
        key:Key(key:ID() .. '.' .. key:Dungeon():Key())

        self:Add(key)
        XF.Player.Unit:MythicKey(key)
    end
end
--#endregion