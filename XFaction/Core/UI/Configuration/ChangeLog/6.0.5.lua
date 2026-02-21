local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.0.5'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Old = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed old code that was preventing friend online notifications for some',
            },
        },
    },		
}