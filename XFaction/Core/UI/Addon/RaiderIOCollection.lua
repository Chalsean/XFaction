local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RaiderIOCollection'

XFC.RaiderIOCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.RaiderIOCollection:new()
    local object = XFC.RaiderIOCollection.parent.new(self)
    object.__name = ObjectName
    object.api = nil
    return object
end

function XFC.RaiderIOCollection:NewObject()
    return XFC.RaiderIO:new()
end

function XFC.RaiderIOCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:API(_G.RaiderIO)
        self:IsInitialized(true)        
    end
    return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.RaiderIOCollection:API(inAPI)
    assert(type(inAPI) == 'table' or inAPI == nil)
    if(inAPI ~= nil) then
        self.api = inAPI
    end
    return self.api
end
--#endregion

--#region Methods
function XFC.RaiderIOCollection:Get(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(self:IsInitialized()) then
        if(not self:Contains(inUnit:Key())) then
            self:AddUnit(inUnit)
        end
        return self.parent.Get(self, inUnit:Key())
    end
end

function XFC.RaiderIOCollection:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit') 
    try(function ()
        local raiderIO = self:Pop()
        raiderIO:Initialize()
        raiderIO:Key(inUnit:Key())
        raiderIO:Name(inUnit:UnitName())

        local profile = inUnit:IsAlt() and self:API().GetProfile(inUnit:MainName(), inUnit:Guild():Realm():Name()) or self:API().GetProfile(inUnit:Name(), inUnit:Guild():Realm():Name())
        
        -- Raid
        if(profile and profile.raidProfile) then
            local topProgress = profile.raidProfile.sortedProgress[1]
            if(topProgress and topProgress.isProgress) then
                raiderIO:Raid(topProgress.progress.progressCount, topProgress.progress.raid.bossCount, topProgress.progress.difficulty)
            end
        end
        -- M+
        if(profile and profile.mythicKeystoneProfile) then
            if(profile.mythicKeystoneProfile.mainCurrentScore and profile.mythicKeystoneProfile.mainCurrentScore > 0) then
                raiderIO:DungeonScore(profile.mythicKeystoneProfile.mainCurrentScore)
            elseif(profile.mythicKeystoneProfile.currentScore and profile.mythicKeystoneProfile.currentScore > 0) then
                raiderIO:DungeonScore(profile.mythicKeystoneProfile.currentScore)
            end
        end

        self:Add(raiderIO)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.RaiderIOCollection:Remove(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name == 'RaiderIO')
    if(self:Contains(inRaiderIO:Key())) then
        self.parent.Remove(self, inRaiderIO:Key())
        self:Push(inRaiderIO)
    end
end
--#endregion