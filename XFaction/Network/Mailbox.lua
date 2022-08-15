local XFG, G = unpack(select(2, ...))

Mailbox = ObjectCollection:newChildConstructor()

function Mailbox:new()
    local _Object = Mailbox.parent.new(self)
	_Object.__name = 'Mailbox'
	return _Object
end

function Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, _Message in self:Iterator() do
		if(_Message:GetTimeStamp() < inEpochTime) then
			self:RemoveObject(_Message:GetKey())
		end
	end
end