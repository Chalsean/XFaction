local XFG, G = unpack(select(2, ...))

ExpansionCollection = ObjectCollection:newChildConstructor()

function ExpansionCollection:new()
    local _Object = ExpansionCollection.parent.new(self)
	_Object.__name = 'ExpansionCollection'
    _Object._CurrentExpansion = nil
    return _Object
end

function ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for _ExpansionID, _IconID in pairs(XFG.Settings.Expansions) do
            local _NewExpansion = Expansion:new()
            _NewExpansion:SetKey(_ExpansionID)
            _NewExpansion:SetID(_ExpansionID)
            _NewExpansion:SetIconID(_IconID)
            if(_ExpansionID == WOW_PROJECT_MAINLINE) then
                _NewExpansion:SetName('Retail')
            elseif(_ExpansionID == WOW_PROJECT_CLASSIC) then
                _NewExpansion:SetName('Classic')
            end
            XFG:Info(self:GetObjectName(), 'Initializing expansion [%s:%s]', _NewExpansion:GetName(), _NewExpansion:GetKey())
            self:AddObject(_NewExpansion)

            if(WOW_PROJECT_ID == _ExpansionID) then
                self:SetCurrent(_NewExpansion)
                local _WoWVersion = GetBuildInfo()
                local _Version = Version:new()
                _Version:SetKey(_WoWVersion)
                _NewExpansion:SetVersion(_Version)
            end
        end       

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name ~= nil and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self._CurrentExpansion = inExpansion
	return self:GetCurrent()
end

function ExpansionCollection:GetCurrent()
	return self._CurrentExpansion
end