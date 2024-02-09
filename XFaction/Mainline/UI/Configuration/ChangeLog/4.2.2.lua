local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.2.2'] = {
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
                name = 'Cleaner team/alt name tagging for player notes and no longer need to specify a guild rank for alts.\n[XFt:team_initials]\n[XFa:main_name]',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'Cleaner guild setup menu for GMs.',
                fontSize = 'medium',
            },
            Three = {
                order = 3,
                type = 'description',
                name = 'Support multi-character team initials.',
                fontSize = 'medium',
            },
            Four = {
                order = 4,
                type = 'description',
                name = 'XFaction uOF tags can be used in Nameplates/UnitFrames and show in ElvUI Available Tags.',
                fontSize = 'medium',
            },
        }
    },			
}