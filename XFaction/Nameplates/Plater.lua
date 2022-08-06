local XFG, G = unpack(select(2, ...))
local ObjectName = 'PlaterNameplate'
local LogCategory = 'NPPlater'

PlaterNameplate = Nameplate:newChildConstructor()

function PlaterNameplate:new()
    local _Object = PlaterNameplate.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function PlaterNameplate:Initialize()
	if(not self:IsInitialized()) then
        XFG:RawHook(Plater, 'AddGuildNameToPlayerName', XFG.Nameplates.Plater.AddGuildNameToPlayerName, true)
        XFG:RawHook(Plater, 'UpdateUnitName', XFG.Nameplates.Plater.UpdateUnitName, true)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function PlaterNameplate:AddGuildNameToPlayerName(inPlateFrame)
    local _Plates = {}
    if(inPlateFrame) then
        table.insert(_Plates, inPlateFrame)
    else
        _Plates = Plater.GetAllShownPlates()
    end    
    for _, _PlateFrame in ipairs (Plater.GetAllShownPlates()) do
        local currentText = _PlateFrame.CurrentUnitNameString:GetText()
        if (not currentText:find ("<")) then
            local _GuildName = _PlateFrame.playerGuildName
            if(XFG.Config.Nameplates.Plater.Confederate) then
                -- Unfortunately Plater does not track GUIDs and strips the realm name, so we have to assume
                local _UnitData = XFG.Confederate:GetUnitByName(_PlateFrame['namePlateUnitName'])
                if(_UnitData) then
                    _GuildName = XFG.Confederate:GetName()
                    if(XFG.Config.Nameplates.Plater.Team) then
                        _GuildName = _GuildName .. ':' .. _UnitData:GetTeam():GetName()
                    end
                end
            end
            if(_GuildName) then
                _PlateFrame.CurrentUnitNameString:SetText (currentText .. "\n" .. "<" .. _GuildName .. ">")
            end
        end
    end
end

function PlaterNameplate:UpdateUnitName()
    for _, _PlateFrame in ipairs (Plater.GetAllShownPlates()) do
        local nameString = _PlateFrame.CurrentUnitNameString
        if(XFG.Config.Nameplates.Plater.Main) then
            -- Unfortunately Plater does not track GUIDs and strips the realm name, so we have to assume
            local _UnitData = XFG.Confederate:GetUnitByName(_PlateFrame['namePlateUnitName'])
            if(_UnitData) then
                if(_UnitData:HasMainName()) then
                    nameString = nameString .. ' (' .. _UnitData:GetMainName() .. ')'
                end
            end
        end

		if ( not (_PlateFrame.IsFriendlyPlayerWithoutHealthBar or _PlateFrame.IsNpcWithoutHealthBar) and _PlateFrame.NameAnchor >= 9) then
			--remove some character from the unit name if the name is placed inside the nameplate
			Plater.UpdateUnitNameTextSize (_PlateFrame, nameString)
		else
			nameString:SetText (_PlateFrame ['namePlateUnitName'] or _PlateFrame.unitFrame ['namePlateUnitName'] or "")
		end
		
		--check if the player has a guild, this check is done when the nameplate is added
		if (_PlateFrame.playerGuildName) then
			if (_PlateFrame.PlateConfig.show_guild_name) then
				XFG.Nameplates.Plater.AddGuildNameToPlayerName(_PlateFrame)
			end
		end
    end
end