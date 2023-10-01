local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.3.8'] = {
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
                name = 'Bumped toc to 100005.',
            },
            Bar1 = {
                order = 2,
                name = '',
                type = 'header'
            },
            Two = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Rolled back 4.3.4 logic to isolate a memory leak.',
            },
        }
    },			
}