local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.0.10'] = {
    Improvements = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Bug fix for guilds that are using the compression settings in guild info.',
            },
        }
    },			
}