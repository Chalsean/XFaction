local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemFrame'

XFC.SystemFrame = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemFrame:new()
    local object = XFC.SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.SystemFrame:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFF.ChatFrameFilter('CHAT_MSG_SYSTEM', XFO.SystemFrame.CallbackChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_SYSTEM event filter')
        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
function XFC.SystemFrame:CallbackChatFilter(inEvent, inMessage, ...)
    if(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGIN']) and XF.Config.DataText.Guild.NonXFaction) then
        return true
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGOUT']) and XF.Config.DataText.Guild.NonXFaction) then
        return true
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inMessage, ...
end

function XFC.SystemFrame:DisplayLogin(inUnit)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(XFF.PlayerIsIgnored(inUnit:GUID())) then return end

    local text = XF.Settings.Frames.Chat.Prepend
    
    if(XF.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Faction():IconID()))
    end

    text = text .. inUnit:GetLink() .. ' '
  
    if(XF.Config.Chat.Login.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end

    if(XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    
    text = text .. XF.Lib.Locale['CHAT_LOGIN']
    if(XF.Config.Chat.Login.Sound and not inUnit:IsSameGuild()) then
        XFF.UISystemSound(3332, 'Master')
    end

    XFF.UISystemMessage(text)
end

function XFC.SystemFrame:DisplayLogout(inName)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inName) == 'string')
    local text = XF.Settings.Frames.Chat.Prepend
    text = text .. inName .. ' ' .. XF.Lib.Locale['CHAT_LOGOUT']
    XFF.UISystemMessage(text) 
end

function XFC.SystemFrame:DisplayOrder(inOrder)
    if(not XF.Config.Chat.Crafting.Enable) then return end
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    if(XFF.PlayerIsIgnored(inOrder:Customer():GUID())) then return end

    if(inOrder:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
    if(inOrder:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
    if(inOrder:IsPersonal() and not inOrder:IsMyOrder() and not inOrder:IsPlayerCrafter()) then return end

    local display = false
    if(not XF.Config.Chat.Crafting.Professions) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession1())) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession2())) then
        display = true
    end

    if(display) then
        local customer = inOrder:Customer()
        local text = XF.Settings.Frames.Chat.Prepend
            
        if(XF.Config.Chat.Crafting.Faction) then
            text = text .. format('%s ', format(XF.Icons.String, customer:Faction():IconID()))
        end
        
        text = text .. customer:GetLink()
            
        if(XF.Config.Chat.Crafting.Main and customer:IsAlt()) then
            text = text .. '(' .. customer:MainName() .. ') '
        end
        
        if(XF.Config.Chat.Crafting.Guild) then
            text = text .. '<' .. customer:Guild():Initials() .. '> '
        end
            
        if(inOrder:IsGuild()) then
            text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:Link())
        else
            text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:Link())
        end

        XFF.UISystemMessage(text)
    end
end
--#endregion