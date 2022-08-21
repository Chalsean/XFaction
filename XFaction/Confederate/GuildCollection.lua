local XFG, G = unpack(select(2, ...))

GuildCollection = ObjectCollection:newChildConstructor()

function GuildCollection:new()
    local _Object = GuildCollection.parent.new(self)
	_Object.__name = 'GuildCollection'
	_Object._Names = nil
    return _Object
end

function GuildCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self._Names = {}
		self:IsInitialized(true)
	end
end

function GuildCollection:ContainsName(inGuildName)
	return self._Names[inGuildName] ~= nil
end

function GuildCollection:GetByRealmGuildName(inRealm, inGuildName)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be a Realm object')	
	assert(type(inGuildName) == 'string')
	for _, _Guild in self:Iterator() do
		if(inRealm:Equals(_Guild:GetRealm()) and _Guild:GetName() == inGuildName) then
			return _Guild
		end
	end
end

function GuildCollection:GetByName(inGuildName)
	return self._Names[inGuildName]
end

function GuildCollection:Add(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
	self.parent.Add(self, inGuild)
	self._Names[inGuild:GetName()] = inGuild
end