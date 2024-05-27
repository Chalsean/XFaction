local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.12.4'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Bug = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed bug when entering/exiting instances.',
            },
        },
    },		
}