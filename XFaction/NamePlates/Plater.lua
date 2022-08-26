local XFG, G = unpack(select(2, ...))
local ObjectName = 'PlaterNameplate'

PlaterNameplate = Object:newChildConstructor()

function PlaterNameplate:new()
    local _Object = PlaterNameplate.parent.new(self)
    self.__name = ObjectName    
    return _Object
end

function PlaterNameplate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        --if(XFG.Config.Nameplates.ElvUI.Enable) then
            XFG:RegisterEvent('NAME_PLATE_UNIT_ADDED', XFG.Nameplates.Plater.CallbackUnitAdded)
            
        --end
        
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function PlaterNameplate:CallbackUnitAdded(inUnit)
    local _GUID = UnitGUID(inUnit)
    if(C_PlayerInfo.GUIDIsPlayer(_GUID)) then
        if(XFG.Confederate:Contains(_GUID)) then
            local _Unit = XFG.Confederate:Get(_GUID)
            if(_Unit:HasMainName()) then
                local namePlate = C_NamePlate.GetNamePlateForUnit (inUnit)
                namePlate.unitFrame.unitName = namePlate.unitFrame.unitName .. ' (' .. _Unit:GetMainName() .. ')'
            end
        end

        
        XFG:DataDumper(ObjectName, namePlate.unitFrame.unitName)
        XFG:DataDumper(ObjectName, namePlate.unitFrame.playerGuildName)
        XFG:DataDumper(ObjectName, _GUID)
    end
end