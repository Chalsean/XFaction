local XFG, G = unpack(select(2, ...))
local ObjectName = 'NameplateEvent'
local LogCategory = 'HENameplate'

NameplateEvent = {}

function NameplateEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end

function NameplateEvent:Initialize()
	if(not self:IsInitialized()) then
--        XFG:RegisterEvent('NAME_PLATE_UNIT_ADDED', XFG.Handlers.NameplateEvent.CallbackNameplateAdd)

        -- if(IsAddOnLoaded('ElvUI')) then
        --     ElvUI[1]:AddTag('guild:brackets', 'PLAYER_GUILD_UPDATE', function(inNameplate)
        --         local _GUID = UnitGUID(inNameplate)
        --         local _GuildName = GetGuildInfo(inNameplate)
        --         if(XFG.Config.Nameplates.Confederate.Enable and XFG.Confederate:Contains(_GUID)) then
        --             _GuildName = XFG.Confederate:GetName()
        --         end
        --         if(_GuildName) then
        --             return format('<%s>', _GuildName)
        --         end
        --     end)
        -- end

        -- hooksecurefunc("CompactUnitFrame_UpdateName", function (frame)
        --         frame.name:SetText('bob')
        --     end)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function NameplateEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function NameplateEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function NameplateEvent:ElvUI(tagName, eventsOrSeconds, func, block)
    XFG:Error(LogCategory, 'elvui raw hook fire')
    if(tagName == 'guild:brackets') then

    else
        XFG.hooks['AddTag'](tagName, eventsOrSeconds, func, block)
    end

    --XFG:Error(LogCategory, 'Setting ElvUI nameplate to bob')
    --frame.name = 'bob'
end



function NameplateEvent:CallbackNameplateAdd(inNameplate)
    XFG:Error(LogCategory, 'NAME_PLATE_UNIT_ADDED event fired: ' .. tostring(inNameplate))
    for _, _Frame in pairs(C_NamePlate.GetNamePlates()) do
 		if(_Frame and _Frame.unitFrame) then
 			local _Nameplate = _Frame.unitFrame
--             local _GUID = UnitGUID(_Nameplate.unit)
            --  XFG:DataDumper(LogCategory, _Nameplate.unitName)
            --  local currentText = _Nameplate.unitName:GetText()
		    -- if (not currentText:find ("<")) then
			--     _Nameplate.unitName:SetText (currentText .. "\n" .. "<Bob>")
		    -- end
--             if(string.find(_GUID, 'Player')) then
--                 _Nameplate.name = 'Bob'
--                 XFG:DataDumper(LogCategory, _Nameplate.name)
-- --                XFG:UnregisterEvent('NAME_PLATE_UNIT_ADDED')
-- --                break
--             end

			-- --Reset couunter
			-- plate.SLE_targetcount:SetText('')
			-- plate.SLE_TargetedByCounter = 0

			-- --If in group, then update counter
			-- if isGrouped then
			-- 	for _, unitid in pairs(N.GroupMembers) do --For every unit in roster
			-- 		if not UnitIsUnit(unitid, 'player') and plate.unit then
			-- 			target = format('%starget', unitid) --Get group member's target
			-- 			plate.guid = UnitGUID(plate.unit) --Find unit's guid

			-- 			if plate.guid and UnitExists(target) then --If target exists and plate actually has unit, then someone actually targets this plate
			-- 				if UnitGUID(target) == plate.guid then
			-- 					plate.SLE_TargetedByCounter = plate.SLE_TargetedByCounter + 1
			-- 				end
			-- 			end
			-- 		end
			-- 	end
			-- end

			-- --If debug mode is set
			-- if N.TestSoloTarget then
			-- 	plate.guid = UnitGUID(plate.unit)

			-- 	if plate.guid and UnitExists('target') then
			-- 		if UnitGUID('target') == plate.guid then
			-- 			plate.SLE_TargetedByCounter = plate.SLE_TargetedByCounter + 1
			-- 		end
			-- 	end
			-- end
			-- if not (plate.SLE_TargetedByCounter == 0) then
			-- 	plate.SLE_targetcount:SetText(format('[%d]', plate.SLE_TargetedByCounter))
			-- end
		end
	end
end