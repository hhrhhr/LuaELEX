//// config

var tileRes = 512;
var terrainSize = 8192;

var terrainCorners = 
    [[-(terrainSize * 0.5) - tileRes, -(terrainSize * 0.5) - tileRes],
    [terrainSize * 0.25  + tileRes, terrainSize * 0.25 + tileRes]];

var a = tileRes / terrainSize;
var b = tileRes / 2;
L.CRS.Map = L.extend({}, L.CRS.Simple, {
    transformation: new L.Transformation(a, b, -a, b),
});


//// base maps

var layerBaseWebP = L.tileLayer("", {
    minNativeZoom: 0,
    maxNativeZoom: 3,
    errorTileUrl: "404.webp",
    tileSize: tileRes,
    noWrap: true,
    continuousWorld: true,
});
layerBaseWebP.setUrl("map_512/elex-{z}-{y}-{x}.webp")

var layerBaseJPG = L.tileLayer("", {
    minNativeZoom: 0,
    maxNativeZoom: 3,
    errorTileUrl: "404.jpg",
    tileSize: tileRes,
    noWrap: true,
    continuousWorld: true,
});
layerBaseJPG.setUrl("map_512/elex-{z}-{y}-{x}.jpg")

var baseMaps = { "WebP (modern browser)": layerBaseWebP, "JPG (old browser)": layerBaseJPG };


//// overlays

init_overlay();
add_markers();


//// init

var enabled_layers = [ has_WebP ? layerBaseWebP : layerBaseJPG, layer["teleport"] ];

var elexMap = L.map('mapid', {
    crs: L.CRS.Map,
    minZoom: 0,
    maxZoom: 7,
    layers: enabled_layers,
    maxBounds: terrainCorners,
    attributionControl: false,
    //zoomSnap: 0.5,
    //zoomDelta: 0.5,
});

elexMap.fitBounds(terrainCorners);

var hash = new L.Hash(elexMap);

L.control.layers(baseMaps, overlays, {}).addTo(elexMap);
L.control.scale({maxWidth: 400, updateWhenIdle: true}).addTo(elexMap);


//// attribution

var url1 = "<a href='elex_map.html?l=de' title='Deutsch'>[DE]</a>";
var url2 = "<a href='elex_map.html?l=en' title='English'>[EN]</a>";
var url3 = "<a href='elex_map.html' title='Русский'>[RU]</a>";
var url4 = "<a href='https://github.com/hhrhhr/LuaELEX' title='source on Github'>[map source]</a>"; 
L.control.attribution()
.addAttribution(url1)
.addAttribution(url2)
.addAttribution(url3)
.addAttribution(url4)
.addTo(elexMap);
