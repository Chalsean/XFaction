local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.0.6'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Deprecated = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Removed old code that was preventing friend online notifications for some',
            },
            Duplicate = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Logic to mitigate duplicate messages',
            },
        },
    },		
}