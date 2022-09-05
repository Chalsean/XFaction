local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaidIOCollection'

local RaiderIO = nil

RaidIOCollection = Factory:newChildConstructor()

function RaidIOCollection:new()
    local object = RaidIOCollection.parent.new(self)
    object.__name = ObjectName
    object.isLoaded = false
    return object
end

function RaidIOCollection:NewObject()
    return RaidIO:new()
end

function RaidIOCollection:IsLoaded(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
        if(self.isLoaded) then
            RaiderIO = _G.RaiderIO
        end
    end    
    return self.isLoaded
end

function RaidIOCollection:Get(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    if(not self:Contains(inUnit:GetKey())) then
        self:Cache(inUnit)
    end
    return self.parent.Get(self, inUnit:GetKey())
end

function RaidIOCollection:Push(inRaidIO)
    assert(type(inRaidIO) == 'table' and inRaidIO.__name == 'RaidIO', 'argument must be RaidIO object')
    if(self:Contains(inRaidIO:GetKey())) then
        self:Remove(inRaidIO:GetKey())
        self.parent.Push(self, inRaidIO)
    end
end

function RaidIOCollection:Cache(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object') 
    try(function ()
        if(self:IsLoaded()) then
            local raidIO = self:Pop()
            raidIO:Initialize()
            raidIO:SetKey(inUnit:GetKey())

            local profile = RaiderIO.GetProfile(inUnit:GetKey(), inUnit:GetRealm():GetName())
            -- Raid
            if(profile and profile.raidProfile) then
                local topProgress = profile.raidProfile.sortedProgress[1]
                if(topProgress.isProgressPrev == nil or not topProgress.IsProgressPrev) then
                    raidIO:SetRaid(topProgress.progress.progressCount, topProgress.progress.raid.bossCount, topProgress.progress.difficulty)
                end
            end
            -- M+
            if(profile and profile.mythicKeystoneProfile) then
                if(profile.mythicKeystoneProfile.mainCurrentScore and profile.mythicKeystoneProfile.mainCurrentScore > 0) then
                    raidIO:SetDungeon(profile.mythicKeystoneProfile.mainCurrentScore)
                elseif(profile.mythicKeystoneProfile.currentScore and profile.mythicKeystoneProfile.currentScore > 0) then
                    raidIO:SetDungeon(profile.mythicKeystoneProfile.currentScore)
                end
            end

            self:Add(raidIO)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end