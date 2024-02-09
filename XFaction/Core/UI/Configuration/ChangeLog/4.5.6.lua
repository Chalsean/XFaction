local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.5.6'] = {
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
                name = 'Fixed unit faction recognition when it is different than the guild.',
            },
        },
    },			
}