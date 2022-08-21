local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaidIOCollection'

local RaiderIO = nil

RaidIOCollection = Factory:newChildConstructor()

function RaidIOCollection:new()
    local _Object = RaidIOCollection.parent.new(self)
    _Object.__name = ObjectName
    _Object._Loaded = false
    return _Object
end

function RaidIOCollection:NewObject()
    return RaidIO:new()
end

function RaidIOCollection:IsLoaded(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._Loaded = inBoolean
        if(self._Loaded) then
            RaiderIO = _G.RaiderIO
        end
    end    
    return self._Loaded
end

function RaidIOCollection:Get(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object')
    if(not self:Contains(inUnit:GetKey())) then
        self:Cache(inUnit)
    end
    return self.parent.Get(self, inUnit:GetKey())
end

function RaidIOCollection:Push(inRaidIO)
    assert(type(inRaidIO) == 'table' and inRaidIO.__name ~= nil and inRaidIO.__name == 'RaidIO', 'argument must be RaidIO object')
    if(self:Contains(inRaidIO:GetKey())) then
        self:Remove(inRaidIO:GetKey())
        self.parent.Push(self, inRaidIO)
    end
end

function RaidIOCollection:Cache(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object') 
    try(function ()
        if(self:IsLoaded()) then
            local _RaidIO = self:Pop()
            _RaidIO:Initialize()
            _RaidIO:SetKey(inUnit:GetKey())

            local _Profile = RaiderIO.GetProfile(inUnit:GetKey(), inUnit:GetRealm():GetName())
            -- Raid
            if(_Profile and _Profile.raidProfile) then
                local _TopProgress = _Profile.raidProfile.sortedProgress[1]
                if(_TopProgress.isProgressPrev == nil or _TopProgress.IsProgressPrev == false) then
                    _RaidIO:SetRaid(_TopProgress.progress.progressCount, _TopProgress.progress.raid.bossCount, _TopProgress.progress.difficulty)
                end
            end
            -- M+
            if(_Profile and _Profile.mythicKeystoneProfile) then
                if(_Profile.mythicKeystoneProfile.mainCurrentScore and _Profile.mythicKeystoneProfile.mainCurrentScore > 0) then
                    _RaidIO:SetDungeon(_Profile.mythicKeystoneProfile.mainCurrentScore)
                elseif(_Profile.mythicKeystoneProfile.currentScore and _Profile.mythicKeystoneProfile.currentScore > 0) then
                    _RaidIO:SetDungeon(_Profile.mythicKeystoneProfile.currentScore)
                end
            end

            self:Add(_RaidIO)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end