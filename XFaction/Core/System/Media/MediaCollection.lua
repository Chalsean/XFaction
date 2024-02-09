local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'MediaCollection'
local MediaPath = 'Interface/Addons/XFaction/Core/System/Media/'

XFC.MediaCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.MediaCollection:new()
    local object = XFC.MediaCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Hash
function XFC.MediaCollection:Add(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')
	local media = XFC.Media:new()
	media:Initialize()
	media:SetKey(inName)
	media:SetName(inName)
	media:SetType(inType)
	media:SetPath(MediaPath .. inType .. '/' .. inName .. '.blp')
	self.parent.Add(self, media)
end
--#endregion