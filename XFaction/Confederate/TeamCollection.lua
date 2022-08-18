local XFG, G = unpack(select(2, ...))

TeamCollection = ObjectCollection:newChildConstructor()

function TeamCollection:new()
	local _Object = TeamCollection.parent.new(self)
	_Object.__name = 'TeamCollection'
    return _Object
end

function TeamCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _Initials, _Name in pairs (XFG.Settings.Teams) do
			local _NewTeam = Team:new()
			_NewTeam:Initialize()
			_NewTeam:SetName(_Name)
			_NewTeam:SetInitials(_Initials)
			_NewTeam:SetKey(_Initials)
			self:AddObject(_NewTeam)
		end
		self:IsInitialized(true)
	end
end