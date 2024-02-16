local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Message'
local GetCurrentTime = GetServerTime

Message = Object:newChildConstructor()

--#region Constructors
function Message:new()
    local object = Message.parent.new(self)
    object.__name = 'Message'
    object.to = nil
    object.from = nil
    object.type = nil
    object.subject = nil
    object.epochTime = nil
    object.targets = nil
    object.targetCount = 0
    object.data = nil
    object.initialized = false
    object.version = nil
    return object
end
--#endregion

--#region Initializers
function Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:SetFrom(XF.Player.Unit)
        self:SetTimeStamp(GetCurrentTime())
        self:SetAllTargets()
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Deconstructor()
    self:ParentDeconstructor()
    self.to = nil
    self.from = nil
    self.type = nil
    self.subject = nil
    self.epochTime = nil
    self.targets = nil
    self.targetCount = 0
    self.data = nil
    self:Initialize()
end
--#endregion

--#region Print
function Message:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
    XF:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(ObjectName, '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(ObjectName, '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(ObjectName, '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    if(self:HasFrom() and not self:IsFromSerialized()) then
        self:GetFrom():Print()
    end
end
--#endregion

--#region Accessors
function Message:GetTo()
    return self.to
end

function Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self.to = inTo
end

function Message:HasFrom()
    return self.from ~= nil
end

function Message:GetFrom()
    return self.from
end

function Message:SetFrom(inFrom)
    -- Depending upon moment in execution, From may be string or Unit object
    self.from = inFrom
end

function Message:IsFromSerialized()
    return type(self.from) == 'string'
end

function Message:GetType()
    return self.type
end

function Message:SetType(inType)
    assert(type(inType) == 'string')
    self.type = inType
end

function Message:GetSubject()
    return self.subject
end

function Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self.subject = inSubject
end

function Message:GetTimeStamp()
    return self.epochTime
end

function Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.epochTime = inEpochTime
end

function Message:GetData()
    return self.data
end

function Message:SetData(inData)
    self.data = inData
end

function Message:IsMyMessage()
    return self:GetFrom():Equals(XF.Player.Unit)
end
--#endregion

--#region Target
function Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.targets[inTarget:GetKey()] ~= nil
end

function Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(not self:ContainsTarget(inTarget)) then
        self.targetCount = self.targetCount + 1
    end
    self.targets[inTarget:GetKey()] = inTarget
end

function Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(self:ContainsTarget(inTarget)) then
        self.targets[inTarget:GetKey()] = nil
        self.targetCount = self.targetCount - 1
    end
end

function Message:SetAllTargets()
    for _, target in XF.Targets:Iterator() do
        if(not target:Equals(XF.Player.Target)) then
            self:AddTarget(target)
        end
    end
end

function Message:HasTargets()
    return self.targetCount > 0
end

function Message:GetTargets()
    if(self:HasTargets()) then return self.targets end
    return {}
end

function Message:GetTargetCount()
    return self.targetCount
end

function Message:GetRemainingTargets()
    local targetsString = ''
    for _, target in pairs (self:GetTargets()) do
        targetsString = targetsString .. '|' .. target:GetKey()
    end
    return targetsString
end

function Message:SetRemainingTargets(inTargetString)
    wipe(self.targets)
    self.targetCount = 0
    local targets = string.Split(inTargetString, '|')
    for _, key in pairs (targets) do
        if(key ~= nil and XF.Targets:Contains(key)) then
            local target = XF.Targets:Get(key)
            if(not XF.Player.Target:Equals(target)) then
                self:AddTarget(target)
            end
        end
    end
end
--#endregion

--#region Network
-- I'm sure there's a cooler way of doing this but this works for me :)
function Message:Serialize()
	local data = {}

	data.F = self:GetFrom():Serialize()
	data.R = self:GetRemainingTargets()
    data.S = self:GetSubject()
    data.T = self:GetTo()	
	data.Y = self:GetType()

	return pickle(data)
end

function Message:Deserialize(inData)
	local decompressed = Deflate:DecompressDeflate(inData)
	local data = unpickle(decompressed)
	
	local unit = nil
	try(function()
		unit = XFO.Confederate:Pop()
		unit:Deserialize(data.F)
		self:SetFrom(unit)
	end).
	catch(function(inErrorMessage)
		XFO.Confederate:Push(unit)
        throw(inErrorMessage)
	end)

	self:SetRemainingTargets(data.R)
    self:SetSubject(data.S)
    self:SetTo(data.T)	
	self:SetType(data.Y)
end

function Message:Compress()
    local serialized = self:Serialize()
	return compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
end
--#endregion