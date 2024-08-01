local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TagCollection'

local MaxTagCount = 100

-- Blizzards "addon too chatty" algorithm is based on message tags
-- Therefore by randomizing the tags, it linearly grows the messaging ceiling
XFC.TagCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TagCollection:new()
	local object = XFC.TagCollection.parent.new(self)
	object.__name = ObjectName
	object.prefix = nil
    return object
end

function XFC.TagCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		self:Prefix('XF' .. XFO.Confederate:Key())
		
		for i = 1, MaxTagCount do
			local tag = XFC.Tag:new(); tag:Initialize()
			tag:Key(i)
			tag:Name(self:Prefix() .. tostring(i))
			self:Add(tag)
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
function XFC.TagCollection:GetRandomTag()
	local randomNumber = math.random(1, MaxTagCount)
	return self:Get(randomNumber):Name()
end
--#endregion