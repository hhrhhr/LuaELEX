var arr_teleport = [
[ 399.335234375, -1959.5875, "MapMarker_Location_TAV_Fort", 0x136D46EF ],
[ 295.50126953125, -1549.41640625, "MapMarker_Location_TAV_DomeRuins", 0x31A1602A ],
[ 106.4290625, -2278.345, "MapMarker_Location_TAV_WindPark", 0xDDCFC874 ],
[ 469.2810546875, -2436.73359375, "MapMarker_Location_TAV_SouthCliffs", 0x4017D9BE ],
[ -313.71564453125, -1691.60828125, "MapMarker_Location_TAV_Converter", 0x30DA288C ],
[ -587.2224609375, -1202.114453125, "MapMarker_Location_TAV_TavarMountain", 0x4B0CAA9D ],
[ -1564.40546875, -2066.97859375, "MapMarker_Location_EDA_FirstBase", 0x2E61FD16 ],
[ -1336.0815625, -2179.5871875, "MapMarker_Location_EDA_Goliet", 0x659CD757 ],
[ -1631.784375, -1827.849375, "MapMarker_Location_EDA_Converter", 0x2C87D3CB ],
[ -1140.168046875, -2382.21640625, "MapMarker_Location_EDA_HotelGoliet", 0x13FF2D93 ],
[ -1734.2221875, -2358.46578125, "MapMarker_Location_EDA_WoodElevator", 0xDDE9AAEE ],
[ -2223.25390625, -2787.52, "MapMarker_Location_EDA_PilgerLocation", 0x9A754E8F ],
[ -2316.41171875, -2414.8671875, "MapMarker_Location_EDA_CompanyPlace", 0x8FD3FE6F ],
[ -1313.9828125, -2705.5978125, "MapMarker_Location_EDA_RiverDelta", 0xA1F46425 ],
[ -1291.636640625, -1017.835625, "MapMarker_Location_HOM_HomeBase", 0xACD16D51 ],
[ -586.539765625, -2157.3953125, "MapMarker_Location_EDA_MountainLake", 0x2B68481B ],
[ -1799.00265625, -839.69921875, "MapMarker_Location_ABE_Relict", 0x3674CDF4 ],
[ -1338.6884375, -306.59837890625, "MapMarker_Location_ABE_ConverterNorth", 0x7DB88F74 ],
[ -848.666796875, -606.9918359375, "MapMarker_Location_ABE_ConverterSouth", 0x7E1316BC ],
[ -539.7921484375, -358.563671875, "MapMarker_Location_ABE_Barrage", 0x2C879685 ],
[ 952.342890625, -296.496796875, "MapMarker_Location_IGN_Crater", 0xC9700BE8 ],
[ 1167.831328125, 284.9244140625, "MapMarker_Location_IGN_Hort", 0xA7CE6184 ],
[ -58.305307617188, 498.848359375, "MapMarker_Location_IGN_Converter", 0xC293463F ],
[ 1120.25953125, -855.138828125, "MapMarker_Location_IGN_LavaLake", 0x46FD3928 ],
[ 520.2908984375, -115.8633203125, "MapMarker_Location_IGN_Vulcano", 0xB5C12F1F ],
[ 846.525390625, 525.58296875, "MapMarker_Location_IGN_Hangar", 0xD3ED1F98 ],
[ -1228.644375, 138.54291015625, "MapMarker_Location_XAC_EntranceSouth", 0xF7347928 ],
[ -753.61515625, 740.5934375, "MapMarker_Location_XAC_EntranceEast", 0xB22077A2 ],
[ -1254.2171875, 621.779296875, "MapMarker_Location_XAC_ConverterEast", 0x18E6FF6A ],
[ -1421.26703125, 223.255703125, "MapMarker_Location_XAC_ConverterWest", 0x18F0EF40 ],
[ -1617.41984375, 818.860703125, "MapMarker_Location_XAC_Icepalace", 0x6D32723C ],
[ -627.52546875, 115.18771484375, "MapMarker_Location_ABE_Zardom", 0x48D8E77E ],
[ 771.489140625, -544.6966015625, "MapMarker_Location_IGN_ClericCamp", 0x3D891B7A ],
[ 1468.6125, 193.804296875, "MapMarker_Location_IGN_Cathedral", 0x84271F4F ],
[ 483.18859375, -2158.393125, "MapMarker_Location_TAV_Duke", 0x136C46BD ],
[ -1834.2771875, -3075.94625, "MapMarker_Location_EDA_BSKIsland", 0x64CAACEE ],
[ -950.90578125, -1690.4596875, "MapMarker_Location_TAV_SandyPines", 0xF2DEF0F2 ],
[ -1077.194765625, -2218.0696875, "MapMarker_Location_EDA_GolietNorth", 0x9F315F82 ],
[ -2061.5928125, -2531.5715625, "MapMarker_Location_EDA_ForbiddenValley", 0x501F5ACD ],
[ 771.4734375, -544.318359375, "Obj_Bld_Castle_Foundation_1", 0x7C9B47F5 ],
[ -1573.53875, -590.09046875, "MapMarker_Location_ABE_CentralAbessa", 0x102BC0A9 ],
[ -2005.09640625, -1029.136484375, "MapMarker_Location_ABE_SmallFarm", 0x124A4A10 ],
[ -171.15876953125, -2467.2121875, "MapMarker_Location_TAV_OUTIsland", 0xE0BE8B47 ],
];

function add_teleport_markers() {
    for (var i = 0; i < arr_teleport.length; i++) {
        var m = arr_teleport[i];
        var pop = lang[m[3]] + "<br /><i>" + m[2] + "</i>";
        L.marker( [ m[1], m[0] ], { title: lang[m[3]], icon: teleport } ).bindPopup(pop).addTo(Teleport);
    };
};
