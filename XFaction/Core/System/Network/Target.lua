local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Target'

XFC.Target = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Target:new()
    local object = XFC.Target.parent.new(self)
    object.__name = ObjectName
    object.guild = nil
    return object
end
--#endregion

--#region Properties
function XFC.Target:Guild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild' or inGuild == nil)
    if(inGuild ~= nil) then
        self.guild = inGuild
    end
    return self.guild
end
--#endregion

--#region Methods
function XFC.Target:Print()
    self:ParentPrint()
    if(self:HasGuild()) then self:Guild():Print() end
end

function XFC.Target:HasGuild()
    return self.guild ~= nil
end

function XFC.Target:IsMyTarget()
    return XF.Player.Target:Equals(self)
end

function XFC.Target:LinkCount()
    local count = 0
    for _, friend in XFO.Friends:Iterator() do
        if(friend:IsLinked() and friend:HasUnit() and self:Equals(friend:Unit():Target())) then
            count = count + 1
        end
    end
    return count
end
--#endregion