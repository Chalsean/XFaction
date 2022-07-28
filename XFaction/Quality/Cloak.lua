local XFG, G = unpack(select(2, ...))
local ObjectName = 'Cloak'
local LogCategory = 'QCloak'

Cloak = {}

function Cloak:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Instance = false
    
    return Object
end

function Cloak:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then        
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Cloak:Initialize()
	if(not self:IsInitialized()) then
        XFG:CreateEvent('Cloak', 'ZONE_CHANGED_NEW_AREA', XFG.Quality.Cloak.CallbackZoneChanged, false, false)
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Cloak:CallbackZoneChanged()
    try(function ()
        if(XFG.Config.Quality.Cloak) then
            local _ZoneName = GetRealZoneText()
            local _SubZone = GetSubZoneText()
            if((_ZoneName == 'Stormwind City' and _SubZone == "Wizard's Sanctum") or
               (_ZoneName == 'Orgrimmar' and _SubZone == "Pathfinder's Den")) then
                local _ItemID = GetInventoryItemID('player', 15)
                if(XFG.Settings.Quality.Cloak[_ItemID]) then
                    local _SpecIndex = GetSpecialization()
                    local _EquipmentSetID = C_EquipmentSet.GetEquipmentSetForSpec(_SpecIndex)
                    if(_EquipmentSetID) then
                        local _ItemIDs = C_EquipmentSet.GetItemIDs(_EquipmentSetID)
                        EquipItemByName(_ItemIDs[15])
                    end
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Debug(LogCategory, 'Failed to auto-equip cloak: ' .. inErrorMessage)
    end)
end