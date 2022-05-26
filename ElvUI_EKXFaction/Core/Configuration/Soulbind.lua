local EKX, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'CSoulbind'
local ARG = EKX.Config.Soulbind.args
local DB = E.db.Confederation.Soulbind

local function ImportantColorString(string)
    return F.CreateColorString(string, {r = 0.204, g = 0.596, b = 0.859})
end

local function FormatDesc(code, helpText)
    return ImportantColorString(code) .. " = " .. helpText
end

ARG.desc = {
    order = 1,
    type = "group",
    inline = true,
    name = L["Description"],
    args = {
        feature_1 = {
            order = 1,
            type = "description",
            name = L["Soulbind can be used to view, change and automate active soulbind."],
            fontSize = "medium"
        }
    }
}

 ARG.Automation = {
    order = 3,
    type = "group",
    name = L["Automation"],
    get = function(info)
         return ARG.Automation[info[#info - 1]][info[#info]]
     end,
     set = function(info, value)
		ARG.Automation[info[#info - 1]][info[#info]] = value
     end,
    args = {
        desc = {
            order = 1,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                feature = {
                    order = 1,
                    type = "description",
                    name = L["Choose default soulbind during covenant change"],
                    fontSize = "medium"
                }
            }
        },
        enable = {
            order = 2,
            type = "toggle",
            name = L["Enable"],
            set = function(info, value)
                ARG.Automation[info[#info - 1]][info[#info]] = value
            end
        },
        includeDetails = {
            order = 3,
            type = "toggle",
            name = L["Include Details"],
            desc = L["Announce every time the progress has been changed."]
        },
        channel = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Channel"],
            get = function(info)
                return ARG.Automation[info[#info - 2]][info[#info - 1]][info[#info]]
            end,
            set = function(info, value)
                ARG.Automation[info[#info - 2]][info[#info - 1]][info[#info]] = value
            end,
            args = {
                party = {
                    order = 1,
                    name = L["In Party"],
                    type = "select",
                    values = {
                        NONE = L["None"],
                        SELF = L["Self(Chat Frame)"],
                        EMOTE = L["Emote"],
                        PARTY = L["Party"],
                        YELL = L["Yell"],
                        SAY = L["Say"]
                    }
                },
                instance = {
                    order = 2,
                    name = L["In Instance"],
                    type = "select",
                    values = {
                        NONE = L["None"],
                        PARTY = L["Party"],
                        SELF = L["Self(Chat Frame)"],
                        EMOTE = L["Emote"],
                        INSTANCE_CHAT = L["Instance"],
                        YELL = L["Yell"],
                        SAY = L["Say"]
                    }
                },
                raid = {
                    order = 3,
                    name = L["In Raid"],
                    type = "select",
                    values = {
                        NONE = L["None"],
                        SELF = L["Self(Chat Frame)"],
                        EMOTE = L["Emote"],
                        PARTY = L["Party"],
                        RAID = L["Raid"],
                        YELL = L["Yell"],
                        SAY = L["Say"]
                    }
                }
            }
        }
    }
}

-- do
--     local categoryLocales = {
--         feasts = L["Feasts"],
--         bots = L["Bots"],
--         toys = L["Toys"],
--         portals = L["Portals"]
--     }

--     local specialExampleSpell = {
--         feasts = 286050,
--         bots = 67826,
--         toys = 61031,
--         portals = 10059
--     }

--     local spellOptions = options.utility.args
--     local spellOrder = 10
--     local categoryOrder = 50
--     for categoryOrId, config in pairs(P.announcement.utility.spells) do
--         local groupName, groupOrder, exampleSpellId
--         local id = tonumber(categoryOrId)
--         if id then
--             groupName = GetSpellInfo(id)
--             exampleSpellId = id
--             groupOrder = spellOrder
--             spellOrder = spellOrder + 1
--         else
--             groupName = categoryLocales[categoryOrId]
--             exampleSpellId = specialExampleSpell[categoryOrId]
--             groupOrder = categoryOrder
--             categoryOrder = categoryOrder + 1
--         end

--         exampleSpellId = exampleSpellId or 20484

--         spellOptions[categoryOrId] = {
--             order = groupOrder,
--             name = groupName,
--             type = "group",
--             get = function(info)
--                 return E.db.WT.announcement.utility.spells[categoryOrId][info[#info]]
--             end,
--             set = function(info, value)
--                 E.db.WT.announcement.utility.spells[categoryOrId][info[#info]] = value
--             end,
--             args = {
--                 enable = {
--                     order = 1,
--                     type = "toggle",
--                     name = L["Enable"]
--                 },
--                 includePlayer = {
--                     order = 2,
--                     type = "toggle",
--                     name = L["Include Player"],
--                     desc = L["Uncheck this box, it will not send message if you cast the spell."]
--                 },
--                 raidWarning = {
--                     order = 3,
--                     type = "toggle",
--                     name = L["Raid Warning"],
--                     desc = L["If you have privilege, it would the message to raid warning(/rw) rather than raid(/r)."]
--                 },
--                 text = {
--                     order = 4,
--                     type = "input",
--                     name = L["Text"],
--                     desc = format(
--                         "%s\n%s\n%s",
--                         FormatDesc("%player%", L["Name of the player"]),
--                         FormatDesc("%target%", L["Target name"]),
--                         FormatDesc("%spell%", L["The spell link"])
--                     ),
--                     width = 2.5
--                 },
--                 useDefaultText = {
--                     order = 5,
--                     type = "execute",
--                     func = function()
--                         E.db.WT.announcement.utility.spells[categoryOrId].text =
--                             P.announcement.utility.spells[categoryOrId].text
--                     end,
--                     name = L["Default Text"]
--                 },
--                 example = {
--                     order = 6,
--                     type = "description",
--                     name = function()
--                         local message = E.db.WT.announcement.utility.spells[categoryOrId].text
--                         message = gsub(message, "%%player%%", E.myname)
--                         message = gsub(message, "%%target%%", L["Sylvanas"])
--                         message = gsub(message, "%%spell%%", GetSpellLink(exampleSpellId))
--                         return "\n" .. ImportantColorString(L["Example"]) .. ": " .. message .. "\n"
--                     end
--                 }
--             }
--         }
--     end
-- end
