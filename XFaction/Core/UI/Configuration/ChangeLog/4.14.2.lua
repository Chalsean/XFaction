local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.14.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Guild = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Will leverage GUILD chat rather than custom channel if only guild on realm.',
            },
            GChat = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed issue of achievements/gchat not displaying in 4.13.',
            },
        },
    },		
}