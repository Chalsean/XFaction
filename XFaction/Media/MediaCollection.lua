local XFG, G = unpack(select(2, ...))
local ObjectName = 'MediaCollection'
local MediaPath = 'Interface/Addons/XFaction/Media/'

MediaCollection = ObjectCollection:newChildConstructor()

function MediaCollection:new()
    local _Object = MediaCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function MediaCollection:Add(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')

	local _NewMedia = Media:new()
	_NewMedia:Initialize()
	_NewMedia:SetKey(inName)
	_NewMedia:SetName(inName)
	_NewMedia:SetType(inType)
	_NewMedia:SetPath(MediaPath .. inType .. '/' .. inName .. '.blp')
	self.parent.Add(self, _NewMedia)
end