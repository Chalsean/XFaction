local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaiderIOCollection'

local RaiderIO = nil

RaiderIOCollection = Factory:newChildConstructor()

--#region Constructors
function RaiderIOCollection:new()
    local object = RaiderIOCollection.parent.new(self)
    object.__name = ObjectName
    return object
end

function RaiderIOCollection:NewObject()
    return XFRaiderIO:new()
end
--#endregion

--#region Initializers
function RaiderIOCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        RaiderIO = _G.RaiderIO
        self:IsInitialized(true)        
    end
    return self:IsInitialized()
end
--#endregion

--#region Hash
function RaiderIOCollection:Get(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    if(not self:Contains(inUnit:GetKey())) then
        self:Cache(inUnit)
    end
    return self.parent.Get(self, inUnit:GetKey())
end

function RaiderIOCollection:Cache(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object') 
    try(function ()
        if(self:IsInitialized()) then
            local raiderIO = self:Pop()
            raiderIO:Initialize()
            raiderIO:SetKey(inUnit:GetKey())
            raiderIO:SetName(inUnit:GetUnitName())

            local profile = RaiderIO.GetProfile(inUnit:GetMainName(), inUnit:GetRealm():GetName())
            if(profile == nil) then
                profile = RaiderIO.GetProfile(inUnit:GetName(), inUnit:GetRealm():GetName())
            end
            
            -- Raid
            if(profile and profile.raidProfile) then
                local topProgress = profile.raidProfile.sortedProgress[1]
                if(topProgress.isProgress) then
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
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function RaiderIOCollection:Remove(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name ~= nil and inRaiderIO.__name == 'RaiderIO', 'argument must be RaiderIO object')
    if(self:Contains(inRaiderIO:GetKey())) then
        self.parent.Remove(self, inRaiderIO:GetKey())
        self:Push(inRaiderIO)
    end
end
--#endregion