local XFG, G = unpack(select(2, ...))
local ObjectName = 'XFactionFrame'
local LogCategory = 'FXFaction'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

XFactionFrame = {}

function XFactionFrame:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Initialized = false
        self._Frame = nil
    end

    return Object
end

function XFactionFrame:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())

        -- Force the creation of the guild frame so we can hook it
        if not CommunitiesFrame or not CommunitiesFrame:IsShown() then 
			ToggleGuildFrame()	
			CommunitiesFrame:HookScript('OnHide', function (self) print('got here') end )
			CommunitiesFrame:Hide()

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

			--ToggleCommunitiesFrame();
	--local communitiesFrame = CommunitiesFrame;
			--CommunitiesFrame:Enable()
			Communities_LoadUI()
			CommunitiesFrame:HookScript('OnShow', function (self) print('got here') end )
			--ToggleGuildFrame()
			--CommunitiesFrame:Hide()
			-- CommunitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER)
			-- local _Frame = CreateFrame('Frame', 'XFaction', CommunitiesFrame)
			-- _Frame:SetPoint('CENTER')
			-- _Frame:SetSize(64,64)
			-- _Frame.tex = _Frame:CreateTexture()
			-- _Frame.tex:SetAllPoints(_Frame)
			-- _Frame.tex:SetTexture("interface/icons/inv_mushroom_11")
			local _GuildID = C_Club.GetGuildClubId()
			local _Streams = C_Club.GetStreams(2007621)
			local _Numbers = C_Club.GetClubMembers(2007621, 1)

			local _BNetID = C_AccountInfo.GetIDFromBattleNetAccountGUID('BNetAccount-0-000000000063')
			local _info = C_BattleNet.GetAccountInfoByID(_BNetID, 'BNetAccount-0-000000000063')
			XFG:DataDumper(LogCategory, _info)

			XFG:Debug(LogCategory, _GuildID)
			XFG:DataDumper(LogCategory, _Streams)
			XFG:DataDumper(LogCategory, _Numbers)
			for _, _ID in ipairs (_Numbers) do
				local _Data =  C_Club.GetMemberInfo(2007621, _ID)
				XFG:DataDumper(LogCategory, _Data)
			end
		else

function XFactionFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function XFactionFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function XFactionFrame:GetKey()
    return self._Key
end

function XFactionFrame:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function XFactionFrame:Display(inMessage)
    if(XFG.Config.Chat.Login.Enable == false) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")

    local _UnitName = nil
    local _MainName = nil
    local _Guild = nil

    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _UnitData = inMessage:GetData()
        _UnitName = _UnitData:GetName()
        if(_UnitData:HasMainName()) then
            _MainName = _UnitData:GetMainName()
        end
        _Guild = _UnitData:GetGuild()
    else
        _UnitName = inMessage:GetUnitName()
        _MainName = inMessage:GetMainName()
        _Guild = inMessage:GetGuild()
    end

    local _Faction = _Guild:GetFaction()
                    
    local _Message = format('%s ', format(XFG.Icons.String, _Faction:GetIconID())) .. _UnitName
    if(_MainName ~= nil) then
        _Message = _Message .. ' (' .. _MainName .. ')'
    end

    _Message = _Message .. ' <' .. _Guild:GetInitials() .. '> '
    
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGOUT']
    elseif(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGIN']
        if(XFG.Config.Chat.Login.Sound) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(_Message) 
end