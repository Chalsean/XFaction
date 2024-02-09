local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.6.8'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Bug fix for 4.6.6 GUILD chat modification.',
            },
        },
    },			
}