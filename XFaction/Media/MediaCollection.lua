local XFG, G = unpack(select(2, ...))
local ObjectName = 'MediaCollection'
local LogCategory = 'MCMedia'
local MediaPath = 'Interface/Addons/XFaction/Media/'

MediaCollection = {}

function MediaCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Media = {}
	self._MediaCount = 0
	self._Initialized = false
    
    return Object
end

function MediaCollection:Initialize()
	if(not self._Initialized) then
		if(not XFG.WoW:IsRetail()) then
			for _, _Spec in XFG.Specs:Iterator() do
				self:AddMedia(tostring(_Spec:GetIconID()), 'Icon')
			end			
		end
		self._Initialized = true
	end
	return self._Initialized
end

function MediaCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _MediaCount (' .. type(self._MediaCount) .. '): ' .. tostring(self._MediaCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Media in self:Iterator() do
		_Media:Print()
	end
end

function MediaCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Media[inKey] ~= nil
end

function MediaCollection:GetMedia(inKey)
	assert(type(inKey) == 'string')
	return self._Media[inKey]
end

function MediaCollection:AddMedia(inName, inType)
    assert(type(inName) == 'string')
	assert(type(inType) == 'string')

	local _NewMedia = Media:new()
	_NewMedia:SetKey(inName)
	_NewMedia:SetName(inName)
	_NewMedia:SetType(inType)
	_NewMedia:SetPath(MediaPath .. inType .. '/' .. inName .. '.blp')

	if(not self:Contains(_NewMedia:GetKey())) then
		self._MediaCount = self._MediaCount + 1
	end
	self._Media[_NewMedia:GetKey()] = _NewMedia
	return self:Contains(_NewMedia:GetKey())
end

function MediaCollection:Iterator()
	return next, self._Media, nil
end