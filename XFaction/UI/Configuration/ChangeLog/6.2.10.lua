local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.2.10'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Double = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fix double posting',
            },
        },
    },		
}