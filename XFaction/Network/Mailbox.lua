local XFG, G = unpack(select(2, ...))
local ObjectName = 'Mailbox'

local ServerTime = GetServerTime

Mailbox = Factory:newChildConstructor()

function Mailbox:new()
    local _Object = Mailbox.parent.new(self)
	_Object.__name = ObjectName
	return _Object
end

function Mailbox:NewObject()
	return Message:new()
end

function Mailbox:Add(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
	if(not self:Contains(inMessage:GetKey())) then
		self._Objects[inMessage:GetKey()] = ServerTime()
	end
end

function Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _Key, _ReceivedTime in self:Iterator() do
		if(_ReceivedTime < inEpochTime) then
			self:Remove(_Key)
		end
	end
end