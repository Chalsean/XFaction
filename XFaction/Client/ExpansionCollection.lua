local XFG, G = unpack(select(2, ...))
local ObjectName = 'ExpansionCollection'

ExpansionCollection = ObjectCollection:newChildConstructor()

function ExpansionCollection:new()
    local _Object = ExpansionCollection.parent.new(self)
	_Object.__name = ObjectName
    _Object._CurrentExpansion = nil
    return _Object
end

function ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for _ExpansionID, _IconID in pairs(XFG.Settings.Expansions) do
            local _Expansion = Expansion:new()
            _Expansion:SetKey(_ExpansionID)
            _Expansion:SetID(_ExpansionID)
            _Expansion:SetIconID(_IconID)
            if(_ExpansionID == WOW_PROJECT_MAINLINE) then
                _Expansion:SetName('Retail')
            elseif(_ExpansionID == WOW_PROJECT_CLASSIC) then
                _Expansion:SetName('Classic')
            end
            XFG:Info(ObjectName, 'Initializing expansion [%s:%s]', _Expansion:GetName(), _Expansion:GetKey())
            self:Add(_Expansion)

            if(WOW_PROJECT_ID == _ExpansionID) then
                self:SetCurrent(_Expansion)
                local _WoWVersion = GetBuildInfo()
                local _Version = Version:new()
                _Version:SetKey(_WoWVersion)
                _Expansion:SetVersion(_Version)
            end
        end       

		self:IsInitialized(true)
	end
end

function ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name ~= nil and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self._CurrentExpansion = inExpansion
end

function ExpansionCollection:GetCurrent()
	return self._CurrentExpansion
end