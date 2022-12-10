local XFG, G = unpack(select(2, ...))
local ObjectName = 'RealmCollection'

--#region Realm list
-- This data originally came from LibRealmInfo, it seems no longer supported as the data is quite stale and the library had bugs nobody was fixing
-- There is a blizz web api that provides this data
local RealmData = {
	[1]="Lightbringer,PvE,enUS,US,PST",
	[2]="Cenarius,PvE,enUS,US,PST",
	[3]="Uther,PvE,enUS,US,CST",
	[4]="Kilrogg,PvE,enUS,US,PST",
	[5]="Proudmoore,PvE,enUS,US,PST",
	[6]="Hyjal,PvE,enUS,US,PST",
	[7]="Frostwolf,PvE,enUS,US,PST",
	[8]="Ner'zhul,PvE,enUS,US,CST",
	[9]="Kil'jaeden,PvE,enUS,US,PST",
	[10]="Blackrock,PvE,enUS,US,PST",
	[11]="Tichondrius,PvE,enUS,US,PST",
	[12]="Silver Hand,RP,enUS,US,PST",
	[13]="Doomhammer,PvE,enUS,US,PST",
	[14]="Icecrown,PvE,enUS,US,CST",
	[15]="Deathwing,PvE,enUS,US,PST",
	[16]="Kel'Thuzad,PvE,enUS,US,MST",
	[32]="Jared's Regional,PvE,enUS,US,PST",
	[39]="Faron Woods,PvE,enUS,US,PST",
	[47]="Eitrigg,PvE,enUS,US,CST",
	[51]="Garona,PvE,enUS,US,CST",
	[52]="Alleria,PvE,enUS,US,CST",
	[53]="Hellscream,PvE,enUS,US,CST",
	[54]="Blackhand,PvE,enUS,US,CST",
	[55]="Whisperwind,PvE,enUS,US,CST",
	[56]="Archimonde,PvE,enUS,US,CST",
	[57]="Illidan,PvE,enUS,US,CST",
	[58]="Stormreaver,PvE,enUS,US,CST",
	[59]="Mal'Ganis,PvE,enUS,US,CST",
	[60]="Stormrage,PvE,enUS,US,EST",
	[61]="Zul'jin,PvE,enUS,US,EST",
	[62]="Medivh,PvE,enUS,US,EST",
	[63]="Durotan,PvE,enUS,US,EST",
	[64]="Bloodhoof,PvE,enUS,US,EST",
	[65]="Khadgar,PvE,enUS,US,CST",
	[66]="Dalaran,PvE,enUS,US,EST",
	[67]="Elune,PvE,enUS,US,EST",
	[68]="Lothar,PvE,enUS,US,EST",
	[69]="Arthas,PvE,enUS,US,EST",
	[70]="Mannoroth,PvE,enUS,US,EST",
	[71]="Warsong,PvE,enUS,US,EST",
	[72]="Shattered Hand,PvE,enUS,US,PST",
	[73]="Bleeding Hollow,PvE,enUS,US,EST",
	[74]="Skullcrusher,PvE,enUS,US,EST",
	[75]="Argent Dawn,RP,enUS,US,EST",
	[76]="Sargeras,PvE,enUS,US,CST",
	[77]="Azgalor,PvE,enUS,US,CST",
	[78]="Magtheridon,PvE,enUS,US,EST",
	[79]="Destromath,PvE,enUS,US,CST",
	[80]="Gorgonnash,PvE,enUS,US,EST",
	[81]="Dethecus,PvE,enUS,US,CST",
	[82]="Spinebreaker,PvE,enUS,US,CST",
	[83]="Bonechewer,PvE,enUS,US,CST",
	[84]="Dragonmaw,PvE,enUS,US,PST",
	[85]="Shadowsong,PvE,enUS,US,PST",
	[86]="Silvermoon,PvE,enUS,US,PST",
	[87]="Windrunner,PvE,enUS,US,PST",
	[88]="Cenarion Circle,RP,enUS,US,PST",
	[89]="Nathrezim,PvE,enUS,US,CST",
	[90]="Terenas,PvE,enUS,US,MST",
	[91]="Burning Blade,PvE,enUS,US,EST",
	[92]="Gorefiend,PvE,enUS,US,CST",
	[93]="Eredar,PvE,enUS,US,CST",
	[94]="Shadowmoon,PvE,enUS,US,CST",
	[95]="Lightning's Blade,PvE,enUS,US,EST",
	[96]="Eonar,PvE,enUS,US,EST",
	[97]="Gilneas,PvE,enUS,US,EST",
	[98]="Kargath,PvE,enUS,US,EST",
	[99]="Llane,PvE,enUS,US,EST",
	[100]="Earthen Ring,RP,enUS,US,EST",
	[101]="Laughing Skull,PvE,enUS,US,CST",
	[102]="Burning Legion,PvE,enUS,US,CST",
	[103]="Thunderlord,PvE,enUS,US,CST",
	[104]="Malygos,PvE,enUS,US,CST",
	[105]="Thunderhorn,PvE,enUS,US,CST",
	[106]="Aggramar,PvE,enUS,US,CST",
	[107]="Crushridge,PvE,enUS,US,CST",
	[108]="Stonemaul,PvE,enUS,US,MST",
	[109]="Daggerspine,PvE,enUS,US,CST",
	[110]="Stormscale,PvE,enUS,US,EST",
	[111]="Dunemaul,PvE,enUS,US,MST",
	[112]="Boulderfist,PvE,enUS,US,MST",
	[113]="Suramar,PvE,enUS,US,PST",
	[114]="Dragonblight,PvE,enUS,US,PST",
	[115]="Draenor,PvE,enUS,US,PST",
	[116]="Uldum,PvE,enUS,US,PST",
	[117]="Bronzebeard,PvE,enUS,US,PST",
	[118]="Feathermoon,RP,enUS,US,PST",
	[119]="Bloodscalp,PvE,enUS,US,MST",
	[120]="Darkspear,PvE,enUS,US,MST",
	[121]="Azjol-Nerub,PvE,enUS,US,MST",
	[122]="Perenolde,PvE,enUS,US,MST",
	[123]="Eldre'Thalas,PvE,enUS,US,EST",
	[124]="Spirestone,PvE,enUS,US,EST",
	[125]="Shadow Council,RP,enUS,US,MST",
	[126]="Scarlet Crusade,RP,enUS,US,PST",
	[127]="Firetree,PvE,enUS,US,EST",
	[128]="Frostmane,PvE,enUS,US,CST",
	[129]="Gurubashi,PvE,enUS,US,CST",
	[130]="Smolderthorn,PvE,enUS,US,CST",
	[131]="Skywall,PvE,enUS,US,PST",
	[151]="Runetotem,PvE,enUS,US,CST",
	[153]="Moonrunner,PvE,enUS,US,PST",
	[154]="Detheroc,PvE,enUS,US,CST",
	[155]="Kalecgos,PvE,enUS,US,PST",
	[156]="Ursin,PvE,enUS,US,PST",
	[157]="Dark Iron,PvE,enUS,US,PST",
	[158]="Greymane,PvE,enUS,US,CST",
	[159]="Wildhammer,PvE,enUS,US,CST",
	[160]="Staghelm,PvE,enUS,US,CST",
	[162]="Emerald Dream,RP,enUS,US,CST",
	[163]="Maelstrom,RP,enUS,US,CST",
	[164]="Twisting Nether,RP,enUS,US,CST",
	[201]="불타는 군단,PvE,koKR,KR,Burning Legion",
	[205]="아즈샤라,PvE,koKR,KR,Azshara",
	[207]="달라란,PvE,koKR,KR,Dalaran",
	[210]="듀로탄,PvE,koKR,KR,Durotan",
	[211]="노르간논,PvE,koKR,KR,Norgannon",
	[212]="가로나,PvE,koKR,KR,Garona",
	[214]="윈드러너,PvE,koKR,KR,Windrunner",
	[215]="굴단,PvE,koKR,KR,Gul'dan",
	[258]="알렉스트라자,PvE,koKR,KR,Alexstrasza",
	[264]="말퓨리온,PvE,koKR,KR,Malfurion",
	[293]="헬스크림,PvE,koKR,KR,Hellscream",
	[500]="Aggramar,PvE,enUS,EU",
	[501]="Arathor,PvE,enUS,EU",
	[502]="Aszune,PvE,enUS,EU",
	[503]="Azjol-Nerub,PvE,enUS,EU",
	[504]="Bloodhoof,PvE,enUS,EU",
	[505]="Doomhammer,PvE,enUS,EU",
	[506]="Draenor,PvE,enUS,EU",
	[507]="Dragonblight,PvE,enUS,EU",
	[508]="Emerald Dream,PvE,enUS,EU",
	[509]="Garona,PvE,frFR,EU",
	[510]="Vol'jin,PvE,frFR,EU",
	[511]="Sunstrider,PvE,enUS,EU",
	[512]="Arak-arahm,PvE,frFR,EU",
	[513]="Twilight's Hammer,PvE,enUS,EU",
	[515]="Zenedar,PvE,enUS,EU",
	[516]="Forscherliga,RP,deDE,EU",
	[517]="Medivh,PvE,frFR,EU",
	[518]="Agamaggan,PvE,enUS,EU",
	[519]="Al'Akir,PvE,enUS,EU",
	[521]="Bladefist,PvE,enUS,EU",
	[522]="Bloodscalp,PvE,enUS,EU",
	[523]="Burning Blade,PvE,enUS,EU",
	[524]="Burning Legion,PvE,enUS,EU",
	[525]="Crushridge,PvE,enUS,EU",
	[526]="Daggerspine,PvE,enUS,EU",
	[527]="Deathwing,PvE,enUS,EU",
	[528]="Dragonmaw,PvE,enUS,EU",
	[529]="Dunemaul,PvE,enUS,EU",
	[531]="Dethecus,PvE,deDE,EU",
	[533]="Sinstralis,PvE,frFR,EU",
	[535]="Durotan,PvE,deDE,EU",
	[536]="Argent Dawn,RP,enUS,EU",
	[537]="Kirin Tor,RP,frFR,EU",
	[538]="Dalaran,PvE,frFR,EU",
	[539]="Archimonde,PvE,frFR,EU",
	[540]="Elune,PvE,frFR,EU",
	[541]="Illidan,PvE,frFR,EU",
	[542]="Hyjal,PvE,frFR,EU",
	[543]="Kael'thas,PvE,frFR,EU",
	[544]="Ner’zhul,PvE,frFR,EU,Ner'zhul",
	[545]="Cho’gall,PvE,frFR,EU,Cho'gall",
	[546]="Sargeras,PvE,frFR,EU",
	[547]="Runetotem,PvE,enUS,EU",
	[548]="Shadowsong,PvE,enUS,EU",
	[549]="Silvermoon,PvE,enUS,EU",
	[550]="Stormrage,PvE,enUS,EU",
	[551]="Terenas,PvE,enUS,EU",
	[552]="Thunderhorn,PvE,enUS,EU",
	[553]="Turalyon,PvE,enUS,EU",
	[554]="Ravencrest,PvE,enUS,EU",
	[556]="Shattered Hand,PvE,enUS,EU",
	[557]="Skullcrusher,PvE,enUS,EU",
	[558]="Spinebreaker,PvE,enUS,EU",
	[559]="Stormreaver,PvE,enUS,EU",
	[560]="Stormscale,PvE,enUS,EU",
	[561]="Earthen Ring,RP,enUS,EU",
	[562]="Alexstrasza,PvE,deDE,EU",
	[563]="Alleria,PvE,deDE,EU",
	[564]="Antonidas,PvE,deDE,EU",
	[565]="Baelgun,PvE,deDE,EU",
	[566]="Blackhand,PvE,deDE,EU",
	[567]="Gilneas,PvE,deDE,EU",
	[568]="Kargath,PvE,deDE,EU",
	[569]="Khaz'goroth,PvE,deDE,EU",
	[570]="Lothar,PvE,deDE,EU",
	[571]="Madmortem,PvE,deDE,EU",
	[572]="Malfurion,PvE,deDE,EU",
	[573]="Zuluhed,PvE,deDE,EU",
	[574]="Nozdormu,PvE,deDE,EU",
	[575]="Perenolde,PvE,deDE,EU",
	[576]="Die Silberne Hand,RP,deDE,EU",
	[577]="Aegwynn,PvE,deDE,EU",
	[578]="Arthas,PvE,deDE,EU",
	[579]="Azshara,PvE,deDE,EU",
	[580]="Blackmoore,PvE,deDE,EU",
	[581]="Blackrock,PvE,deDE,EU",
	[582]="Destromath,PvE,deDE,EU",
	[583]="Eredar,PvE,deDE,EU",
	[584]="Frostmourne,PvE,deDE,EU",
	[585]="Frostwolf,PvE,deDE,EU",
	[586]="Gorgonnash,PvE,deDE,EU",
	[587]="Gul'dan,PvE,deDE,EU",
	[588]="Kel'Thuzad,PvE,deDE,EU",
	[589]="Kil'jaeden,PvE,deDE,EU",
	[590]="Mal'Ganis,PvE,deDE,EU",
	[591]="Mannoroth,PvE,deDE,EU",
	[592]="Zirkel des Cenarius,RP,deDE,EU",
	[593]="Proudmoore,PvE,deDE,EU",
	[594]="Nathrezim,PvE,deDE,EU",
	[600]="Dun Morogh,PvE,deDE,EU",
	[601]="Aman'thul,PvE,deDE,EU",
	[602]="Sen'jin,PvE,deDE,EU",
	[604]="Thrall,PvE,deDE,EU",
	[605]="Theradras,PvE,deDE,EU",
	[606]="Genjuros,PvE,enUS,EU",
	[607]="Balnazzar,PvE,enUS,EU",
	[608]="Anub'arak,PvE,deDE,EU",
	[609]="Wrathbringer,PvE,deDE,EU",
	[610]="Onyxia,PvE,deDE,EU",
	[611]="Nera'thor,PvE,deDE,EU",
	[612]="Nefarian,PvE,deDE,EU",
	[613]="Kult der Verdammten,RP,deDE,EU",
	[614]="Das Syndikat,RP,deDE,EU",
	[615]="Terrordar,PvE,deDE,EU",
	[616]="Krag'jin,PvE,deDE,EU",
	[617]="Der Rat von Dalaran,RP,deDE,EU",
	[618]="Nordrassil,PvE,enUS,EU",
	[619]="Hellscream,PvE,enUS,EU",
	[621]="Laughing Skull,PvE,enUS,EU",
	[622]="Magtheridon,PvE,enUS,EU",
	[623]="Quel'Thalas,PvE,enUS,EU",
	[624]="Neptulon,PvE,enUS,EU",
	[625]="Twisting Nether,PvE,enUS,EU",
	[626]="Ragnaros,PvE,enUS,EU",
	[627]="The Maelstrom,PvE,enUS,EU",
	[628]="Sylvanas,PvE,enUS,EU",
	[629]="Vashj,PvE,enUS,EU",
	[630]="Bloodfeather,PvE,enUS,EU",
	[631]="Darksorrow,PvE,enUS,EU",
	[632]="Frostwhisper,PvE,enUS,EU",
	[633]="Kor'gall,PvE,enUS,EU",
	[635]="Defias Brotherhood,RP,enUS,EU",
	[636]="The Venture Co,RP,enUS,EU",
	[637]="Lightning's Blade,PvE,enUS,EU",
	[638]="Haomarush,PvE,enUS,EU",
	[639]="Xavius,PvE,enUS,EU",
	[640]="Khaz Modan,PvE,frFR,EU",
	[641]="Drek'Thar,PvE,frFR,EU",
	[642]="Rashgarroth,PvE,frFR,EU",
	[643]="Throk'Feroth,PvE,frFR,EU",
	[644]="Conseil des Ombres,RP,frFR,EU",
	[645]="Varimathras,PvE,frFR,EU",
	[646]="Hakkar,PvE,enUS,EU",
	[647]="Les Sentinelles,RP,frFR,EU",
	[963]="暗影之月,PvE,zhTW,TW,Shadowmoon",
	[964]="尖石,PvE,zhTW,TW,Spirestone",
	[965]="雷鱗,PvE,zhTW,TW,Stormscale",
	[966]="巨龍之喉,PvE,zhTW,TW,Dragonmaw",
	[968]="Naralex,PvE,enUS,EU",
	[969]="Nobundo,PvE,enUS,KR",
	[977]="冰霜之刺,PvE,zhTW,TW,Frostmane",
	[978]="日落沼澤,PvE,zhTW,TW,Sundown Marsh",
	[979]="地獄吼,PvE,zhTW,TW,Hellscream",
	[980]="天空之牆,PvE,zhTW,TW,Skywall",
	[982]="世界之樹,PvE,zhTW,TW,World Tree",
	[984]="Balnazzar,PvE,enUS,US,PST",
	[985]="水晶之刺,PvE,zhTW,TW,Crystalpine Stinger",
	[999]="狂熱之刃,PvE,zhTW,TW,Zealot Blade",
	[1001]="冰風崗哨,PvE,zhTW,TW,Chillwind Point",
	[1006]="米奈希爾,PvE,zhTW,TW,Menethil",
	[1023]="屠魔山谷,PvE,zhTW,TW,Demon Fall Canyon",
	[1033]="語風,PvE,zhTW,TW,Whisperwind",
	[1037]="血之谷,PvE,zhTW,TW,Bleeding Hollow",
	[1038]="亞雷戈斯,PvE,zhTW,TW,Arygos",
	[1043]="夜空之歌,PvE,zhTW,TW,Nightsong",
	[1046]="聖光之願,PvE,zhTW,TW,Light's Hope",
	[1048]="銀翼要塞,PvE,zhTW,TW,Silverwing Hold",
	[1049]="憤怒使者,PvE,zhTW,TW,Wrathbringer",
	[1054]="阿薩斯,PvE,zhTW,TW,Arthas",
	[1056]="眾星之子,PvE,zhTW,TW,Quel'dorei",
	[1057]="寒冰皇冠,PvE,zhTW,TW,Icecrown",
	[1067]="Cho'gall,PvE,enUS,US,CST",
	[1068]="Gul'dan,PvE,enUS,US,EST",
	[1069]="Kael'thas,PvE,enUS,US,CST",
	[1070]="Alexstrasza,PvE,enUS,US,CST",
	[1071]="Kirin Tor,RP,enUS,US,CST",
	[1072]="Ravencrest,PvE,enUS,US,CST",
	[1075]="Balnazzar,PvE,enUS,US,EST",
	[1080]="Khadgar,PvE,enUS,EU",
	[1081]="Bronzebeard,PvE,enUS,EU",
	[1082]="Kul Tiras,PvE,enUS,EU",
	[1083]="Chromaggus,PvE,enUS,EU",
	[1084]="Dentarg,PvE,enUS,EU",
	[1085]="Moonglade,RP,enUS,EU",
	[1086]="La Croisade écarlate,RP,frFR,EU",
	[1087]="Executus,PvE,enUS,EU",
	[1088]="Trollbane,PvE,enUS,EU",
	[1089]="Mazrigos,PvE,enUS,EU",
	[1090]="Talnivarr,PvE,enUS,EU",
	[1091]="Emeriss,PvE,enUS,EU",
	[1092]="Drak'thul,PvE,enUS,EU",
	[1093]="Ahn'Qiraj,PvE,enUS,EU",
	[1096]="Scarshield Legion,RP,enUS,EU",
	[1097]="Ysera,PvE,deDE,EU",
	[1098]="Malygos,PvE,deDE,EU",
	[1099]="Rexxar,PvE,deDE,EU",
	[1104]="Anetheron,PvE,deDE,EU",
	[1105]="Nazjatar,PvE,deDE,EU",
	[1106]="Tichondrius,PvE,deDE,EU",
	[1117]="Steamwheedle Cartel,RP,enUS,EU",
	[1118]="Die ewige Wacht,RP,deDE,EU",
	[1119]="Die Todeskrallen,RP,deDE,EU",
	[1121]="Die Arguswacht,RP,deDE,EU",
	[1122]="Uldaman,PvE,frFR,EU",
	[1123]="Eitrigg,PvE,frFR,EU",
	[1127]="Confrérie du Thorium,RP,frFR,EU",
	[1128]="Azshara,PvE,enUS,US,CST",
	[1129]="Agamaggan,PvE,enUS,US,CST",
	[1130]="Lightninghoof,RP,enUS,US,CST",
	[1131]="Nazjatar,PvE,enUS,US,EST",
	[1132]="Malfurion,PvE,enUS,US,EST",
	[1136]="Aegwynn,PvE,enUS,US,CST",
	[1137]="Akama,PvE,enUS,US,PST",
	[1138]="Chromaggus,PvE,enUS,US,CST",
	[1139]="Draka,PvE,enUS,US,PST",
	[1140]="Drak'thul,PvE,enUS,US,PST",
	[1141]="Garithos,PvE,enUS,US,CST",
	[1142]="Hakkar,PvE,enUS,US,CST",
	[1143]="Khaz Modan,PvE,enUS,US,MST",
	[1145]="Mug'thol,PvE,enUS,US,PST",
	[1146]="Korgath,PvE,enUS,US,CST",
	[1147]="Kul Tiras,PvE,enUS,US,CST",
	[1148]="Malorne,PvE,enUS,US,EST",
	[1151]="Rexxar,PvE,enUS,US,CST",
	[1154]="Thorium Brotherhood,RP,enUS,US,PST",
	[1165]="Arathor,PvE,enUS,US,PST",
	[1168]="Blackmoore,PvE,enUS,US,PST",
	[1169]="Naxxramas,PvE,enUS,US,PST",
	[1171]="Theradras,PvE,enUS,US,PST",
	[1173]="Madoran,PvE,enUS,US,CST",
	[1174]="Xavius,PvE,enUS,US,PST",
	[1175]="Trollbane,PvE,enUS,US,EST",
	[1182]="Muradin,PvE,enUS,US,CST",
	[1184]="Vek'nilash,PvE,enUS,US,CST",
	[1185]="Sen'jin,PvE,enUS,US,CST",
	[1190]="Baelgun,PvE,enUS,US,PST",
	[1258]="Duskwood,PvE,enUS,US,EST",
	[1259]="Zuluhed,PvE,enUS,US,PST",
	[1260]="Steamwheedle Cartel,RP,enUS,US,CST",
	[1262]="Norgannon,PvE,enUS,US,EST",
	[1263]="Thrall,PvE,enUS,US,EST",
	[1264]="Anetheron,PvE,enUS,US,EST",
	[1265]="Turalyon,PvE,enUS,US,EST",
	[1266]="Haomarush,PvE,enUS,US,CST",
	[1267]="Scilla,PvE,enUS,US,PST",
	[1268]="Ysondre,PvE,enUS,US,EST",
	[1270]="Ysera,PvE,enUS,US,EST",
	[1271]="Dentarg,PvE,enUS,US,CST",
	[1276]="Andorhal,PvE,enUS,US,PST",
	[1277]="Executus,PvE,enUS,US,PST",
	[1278]="Dalvengyr,PvE,enUS,US,PST",
	[1280]="Black Dragonflight,PvE,enUS,US,EST",
	[1282]="Altar of Storms,PvE,enUS,US,EST",
	[1283]="Uldaman,PvE,enUS,US,CST",
	[1284]="Aerie Peak,PvE,enUS,US,PST",
	[1285]="Onyxia,PvE,enUS,US,EST",
	[1286]="Demon Soul,PvE,enUS,US,PST",
	[1287]="Gnomeregan,PvE,enUS,US,PST",
	[1288]="Anvilmar,PvE,enUS,US,CST",
	[1289]="The Venture Co,RP,enUS,US,CST",
	[1290]="Sentinels,RP,enUS,US,CST",
	[1291]="Jaedenar,PvE,enUS,US,CST",
	[1292]="Tanaris,PvE,enUS,US,CST",
	[1293]="Alterac Mountains,PvE,enUS,US,EST",
	[1294]="Undermine,PvE,enUS,US,CST",
	[1295]="Lethon,PvE,enUS,US,CST",
	[1296]="Blackwing Lair,PvE,enUS,US,CST",
	[1297]="Arygos,PvE,enUS,US,EST",
	[1298]="Vek'nilash,PvE,enUS,EU",
	[1299]="Boulderfist,PvE,enUS,EU",
	[1300]="Frostmane,PvE,enUS,EU",
	[1301]="Outland,PvE,enUS,EU",
	[1302]="Stonemaul,PvE,enUS,EU",
	[1303]="Grim Batol,PvE,enUS,EU",
	[1304]="Jaedenar,PvE,enUS,EU",
	[1305]="Kazzak,PvE,enUS,EU",
	[1306]="Tarren Mill,PvE,enUS,EU",
	[1307]="Chamber of Aspects,PvE,enUS,EU",
	[1308]="Ravenholdt,RP,enUS,EU",
	[1309]="Pozzo dell'Eternità,PvE,itIT,EU",
	[1310]="Eonar,PvE,enUS,EU",
	[1311]="Kilrogg,PvE,enUS,EU",
	[1312]="Aerie Peak,PvE,enUS,EU",
	[1313]="Wildhammer,PvE,enUS,EU",
	[1314]="Saurfang,PvE,enUS,EU",
	[1315]="Caduta dei Draghi,PvE,itIT,EU",
	[1316]="Nemesis,PvE,itIT,EU",
	[1317]="Darkmoon Faire,RP,enUS,EU",
	[1318]="Vek'lor,PvE,deDE,EU",
	[1319]="Mug'thol,PvE,deDE,EU",
	[1320]="Taerar,PvE,deDE,EU",
	[1321]="Dalvengyr,PvE,deDE,EU",
	[1322]="Rajaxx,PvE,deDE,EU",
	[1323]="Ulduar,PvE,deDE,EU",
	[1324]="Malorne,PvE,deDE,EU",
	[1325]="Grizzlyhügel,PvE,deDE,EU",
	[1326]="Der Abyssische Rat,RP,deDE,EU",
	[1327]="Der Mithrilorden,RP,deDE,EU",
	[1328]="Tirion,PvE,deDE,EU",
	[1329]="Muradin,PvE,deDE,EU",
	[1330]="Ambossar,PvE,deDE,EU",
	[1331]="Suramar,PvE,frFR,EU",
	[1332]="Krasus,PvE,frFR,EU",
	[1333]="Die Nachtwache,RP,deDE,EU",
	[1334]="Arathi,PvE,frFR,EU",
	[1335]="Ysondre,PvE,frFR,EU",
	[1336]="Eldre'Thalas,PvE,frFR,EU",
	[1337]="Culte de la Rive noire,RP,frFR,EU",
	[1342]="Echo Isles,PvE,enUS,US,PST",
	[1344]="The Forgotten Coast,PvE,enUS,US,EST",
	[1345]="Fenris,PvE,enUS,US,PST",
	[1346]="Anub'arak,PvE,enUS,US,CST",
	[1347]="Blackwater Raiders,RP,enUS,US,MST",
	[1348]="Vashj,PvE,enUS,US,PST",
	[1349]="Korialstrasz,PvE,enUS,US,EST",
	[1350]="Misha,PvE,enUS,US,CST",
	[1351]="Darrowmere,PvE,enUS,US,PST",
	[1352]="Ravenholdt,RP,enUS,US,CST",
	[1353]="Bladefist,PvE,enUS,US,CST",
	[1354]="Shu'halo,PvE,enUS,US,CST",
	[1355]="Winterhoof,PvE,enUS,US,PST",
	[1356]="Sisters of Elune,RP,enUS,US,PST",
	[1357]="Maiev,PvE,enUS,US,MST",
	[1358]="Rivendare,PvE,enUS,US,EST",
	[1359]="Nordrassil,PvE,enUS,US,CST",
	[1360]="Tortheldrin,PvE,enUS,US,CST",
	[1361]="Cairne,PvE,enUS,US,MST",
	[1362]="Drak'Tharon,PvE,enUS,US,EST",
	[1363]="Antonidas,PvE,enUS,US,PST",
	[1364]="Shandris,PvE,enUS,US,PST",
	[1365]="Moon Guard,RP,enUS,US,CST",
	[1367]="Nazgrel,PvE,enUS,US,CST",
	[1368]="Hydraxis,PvE,enUS,US,MST",
	[1369]="Wyrmrest Accord,RP,enUS,US,PST",
	[1370]="Farstriders,RP,enUS,US,PST",
	[1371]="Borean Tundra,PvE,enUS,US,PST",
	[1372]="Quel'dorei,PvE,enUS,US,CST",
	[1373]="Garrosh,PvE,enUS,US,EST",
	[1374]="Mok'Nathal,PvE,enUS,US,PST",
	[1375]="Nesingwary,PvE,enUS,US,CST",
	[1377]="Drenden,PvE,enUS,US,PST",
	[1378]="Dun Modr,PvE,esES,EU",
	[1379]="Zul'jin,PvE,esES,EU",
	[1380]="Uldum,PvE,esES,EU",
	[1381]="C'Thun,PvE,esES,EU",
	[1382]="Sanguino,PvE,esES,EU",
	[1383]="Shen'dralar,PvE,esES,EU",
	[1384]="Tyrande,PvE,esES,EU",
	[1385]="Exodar,PvE,esES,EU",
	[1386]="Minahonda,PvE,esES,EU",
	[1387]="Los Errantes,PvE,esES,EU",
	[1388]="Lightbringer,PvE,enUS,EU",
	[1389]="Darkspear,PvE,enUS,EU",
	[1390]="Internal Record 1390,PvE,enUS,EU",
	[1391]="Alonsus,PvE,enUS,EU",
	[1392]="Burning Steppes,PvE,enUS,EU",
	[1393]="Bronze Dragonflight,PvE,enUS,EU",
	[1394]="Anachronos,PvE,enUS,EU",
	[1395]="Colinas Pardas,PvE,esES,EU",
	[1396]="Molten Core,PvE,enUS,EU",
	[1400]="Un'Goro,PvE,deDE,EU",
	[1401]="Garrosh,PvE,deDE,EU",
	[1402]="Menethil,PvE,enUS,EU",
	[1403]="Gnomeragan,PvE,enUS,EU",
	[1404]="Area 52,PvE,deDE,EU",
	[1405]="Todeswache,RP,deDE,EU",
	[1406]="Arygos,PvE,deDE,EU",
	[1407]="Teldrassil,PvE,deDE,EU",
	[1408]="Norgannon,PvE,deDE,EU",
	[1409]="Lordaeron,PvE,deDE,EU",
	[1413]="Aggra (Português),PvE,ptBR,EU",
	[1415]="Terokkar,PvE,enUS,EU",
	[1416]="Blade's Edge,PvE,enUS,EU",
	[1417]="Azuremyst,PvE,enUS,EU",
	[1425]="Drakkari,PvE,esMX,US,CST",
	[1426]="Ulduar,PvE,esMX,US,CST",
	[1427]="Ragnaros,PvE,esMX,US,CST",
	[1428]="Quel'Thalas,PvE,esMX,US,CST",
	[1549]="Azuremyst,PvE,enUS,US,CST",
	[1555]="Auchindoun,PvE,enUS,US,CST",
	[1556]="Coilfang,PvE,enUS,US,PST",
	[1557]="Shattered Halls,PvE,enUS,US,PST",
	[1558]="Blood Furnace,PvE,enUS,US,EST",
	[1559]="The Underbog,PvE,enUS,US,CST",
	[1563]="Terokkar,PvE,enUS,US,CST",
	[1564]="Blade's Edge,PvE,enUS,US,CST",
	[1565]="Exodar,PvE,enUS,US,EST",
	[1566]="Area 52,PvE,enUS,US,EST",
	[1567]="Velen,PvE,enUS,US,EST",
	[1570]="The Scryers,RP,enUS,US,EST",
	[1572]="Zangarmarsh,PvE,enUS,US,CST",
	[1576]="Fizzcrank,PvE,enUS,US,CST",
	[1578]="Ghostlands,PvE,enUS,US,CST",
	[1579]="Grizzly Hills,PvE,enUS,US,EST",
	[1581]="Galakrond,PvE,enUS,US,CST",
	[1582]="Dawnbringer,PvE,enUS,US,CST",
	[1587]="Hellfire,PvE,enUS,EU",
	[1588]="Ghostlands,PvE,enUS,EU",
	[1589]="Nagrand,PvE,enUS,EU",
	[1595]="The Sha'tar,RP,enUS,EU",
	[1596]="Karazhan,PvE,enUS,EU",
	[1597]="Auchindoun,PvE,enUS,EU",
	[1598]="Shattered Halls,PvE,enUS,EU",
	[1606]="Sporeggar,RP,enUS,EU",
	[1607]="Nethersturm,PvE,deDE,EU",
	[1608]="Shattrath,PvE,deDE,EU",
	[1611]="Festung der Stürme,PvE,deDE,EU",
	[1612]="Echsenkessel,PvE,deDE,EU",
	[1613]="Blutkessel,PvE,deDE,EU",
	[1618]="Die Aldor,RP,deDE,EU",
	[1619]="Das Konsortium,RP,deDE,EU",
	[1620]="Chants éternels,PvE,frFR,EU",
	[1621]="Marécage de Zangar,PvE,frFR,EU",
	[1622]="Temple noir,PvE,frFR,EU",
	[1624]="Naxxramas,PvE,frFR,EU",
	[1626]="Les Clairvoyants,RP,frFR,EU",
	[2073]="Winterhuf,PvE,enUS,EU,PST",
	[2074]="Schwarznarbe,PvE,enUS,EU",
	[2075]="雲蛟衛,PvE,zhTW,TW,Order of the Cloud Serpent",
	[2079]="와일드해머,PvE,koKR,KR,Wildhammer",
	[2106]="렉사르,PvE,koKR,KR,Rexxar",
	[2107]="하이잘,PvE,koKR,KR,Hyjal",
	[2108]="데스윙,PvE,koKR,KR,Deathwing",
	[2110]="세나리우스,PvE,koKR,KR,Cenarius",
	[2111]="스톰레이지,PvE,koKR,KR,Stormrage",
	[2116]="줄진,PvE,koKR,KR,Zul'jin",
	[3207]="Goldrinn,PvE,ptBR,US,undefined",
	[3208]="Nemesis,PvE,ptBR,US,undefined",
	[3209]="Azralon,PvE,ptBR,US,undefined",
	[3210]="Tol Barad,PvE,ptBR,US,undefined",
	[3234]="Gallywix,PvE,ptBR,US,undefined",
	[3391]="Cerchio del Sangue,PvE,enUS,EU",
	[3656]="Internal Record 3656,PvE,enUS,EU",
	[3657]="Internal Record 3657,PvE,enUS,EU",
	[3661]="Internal Record 3661,PvE,enUS,US",
	[3666]="Internal Record 3666,PvE,enUS,EU",
	[3674]="Internal Record 3674,PvE,enUS,EU",
	[3675]="Internal Record 3675,PvE,enUS,US",
	[3676]="Internal Record 3676,PvE,enUS,US",
	[3678]="Ambossar,PvE,enUS,US,EST",
	[3679]="Internal Record 3679,PvE,deDE,EU",
	[3681]="Internal Record 3681,PvE,enUS,EU",
	[3682]="Internal Record 3682,PvE,enUS,EU",
	[3683]="Internal Record 3683,PvE,enUS,US",
	[3684]="Internal Record 3684,PvE,enUS,US",
	[3685]="Internal Record 3685,PvE,enUS,US",
	[3686]="Internal Record 3686,PvE,enUS,EU",
	[3690]="Internal Record 3690,PvE,enUS,EU",
	[3691]="Internal Record 3691,PvE,enUS,EU",
	[3692]="Internal Record 3692,PvE,enUS,EU",
	[3693]="Internal Record 3693,PvE,enUS,US",
	[3694]="Internal Record 3694,PvE,enUS,US",
	[3696]="Internal Record 3696,PvE,enUS,EU",
	[3702]="Internal Record 3702,PvE,enUS,EU",
	[3703]="Internal Record 3703,PvE,enUS,EU",
	[3713]="Internal Record 3713,PvE,enUS,EU",
	[3721]="Caelestrasz,PvE,enUS,US,AEST",
	[3722]="Aman'Thul,PvE,enUS,US,AEST",
	[3723]="Barthilas,PvE,enUS,US,AEST",
	[3724]="Thaurissan,PvE,enUS,US,AEST",
	[3725]="Frostmourne,PvE,enUS,US,AEST",
	[3726]="Khaz'goroth,PvE,enUS,US,AEST",
	[3733]="Dreadmaul,PvE,enUS,US,AEST",
	[3734]="Nagrand,PvE,enUS,US,AEST",
	[3735]="Dath'Remar,PvE,enUS,US,AEST",
	[3736]="Jubei'Thos,PvE,enUS,US,AEST",
	[3737]="Gundrak,PvE,enUS,US,AEST",
	[3738]="Saurfang,PvE,enUS,US,AEST",
	[4376]="Azuresong,PvE,enUS,US,PST",
	[4372]="Atiesh,PvE,enUS,US,PST",
	[4373]="Mzrael,PvE,enUS,US,PST",
	[4374]="Old Blanchy,PvE,enUS,US,PST",
	[4376]="Azuresong,PvE,enUS,US,PST",
	[4384]="Mankrik,PvE,enUS,US,EST",
	[4385]="Pagle,PvE,enUS,US,EST",
	[4386]="Deviate Delight,PvP RP,enUS,US,EST",
	[4387]="Thunderfury,PvE,enUS,US,EST",
	[4388]="Westfall,PvE,enUS,US,EST",
	[4395]="Whitemane,PvP,enUS,US,PST",
	[4396]="Fairbanks,PvP,enUS,US,PST",
	[4397]="Blaumeux,PvP,enUS,US,PST",
	[4398]="Bigglesworth,PvP,enUS,US,PST",
	[4399]="Kurinaxx,PvP,enUS,US,PST",
	[4406]="Herod,PvP,enUS,US,EST",
	[4407]="Thalnos,PvP,enUS,US,EST",
	[4408]="Faerlina,PvP,enUS,US,EST",
	[4409]="Stalegg,PvP,enUS,US,EST",
	[4410]="Skeram,PvP,enUS,US,EST",
	[4417]="소금 평원,PvE,koKR,KR,Shimmering Flats",
	[4419]="로크홀라,PvP,koKR,KR,Lokholar",
	[4420]="얼음피,PvP,koKR,KR,Iceblood",
	[4421]="라그나로스,PvP,koKR,KR,Ragnaros",
	[4440]="Everlook,PvE,deDE,EU",
	[4441]="Auberdine,PvE,frFR,EU",
	[4442]="Lakeshire,PvE,deDE,EU",
	[4453]="Pyrewood Village,PvE,enUS,EU",
	[4455]="Razorfen,PvE,deDE,EU",
	[4456]="Nethergarde Keep,PvE,enUS,EU",
	[4458]="Mirage Raceway,PvE,enUS,EU",
	[4463]="Heartstriker,PvP,deDE,EU",
	[4464]="Sulfuron,PvP,frFR,EU",
	[4465]="Golemagg,PvP,enUS,EU",
	[4466]="Patchwerk,PvP,deDE,EU",
	[4467]="Firemaw,PvP,enUS,EU",
	[4475]="Shazzrah,PvP,enUS,EU",
	[4476]="Gehennas,PvP,enUS,EU",
	[4477]="Venoxis,PvP,deDE,EU",
	[4478]="Razorgore,PvP,enUS,EU",
	[4485]="瑪拉頓,PvE,zhTW,TW,Maraudon",
	[4487]="伊弗斯,PvP,zhTW,TW,Ivus",
	[4647]="Grobbulus,PvP RP,enUS,US,PST",
	[4648]="Bloodsail Buccaneers,RP,enUS,US,EST",
	[4667]="Remulos,PvE,enUS,US,AEST",
	[4669]="Arugal,PvP,enUS,US,AEST",
	[4670]="Yojamba,PvP,enUS,US,AEST",
	[4676]="Zandalar Tribe,PvP RP,enUS,EU",
	[4678]="Hydraxian Waterlords,RP,enUS,EU",
	[4695]="Rattlegore,PvP,enUS,US,PST",
	[4696]="Smolderweb,PvP,enUS,US,PST",
	[4698]="Incendius,PvP,enUS,US,EST",
	[4699]="Kromcrush,PvP,enUS,US,EST",
	[4700]="Kirtonos,PvP,enUS,US,EST",
	[4701]="Mograine,PvP,enUS,EU",
	[4702]="Gandling,PvP,enUS,EU",
	[4703]="Amnennar,PvP,frFR,EU",
	[4705]="Stonespire,PvP,enUS,EU",
	[4706]="Flamelash,PvP,enUS,EU",
	[4714]="Thunderfury,PvP,enUS,US,PST",
	[4715]="Anathema,PvP,enUS,US,PST",
	[4716]="Arcanite Reaper,PvP,enUS,US,PST",
	[4726]="Sulfuras,PvP,enUS,US,EST",
	[4727]="Windseeker,PvE,enUS,US,EST",
	[4728]="Benediction,PvP,enUS,US,EST",
	[4729]="Netherwind,PvP,enUS,US,EST",
	[4731]="Earthfury,PvP,enUS,US,EST",
	[4732]="Heartseeker,PvP,enUS,US,EST",
	[4737]="Sul'thraze,PvP,ptBR,US,BRT",
	[4739]="Felstriker,PvP,enUS,US,AEST",
	[4741]="Noggenfogger,PvP,enUS,EU",
	[4742]="Ashbringer,PvP,enUS,EU",
	[4743]="Skullflame,PvP,enUS,EU",
	[4744]="Finkle,PvP,frFR,EU",
	[4745]="Transcendence,PvP,deDE,EU",
	[4746]="Bloodfang,PvP,enUS,EU",
	[4749]="Earthshaker,PvP,enUS,EU",
	[4751]="Dragonfang,PvP,enUS,EU",
	[4755]="Dreadmist,PvP,enUS,EU",
	[4756]="Dragon's Call,PvP,deDE,EU",
	[4757]="Ten Storms,PvP,enUS,EU",
	[4758]="Judgement,PvP,enUS,EU",
	[4759]="Celebras,RP,deDE,EU",
	[4763]="Heartstriker,PvP,deDE,EU",
}
	
local ConnectionData = {
	-- Americas and Oceania
	"1136,83,109,1373,129,1142",                     -- Aegwynn, Bonechewer, Daggerspine, Garrosh, Gurubashi, Hakkar
	"1129,56,102,1291,1559,98,1262,1564,105",        -- Agamaggan, Archimonde, Burning Legion, Jaedenar, The Underbog, Kargath, Norgannon, Blade’s Edge, Thunderhorn
	"106,1576",                                      -- Aggramar, Fizzcrank
	"1070,1563",                                     -- Alexstrasza, Terokkar
	"52,65,62,1565",                                 -- Alleria, Khadgar, Medivh, Exodar
	"75,1570",                                       -- Argent Dawn, The Scryers
	"1276,1267,156,1259,96,1567,1280,1068,74",       -- Andorhal, Scilla, Ursin, Zuluhed, Eonar, Velen, Black Dragonflight, Gul’dan, Skullcrusher
	"77,1128,79,103,1558,70,1131",                   -- Azgalor, Azshara, Destromath, Thunderlord, Blood Furnace, Mannoroth, Nazjatar
	"121,10,1143,1182,1359",                         -- Azjol-Nerub, Blackrock, Khaz Modan, Muradin, Nordrassil
	"1190,13,4376",                                  -- Baelgun, Doomhammer, Azuresong
	"54,1581",                                       -- Blackhand, Galakrond
	"64,1258",                                       -- Bloodhoof, Duskwood (Bloodrazor?)
	"119,112,111,1357,108,1185,1372",                -- Bloodscalp, Boulderfist, Dunemaul, Maiev, Stonemaul, Sen’jin, Quel’dorei
	"117,1364",                                      -- Bronzebeard, Shandris
	"91,95,1285,51,14,104",                          -- Burning Blade, Lightning’s Blade, Onyxia, Garona, Icecrown, Malygos
	"3721,3734,3738",                                -- Caelestrasz, Nagrand, Saurfang
	"1361,122,2,1146,128,8,1360,1168",               -- Cairne, Perenolde, Cenarius, Korgath, Frostmane, Ner’zhul, Tortheldrin, Blackmoore
	"1346,1138,107,1141,89,130,1165,1377",           -- Anub’arak, Chromaggus, Crushridge, Garithos, Nathrezim, Smolderthorn, Arathor, Drenden
	"1556,1278,157,1286,72",                         -- Coilfang, Dalvengyr, Dark Iron, Demon Soul, Shattered Hand
	"1296,81,154,1266,1295,94",                      -- Blackwing Lair, Dethecus, Detheroc, Haomarush, Lethon, Shadowmoon
	"1351,1139,113,87",                              -- Darrowmere, Draka, Suramar, Windrunner
	"115,1342",                                      -- Draenor, Echo Isles
	"114,1345",                                      -- Dragonblight, Fenris
	"1140,131,86,1374,1371,85,1368,90",              -- Drak’Thul, Skywall, Silvermoon, Mok’Nathal, Borean Tundra, Shadowsong, Hydraxis, Terenas
	"1137,84,123,1349,1145,1363,116",                -- Akama, Dragonmaw, Eldre’Thalas, Korialstrasz, Mug’thol, Antonidas, Uldum
	"63,1270",                                       -- Durotan, Ysera
	"47,1354",                                       -- Eitrigg, Shu’halo
	"93,92,82,159,53,1572",                          -- Eredar, Gorefiend, Spinebreaker, Wildhammer, Hellscream, Zangarmarsh
	"67,97,101,1555,1067",                           -- Elune, Gilneas, Laughing Skull, Auchindoun, Cho’gall
	"118,126",                                       -- Feathermoon, Scarlet Crusade
	"7,1348,1362,127,1148,1358,124,110",             -- Frostwolf, Vashj, Drak’Tharon, Firetree, Malorne, Rivendare, Spirestone, Stormscale
	"158,1292",                                      -- Greymane, Tanaris
	"3737,3736,3725,3733,3724",                      -- Gundrak, Jubei’Thos, Frostmourne, Dreadmaul, Thaurissan
	"15,1277,155,1557",                              -- Deathwing, Executus, Kalecgos, Shattered Halls
	"3735,3726",                                     -- Dath’Remar, Khaz’goroth
	"4,1355",                                        -- Kilrogg, Winterhoof
	"1071,1290,1260",                                -- Kirin Tor, Sentinels, Steamwheedle Cartel
	"1147,1353",                                     -- Kul Tiras, Bladefist
	"99,1297",                                       -- Llane, Arygos
	"1130,1352,164,163",                             -- Lightninghoof, Ravenholdt, Twisting Nether, Maelstrom (Venture Company?)
	"1578,1069,1579,1287,153,1175,68,1132",          -- Ghostlands, Kael’thas, Grizzly Hills, Gnomeregan, Moonrunner, Trollbane, Lothar, Malfurion
	"1282,1264,78,1268",                             -- Altar of Storms, Anetheron, Magtheridon, Ysondre
	"3208,3210",                                     -- Nemesis, Tol Barad
	"1072,1283",                                     -- Ravencrest, Uldaman
	"1350,1151",                                     -- Misha, Rexxar
	"151,3",                                         -- Runetotem, Uther
	"1347,88,1356,125",                              -- Blackwater Raiders, Cenarion Circle, Sisters of Elune, Shadow Council
	"1370,12,1154",                                  -- Farstriders, Silver Hand, Thorium Brotherhood
	"1549,160,1582,1173",                            -- Azuremyst, Staghelm, Dawnbringer, Madoran
	"1369,1171",                                     -- Wyrmrest Accord, Theradras
	"1284,1426",                                     -- Aerie Peak, Ulduar
	"1367,1375,1184",                                -- Nazgrel, Nesingwary, Vek’nilash
	"1293,1075,80,1344,71,1288,1294,1174",           -- Alterac Mountains, Balnazzar, Gorgonnash, The Forgotten Coast, Warsong, Anvilmar, Undermine, Xavius
	"1271,55",                                       -- Dentarg, Whisperwind
	"1566,3676",                                     -- Area 52, Internal Record 3676
	"6,3661",                                        -- Hyjal, Internal Record 3661
	"1365,3675",                                     -- Moon Guard, Internal Record 3675
	"66,3683",                                       -- Dalaran, Internal Record 3683
	"59,3684",                                       -- Mal'Ganis, Internal Record 3684
	"1265,3685",                                     -- Turalyon, Internal Record 3685
	"16,3693",                                       -- Kel'Thuzad, Internal Record 3693
	"1,3694",                                        -- Lightbringer, Internal Record 3694
	"1263,3678",                                     -- Thrall, Ambossar
	-- Europe
	"1312,1081,1416,1310,1298",                      -- Aerie Peak, Bronzebeard, Blade’s Edge, Eonar, Vek’nilash
	"518,522,525,1091,646,513",                      -- Agamaggan, Bloodscalp, Crushridge, Emeriss, Hakkar, Twilight’s Hammer
	"1413,1303,1300",                                -- Aggra (Português), Grim Batol, Frostmane
	"500,619,1325",                                  -- Aggramar, Hellscream, Grizzlyhügel
	"1093,607,1299,1083,526,621,1598,511,1090,1088", -- Ahn’Qiraj, Balnazzar, Boulderfist, Chromaggus, Daggerspine, Laughing Skull, Shattered Halls, Sunstrider, Talnivarr, Trollbane
	"519,524,557,639,3713",                          -- Al’Akir, Burning Legion, Skullcrusher, Xavius, Internal Record 3713
	"562,1607,571,593,3696",                         -- Alexstrasza, Nethersturm, Madmortem, Proudmoore, Internal Record 3696
	"563,1099",                                      -- Alleria, Rexxar
	"1391,1394,1082",                                -- Alonsus, Anachronos, Kul Tiras
	"601,1105,569",                                  -- Aman’Thul, Nazjatar, Khaz’Goroth
	"568,604",                                       -- Ambossar, Kargath, Thrall
	"1104,1611,587,589,594,1322",                    -- Anetheron, Festung der Stürme, Gul’dan, Kil’jaeden, Nathrezim, Rajaxx
	"608,1321,584,573",                              -- Anub’arak, Dalvengyr, Frostmourne, Zuluhed
	"512,543,642,643",                               -- Arak-arahm, Kael’thas, Rashgarroth, Throk’Feroth
	"1334,541,1624,1622",                            -- Arathi, Illidan, Naxxramas, Temple noir
	"501,1587,1311,1589,547",                        -- Arathor, Hellfire, Kilrogg, Nagrand, Runetotem
	"539,1302",                                      -- Archimonde, Stonemaul
	"1404,602,1400",                                 -- Area 52, Sen’jin, Un’Goro
	"578,1613,535,588,1328,1318,609",                -- Arthas, Blutkessel, Durotan, Kel’Thuzad, Tirion, Vek’lor, Wrathbringer
	"1406,569",                                      -- Arygos, Khaz’goroth
	"502,548,3666",                                  -- Aszune, Shadowsong, Internal Record 3666
	"1597,529,1304,628",                             -- Auchindoun, Dunemaul, Jaedenar, Sylvanas
	"503,623,1396",                                  -- Azjol-Nerub, Quel’Thalas, Molten Core
	"579,616,565,570",                               -- Azshara, Krag’jin, Baelgun, Lothar
	"1417,550",                                      -- Azuremyst, Stormrage
	"580,1409,1106",                                 -- Blackmoore, Lordaeron, Tichondrius
	"521,632,515,631,606,624,3657",                  -- Bladefist, Frostwhisper, Zenedar, Darksorrow, Genjuros, Neptulon, Internal Record 3657
	"630,1392,1389,1087,633,1314,556,1415",          -- Bloodfeather, Burning Steppes, Darkspear, Executus, Kor’gall, Saurfang, Shattered Hand, Terokkar
	"504,1080",                                      -- Bloodhoof, Khadgar
	"1393,618",                                      -- Bronze Dragonflight, Nordrassil
	"523,1092",                                      -- Burning Blade, Drak’thul
	"1381,1378",                                     -- C’Thun, Dun Modr
	"540,645,1315",                                  -- Elune, Varimathras, Caduta dei Draghi
	"1620,510",                                      -- Chants éternels, Vol’jin
	"545,1336,533,538,1621",                         -- Cho’gall, Eldre’Thalas, Sinstralis, Dalaran, Marécage de Zangar
	"1395,1387,1384",                                -- Colinas Pardas, Los Errantes, Tyrande
	"1127,1626,647,537,644,1337,1086",               -- Confrérie du Thorium, Les Clairvoyants, Les Sentinelles, Kirin Tor, Conseil des Ombres, Culte de la Rive noire, La Croisade écarlate
	"1619,614,1326,1121,1119,613,1118,576",          -- Das Konsortium, Das Syndikat, Der abyssische Rat, Die Arguswacht, Die Todeskrallen, Kult der Verdammten, Die ewige Wacht, Die Silberne Hand
	"527,507,1588,1596,637,627",                     -- Deathwing, Dragonblight, Ghostlands, Karazhan, Lightning’s Blade, The Maelstrom
	"1317,635,561,1308,1096,1606,636",               -- Darkmoon Faire, Defias Brotherhood, Earthen Ring, Ravenholdt, Scarshield Legion, Sporeggar, The Venture Co
	"1084,1306",                                     -- Dentarg, Tarren Mill
	"582,586,591,612,611",                           -- Destromath, Gorgonnash, Mannoroth, Nefarian, Nera’thor
	"531,1319,610,615,605",                          -- Dethecus, Mug’thol, Onyxia, Terrordar, Theradras
	"1333,516,1405,592,1327,617",                    -- Die Nachtwache, Forscherliga, Todeswache, Zirkel des Cenarius, Der Mithrilorden, Der Rat von Dalaran
	"505,553,1402",                                  -- Doomhammer, Turalyon, Menethil
	"528,638,558,559,629,3656",                      -- Dragonmaw, Haomarush, Spinebreaker, Stormreaver, Vashj, Internal Record 3656
	"641,1122,1123,1332",                            -- Drek’Thar, Uldaman, Eitrigg, Krasus
	"600,1408",                                      -- Dun Morogh, Norgannon
	"1612,590,1320,566,3691",                        -- Echsenkessel, Mal’Ganis, Taerar, Blackhand, Internanl Record 3691
	"508,551,2074",                                  -- Emerald Dream, Terenas, Schwarznarbe
	"1385,1386",                                     -- Exodar, Minahonda
	"509,544,546",                                   -- Garona, Ner’zhul, Sargeras
	"1401,574,575,1608,1407",                        -- Garrosh, Nozdormu, Perenolde, Shattrath, Teldrassil
	"567,612",                                       -- Gilneas, Nefarian
	"1388,1089",                                     -- Lightbringer, Mazrigos
	"572,1098",                                      -- Malfurion, Malygos
	"1324,1097",                                     -- Malorne, Ysera
	"517,1331",                                      -- Medivh, Suramar
	"1085,1117,1595",                                -- Moonglade, Steamwheedle Cartel, The Sha’tar
	"554,1329",                                      -- Ravencrest, Muradin
	"1382,1383,1380,1379",                           -- Sanguino, Shen’dralar, Uldum, Zul’jin
	"560,2073",                                      -- Stormscale, Winterhuf
	"552,1313",                                      -- Thunderhorn, Wildhammer
	"542,1390",                                      -- Hyjal, Internal Record 1390
	"506,1403",                                      -- Draenor, Gnomeragan
	"549,3391",                                      -- Silvermoon, Cerchio del Sangue
	"625,3674",                                      -- Twisting Nether, Internal Record 3674
	"577,3679",                                      -- Aegwynn, Internal Record 3679
	"622,3681",                                      -- Magtheridon, Internal Record 3681
	"626,3682",                                      -- Ragnaros, Internal Record 3682
	"564,3686",                                      -- Antonidas, Internal Record 3686
	"640,3690",                                      -- Khaz Modan, Internal Record 3690
	"583,3692",                                      -- Eredar, Internal Record 3692
	"536,3702",                                      -- Argent Dawn, Internal Record 3702
	"585,3703",                                      -- Frostwolf, Internal Record 3703
}
--#endregion

RealmCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function RealmCollection:new()
	local object = RealmCollection.parent.new(self)
	object.__name = 'RealmCollection'
	object.realmsByID = nil
	object.cacheXref = nil
    return object
end
--#endregion

--#region Initializers
-- Realm information comes from disk, so no need to stick in cache
function RealmCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.realmsByID = {}
		self.cacheXref = {}
		-- Setup all realms in the region
		for id, data in pairs(RealmData) do
			local realmData = string.Split(data, ',')
			if(XFG.Regions:GetCurrent():GetName() == realmData[4]) then
				local realm = Realm:new(); realm:Initialize()
				realm:SetKey(realmData[1])
				realm:SetName(realmData[1])
				realm:SetID(tonumber(id))
				self:Add(realm)
				
				if(realm:GetName() == GetRealmName()) then
					XFG.Player.Realm = realm
					XFG:Info(ObjectName, 'Initialized player realm [%d:%s]', realm:GetID(), realm:GetName())
				else
					XFG:Trace(ObjectName, 'Initialized realm [%d:%s]', realm:GetID(), realm:GetName())
				end
			end
		end

		-- Sanity check
		if(XFG.Player.Realm == nil) then
			error(format('Unable to identify player realm'))
		end

		-- Setup default realms (Torghast)
		for realmID, realmName in pairs (XFG.Settings.Confederate.DefaultRealms) do
			local realm = Realm:new(); realm:Initialize()
			realm:SetKey(realmName)
			realm:SetName(realmName)
			realm:SetID(realmID)
			self:Add(realm)
		end

		-- Identify connected realms
		for _, connections in ipairs (ConnectionData) do
			local realms = string.Split(connections, ',')
			for _, id1 in ipairs (realms) do
				local realm1 = self:GetByID(tonumber(id1))
				if(realm1 ~= nil) then
					for _, id2 in ipairs (realms) do
						local realm2 = self:GetByID(tonumber(id2))
						if(realm2 ~= nil and not realm1:Equals(realm2)) then
							realm1:AddConnected(realm2)
							realm2:AddConnected(realm1)
							XFG:Trace(ObjectName, 'Initialized realm connection [%d:%d]', realm1:GetID(), realm2:GetID())
						end
					end
				end
			end
		end		

		XFG.Events:Add('Setup Realms', XFG.Settings.Network.Message.IPC.CACHE_LOADED, XFG.SetupRealms, true, true)
		XFG.Lib.Event:SendMessage(XFG.Settings.Network.Message.IPC.REALMS_LOADED)
		XFG.Player.Realm:Print()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Hash
function RealmCollection:Add(inRealm)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
	self.realmsByID[inRealm:GetID()] = inRealm
	self.parent.Add(self, inRealm)
end

function RealmCollection:GetByID(inID)
	assert(type(inID) == 'number')
	return self.realmsByID[inID]
end
--#endregion