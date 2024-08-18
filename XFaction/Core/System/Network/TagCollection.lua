local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TagCollection'

local MaxTagCount = 25

-- Blizzards "addon too chatty" algorithm is based on message tags
-- Therefore by randomizing the tags, it linearly grows the messaging ceiling
XFC.TagCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TagCollection:new()
	local object = XFC.TagCollection.parent.new(self)
	object.__name = ObjectName
	object.prefix = nil
	object.tagNames = nil
    return object
end

function XFC.TagCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		self.tagNames = {}
		self:Prefix('XF' .. XFO.Confederate:Key())
		
		for i = 1, MaxTagCount do
			local tag = XFC.Tag:new(); tag:Initialize()			
			tag:Key(i)
			tag:ID(i)
			tag:Name(self:Prefix() .. tostring(i))
			XFF.ChatRegister(tag:Name())
			self:Add(tag)
			self.tagNames[tag:Name()] = i
		end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.TagCollection:Prefix(inPrefix)
	assert(type(inPrefix) == 'string' or inPrefix == nil)
	if(inPrefix ~= nil) then
		self.prefix = inPrefix
	end
	return self.prefix
end
--#endregion

--#region Methods
function XFC.TagCollection:Contains(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string')
	if(type(inKey) == 'string') then
		return self.tagNames[inKey]
	end
	return self.parent.Contains(self, inKey)
end

function XFC.TagCollection:GetRandomTag()
	local randomNumber = math.random(1, MaxTagCount)
	return self:Get(randomNumber):Name()
end
--#endregion