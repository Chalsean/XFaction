local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.12.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Channel = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed bug with changing channel colour.',
            },
            Properties = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Updated various objects to new standard format.',
            },
        },
    },		
}