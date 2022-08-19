local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaidIOCollection'

local RaiderIO = nil

RaidIOCollection = ObjectCollection:newChildConstructor()

function RaidIOCollection:new()
    local _Object = RaidIOCollection.parent.new(self)
    _Object.__name = ObjectName
    _Object._Loaded = false
    return _Object
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

function RaidIOCollection:ContainsUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object')
    local _RaiderName = inUnit:HasMainName() and inUnit:GetMainName() or inUnit:GetName()
    return self._Objects[_RaiderName] ~= nil
end

function RaidIOCollection:GetRaidIO(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object')
    local _RaiderName = inUnit:HasMainName() and inUnit:GetMainName() or inUnit:GetName()

    if(not self:ContainsUnit(inUnit)) then
        self:CacheUnit(inUnit)
    end

    return self._Objects[_RaiderName]
end

function RaidIOCollection:CacheUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object')
    
    try(function ()
        local _RaiderName = inUnit:HasMainName() and inUnit:GetMainName() or inUnit:GetName()
        if(self:IsLoaded()) then
            local _RaidIO = RaidIO:new(); _RaidIO:Initialize()
            _RaidIO:SetKey(_RaiderName)

            local _Profile = RaiderIO.GetProfile(_RaiderName, inUnit:GetRealm():GetName())
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

            self:AddObject(_RaidIO)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end