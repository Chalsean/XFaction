local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'RaiderIOCollection'

local RaiderIO = nil

XFC.RaiderIOCollection = Factory:newChildConstructor()

--#region Constructors
function XFC.RaiderIOCollection:new()
    local object = XFC.RaiderIOCollection.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.RaiderIOCollection:NewObject()
    return XFC.RaiderIO:new()
end
--#endregion

--#region Initializers
function XFC.RaiderIOCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        RaiderIO = _G.RaiderIO
        self:IsInitialized(true)        
    end
    return self:IsInitialized()
end
--#endregion

--#region Hash
function XFC.RaiderIOCollection:Get(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    if(self:IsInitialized()) then
        if(not self:Contains(inUnit:GetKey())) then
            self:AddUnit(inUnit)
        end
        return self.parent.Get(self, inUnit:GetKey())
    end
end

function XFC.RaiderIOCollection:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object') 
    try(function ()
        local raiderIO = self:Pop()
        raiderIO:Initialize()
        raiderIO:SetKey(inUnit:GetKey())
        raiderIO:SetName(inUnit:GetUnitName())

        local profile = RaiderIO.GetProfile(inUnit:GetMainName(), inUnit:GetGuild():GetRealm():GetName())
        if(profile == nil) then
            profile = RaiderIO.GetProfile(inUnit:GetName(), inUnit:GetGuild():GetRealm():GetName())
        end
        
        -- Raid
        if(profile and profile.raidProfile) then
            local topProgress = profile.raidProfile.sortedProgress[1]
            if(topProgress and topProgress.isProgress) then
                raiderIO:SetRaid(topProgress.progress.progressCount, topProgress.progress.raid.bossCount, topProgress.progress.difficulty)
            end
        end
        -- M+
        if(profile and profile.mythicKeystoneProfile) then
            if(profile.mythicKeystoneProfile.mainCurrentScore and profile.mythicKeystoneProfile.mainCurrentScore > 0) then
                raiderIO:SetDungeon(profile.mythicKeystoneProfile.mainCurrentScore)
            elseif(profile.mythicKeystoneProfile.currentScore and profile.mythicKeystoneProfile.currentScore > 0) then
                raiderIO:SetDungeon(profile.mythicKeystoneProfile.currentScore)
            end
        end

        self:Add(raiderIO)
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function XFC.RaiderIOCollection:Remove(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name ~= nil and inRaiderIO.__name == 'RaiderIO', 'argument must be RaiderIO object')
    if(self:Contains(inRaiderIO:GetKey())) then
        self.parent.Remove(self, inRaiderIO:GetKey())
        self:Push(inRaiderIO)
    end
end
--#endregion