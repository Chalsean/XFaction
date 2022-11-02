local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function LoadConfig(inValue)
    -- If data is not XFaction return
    local val = string.match(inValue, '^XF:(.-):XF$')
    if val == nil  then
        return inValue
    end
    
    -- Decompress and deserialize XFaction data
	local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(val))
    local _, _Deserialized = XFG:Deserialize(_Decompressed)
    
    return _Deserialized
end

local function GenerateConfig(inValue)
    -- If data is not XFaction return
    for _, _Line in ipairs(string.Split(inValue, '\n')) do
        if not string.find(_Line, 'XF.:') then
            return inValue
        end
    end

    -- Serialize and compress XFaction data
    local _Serialized = XFG:Serialize(inValue)
	local _Compressed = XFG.Lib.Deflate:EncodeForPrint(XFG.Lib.Deflate:CompressDeflate(_Serialized, {level = XFG.Settings.Network.CompressionLevel}))
    
    return 'XF:' .. _Compressed .. ':XF'
end

XFG.Options.args.Confederate = {
	name = XFG.Lib.Locale['CONFEDERATE'],
	order = 1,
	type = 'group',
	args = {
		Confederate = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['CONFEDERATE'],
			guiInline = true,
			args = {
                Config = {
                    type = "input",
					order = 1,
                    name = XFG.Lib.Locale['CONFEDERATE_CONFIG_BUILDER'],
                    width = "full",
                    multiline = 24,
                    get = function(info) return XFG.Config.Confederate[ info[#info] ] end,
                    set = function(info, value) XFG.Config.Confederate[ info[#info] ] = value; end
                },
                Load = {
                    type = "execute",
					order = 2,
                    name = XFG.Lib.Locale['CONFEDERATE_LOAD'],
                    width = "2",
                    func = function(info)
                        XFG.Config.Confederate.Config = LoadConfig(XFG.Config.Confederate.Config)
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Config")
                    end
                },
                Generate = {
                    type = "execute",
					order = 3,
                    name = XFG.Lib.Locale['CONFEDERATE_GENERATE'],
                    width = "2",
                    func = function(info)
                        XFG.Config.Confederate.Config = GenerateConfig(XFG.Config.Confederate.Config)
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Config")
                    end
                }
			}
		}
	}
}