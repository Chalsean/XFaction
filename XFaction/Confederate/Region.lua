local XFG, G = unpack(select(2, ...))
local ObjectName = 'Region'

Region = Object:newChildConstructor()

--#region Constructors
function Region:new()
    local object = Region.parent.new(self)
    object.__name = ObjectName
    object.current = false
    return object
end
--#endregion

--#region Accessors
function Region:IsCurrent(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.current = inBoolean
    end
    return self.current
end
--#endregion