local XFG, G = unpack(select(2, ...))
local ObjectName = 'MediaCollection'
local MediaPath = 'Interface/Addons/XFaction/Media/'

MediaCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function MediaCollection:new()
    local object = MediaCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Hash
function MediaCollection:Add(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')
	local media = Media:new()
	media:Initialize()
	media:SetKey(inName)
	media:SetName(inName)
	media:SetType(inType)
	media:SetPath(MediaPath .. inType .. '/' .. inName .. '.blp')
	self.parent.Add(self, media)
end
--#endregion