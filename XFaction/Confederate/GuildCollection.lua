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
	return self:IsInitialized()
end

function GuildCollection:ContainsGuildName(inGuildName)
	return self._Names[inGuildName] ~= nil
end

function GuildCollection:GetGuildByRealmGuildName(inRealm, inGuildName)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be a Realm object')	
	assert(type(inGuildName) == 'string')
	for _, _Guild in self:Iterator() do
		if(inRealm:Equals(_Guild:GetRealm()) and _Guild:GetName() == inGuildName) then
			return _Guild
		end
	end
end

function GuildCollection:GetGuildByName(inGuildName)
	return self._Names[inGuildName]
end

function GuildCollection:AddObject(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
	if(not self:Contains(inGuild:GetKey())) then
		self._ObjectCount = self._ObjectCount + 1
	end
	self._Objects[inGuild:GetKey()] = inGuild
	self._Names[inGuild:GetName()] = inGuild
	return self:Contains(inGuild:GetKey())
end