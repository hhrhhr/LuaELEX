var arr = [
[ -196259.625, 40234.38671875, 31708.568359375, "MapMarker_Location_TAV_Fort", "Форт" ],
[ -155198.21875, 29806.705078125, 29256.07421875, "MapMarker_Location_TAV_DomeRuins", "Руины купола" ],
[ -228052.921875, 10861.32421875, 28500.705078125, "MapMarker_Location_TAV_WindPark", "Старые ветряки" ],
[ -243922.640625, 47177.390625, 28523.1328125, "MapMarker_Location_TAV_SouthCliffs", "Южные скалы" ],
[ -169421.484375, -31118.638671875, 28742.17578125, "MapMarker_Location_TAV_Converter", "Преобразователь в Таваре" ],
[ -120468.0546875, -58465.63671875, 39306.39453125, "MapMarker_Location_TAV_TavarMountain", "Таварские горы" ],
[ -206926.515625, -156211.890625, 28683.14453125, "MapMarker_Location_EDA_FirstBase", "Маленький лагерь" ],
[ -218261.34375, -133308.34375, 34146.19921875, "MapMarker_Location_EDA_Goliet", "Голиет" ],
[ -183055.8125, -162907.5625, 28579.8125, "MapMarker_Location_EDA_Converter", "Преобразователь в Эдане" ],
[ -238521.875, -113725.4375, 41812.875, "MapMarker_Location_EDA_HotelGoliet", "Руины отеля в Голиете" ],
[ -236145.640625, -173125.5625, 28271.361328125, "MapMarker_Location_EDA_WoodElevator", "Лифт" ],
[ -279004.65625, -222072.71875, 20913.4140625, "MapMarker_Location_EDA_PilgerLocation", "Позабытые скалы" ],
[ -241704.734375, -231423.15625, 24155.4765625, "MapMarker_Location_EDA_CompanyPlace", "Территория компании: западный Эдан" ],
[ -270851.71875, -131106.328125, 28330.611328125, "MapMarker_Location_EDA_RiverDelta", "Дельта реки" ],
[ -102076.2890625, -128870.9375, 50983.9140625, "MapMarker_Location_HOM_HomeBase", "Лагерь в центре" ],
[ -216042.8125, -58350.6796875, 41305.890625, "MapMarker_Location_EDA_MountainLake", "Горное озеро" ],
[ -84269.6328125, -179600.546875, 42254.0390625, "MapMarker_Location_ABE_Relict", "Купольный город" ],
[ -30914.361328125, -133614.3125, 47093.35546875, "MapMarker_Location_ABE_ConverterNorth", "Преобразователь в северной Абессе" ],
[ -60958.76171875, -84607.1015625, 46319.35546875, "MapMarker_Location_ABE_ConverterSouth", "Преобразователь в южной Абессе" ],
[ -36157.61328125, -53677.96875, 50177.60546875, "MapMarker_Location_ABE_Barrage", "Дамба" ],
[ -29914.765625, 95499.375, 49265.26171875, "MapMarker_Location_IGN_Crater", "Кратер" ],
[ 28200.494140625, 117075.078125, 51546.328125, "MapMarker_Location_IGN_Hort", "Хорт" ],
[ 49601.96875, -5547.6625976562, 54155.67578125, "MapMarker_Location_IGN_Converter", "Преобразователь в Игнадоне" ],
[ -85813.7890625, 112325.859375, 47182.23828125, "MapMarker_Location_IGN_LavaLake", "Лавовое озеро" ],
[ -11880.717773438, 52323.4765625, 52657.80859375, "MapMarker_Location_IGN_Vulcano", "Территория компании: вулкан" ],
[ 52299.5625, 84911.2734375, 55023.75390625, "MapMarker_Location_IGN_Hangar", "Ангар" ],
[ 13569.336914062, -122579.484375, 55579.2421875, "MapMarker_Location_XAC_EntranceSouth", "Южный перевал" ],
[ 73755.5, -75057.671875, 59190.5546875, "MapMarker_Location_XAC_EntranceEast", "Снежный перевал" ],
[ 61903.53515625, -125142.875, 58674.1484375, "MapMarker_Location_XAC_ConverterEast", "Преобразователь в восточном Ксакоре" ],
[ 22045.041015625, -141843.4375, 55415.44140625, "MapMarker_Location_XAC_ConverterWest", "Преобразователь в западном Ксакоре" ],
[ 81586.0, -161441.921875, 61225.2421875, "MapMarker_Location_XAC_Icepalace", "Ледяной дворец" ],
[ 11220.388671875, -62455.3828125, 56232.76171875, "MapMarker_Location_ABE_Zardom", "Территория компании: северная Абесса" ],
[ -54753.546875, 77432.8046875, 60519.64453125, "MapMarker_Location_IGN_ClericCamp", "Руины замка в западном Игнадоне" ],
[ 19096.904296875, 147144.78125, 52919.1875, "MapMarker_Location_IGN_Cathedral", "Собор" ],
[ -216081.234375, 48560.78125, 33762.3828125, "MapMarker_Location_TAV_Duke", "Бункер Герцога" ],
[ -307896.84375, -183125.484375, 18183.544921875, "MapMarker_Location_EDA_BSKIsland", "Остров берсерков" ],
[ -169285.328125, -94851.21875, 31356.322265625, "MapMarker_Location_TAV_SandyPines", "В трех соснах" ],
[ -222114.609375, -107411.859375, 40334.16796875, "MapMarker_Location_EDA_GolietNorth", "Кузнец" ],
[ -253455.359375, -205861.0625, 19090.564453125, "MapMarker_Location_EDA_ForbiddenValley", "Долина Проклятых." ],
[ -54772.625, 77488.1328125, 60130.8125, "Obj_Bld_Castle_Foundation_1", "---" ],
[ -59262.3203125, -157100.59375, 45232.6796875, "MapMarker_Location_ABE_CentralAbessa", "Территория компании: центральная Абесса" ],
[ -103128.5546875, -200294.734375, 37746.50390625, "MapMarker_Location_ABE_SmallFarm", "Маленькая ферма" ],
[ -246943.03125, -16894.05859375, 18991.9140625, "MapMarker_Location_TAV_OUTIsland", "Старая фабрика" ],
];
var arr_len = 43;

function add_teleport_markers() {
    for (var i = 0; i < arr_len; i++) {
        var m = arr[i];
        var pop = m[4] + "<br /><i>" + m[3] + "</i>";
        L.marker( [ m[0]*0.01, m[1]*0.01 ], { title: m[4], icon: teleport } ).bindPopup(pop).addTo(Teleport);
    };    
};

