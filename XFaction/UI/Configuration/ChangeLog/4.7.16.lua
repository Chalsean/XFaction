local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.7.16'] = {
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
                name = 'Fixed disabling guild chat.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed disabling achievements.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Players will now see their own crafting order notifications.',
            },
            Four = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed filtering crafting order notifications by profession.',
            },
            Five = {
                order = 5,
                type = 'description',
                fontSize = 'medium',
                name = "Fixed random 'Collection key must be string or number' error.",
            },
        },
    },		
}