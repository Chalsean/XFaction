local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.1.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Restriction = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Attempting to fix party/raid chat getting eaten during restriction',
            }
        },
    },		
}