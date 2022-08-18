local XFG, G = unpack(select(2, ...))
local ObjectName = 'MediaCollection'
local MediaPath = 'Interface/Addons/XFaction/Media/'

MediaCollection = ObjectCollection:newChildConstructor()

function MediaCollection:new()
    local _Object = MediaCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function MediaCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(not XFG.WoW:IsRetail()) then
			for _, _Spec in XFG.Specs:Iterator() do
				self:AddMedia(tostring(_Spec:GetIconID()), 'Icon')
			end			
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function MediaCollection:AddMedia(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')

	local _NewMedia = Media:new()
	_NewMedia:Initialize()
	_NewMedia:SetKey(inName)
	_NewMedia:SetName(inName)
	_NewMedia:SetType(inType)
	_NewMedia:SetPath(MediaPath .. inType .. '/' .. inName .. '.blp')
	self:AddObject(_NewMedia)

	return self:Contains(inName)
end