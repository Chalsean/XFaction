local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.0.4'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            UTC = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Switched to UTC time instead of server time, there will be a follow up release to handle stale messages but need everyone on this version first',
            },
            Mailbox = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Retains internal message history between reloads to try to avoid showing duplicate guild messages',
            }
        },
    },		
}