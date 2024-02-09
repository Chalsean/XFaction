local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.5.2'] = {
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
                name = 'Bumped toc to 100100.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed API call that Blizzard renamed.',
            },
        },
    },			
}