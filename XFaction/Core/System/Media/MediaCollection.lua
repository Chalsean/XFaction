local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MediaCollection'
local MediaPath = 'Interface/Addons/XFaction/Core/System/Media/'

XFC.MediaCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.MediaCollection:new()
    local object = XFC.MediaCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.MediaCollection:Add(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')
	local media = XFC.Media:new()
	media:Initialize()
	media:Key(inName)
	media:Name(inName)
	media:Type(inType)
	media:Path(MediaPath .. inType .. '/' .. inName)
	self.parent.Add(self, media)
end
--#endregion