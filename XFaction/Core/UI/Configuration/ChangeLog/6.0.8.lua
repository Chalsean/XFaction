local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.0.8'] = {
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
                name = 'Hopefully fixed online/offline notifications for real this time (thx Hyphie!)',
            },
            Duplicate = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Added logic to log out of chat channel when logging off or leaving guild',
            },
        },
    },		
}