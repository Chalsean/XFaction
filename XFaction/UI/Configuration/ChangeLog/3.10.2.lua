local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['3.10.2'] = {
    New = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Selectable font type and size for Guild, Links and Metrics DTs.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Implemented workaround to avoid Blizzard API bug with community channels.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Added the following options for Kui Nameplates: Confederate name/initials, Guild initials, Player main raiding character, Team name, Member icon.',
            },
        }
    },			
}