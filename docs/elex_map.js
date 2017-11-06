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

var layer = L.tileLayer('', {
    minNativeZoom: 0,
    maxNativeZoom: 3,
    errorTileUrl: '404.' + TILE_FMT,
    tileSize: tileRes,
    noWrap: true,
    continuousWorld: true,
});
layer.setUrl('map_512/elex-{z}-{y}-{x}.' + TILE_FMT)

var Zone = new L.LayerGroup();
var Teleport = new L.LayerGroup();
var Amulet = new L.LayerGroup();
var Audio = new L.LayerGroup();
var Picture = new L.LayerGroup();
var Recipe = new L.LayerGroup();
var Socket = new L.LayerGroup();
var Sunglasses = new L.LayerGroup();
var Book = new L.LayerGroup();
var Letter = new L.LayerGroup();

var l = [ layer, Zone, Teleport, Amulet, Audio, Picture, Recipe, Socket, Sunglasses, Book, Letter ];

var overlay = {
    "<img src='images/exclamation-red.png' />Zone": Zone,
    "<img src='images/teleport.png' />Teleport": Teleport,
    "<img src='images/ring.png' />Amulet": Amulet,
    "<img src='images/audio.png' />Audio": Audio,
    "<img src='images/picture.png' />Picture": Picture,
    "<img src='images/recipe.png' />Recipe": Recipe,
    "<img src='images/socket.png' />Socket": Socket,
    "<img src='images/eye.png' />Sunglasses": Sunglasses,
    "<img src='images/book.png' />Book": Book,
    "<img src='images/letter.png' />Letter": Letter
};

var LeafIcon = L.Icon.extend({
    options: {
        iconSize:     [16, 16],
        iconAnchor:   [8, 8],
        popupAnchor:  [0, 0]
}});

var zone = new LeafIcon({iconUrl: 'images/exclamation-red.png'});
var teleport = new LeafIcon({iconUrl: 'images/teleport.png'});
var amulet = new LeafIcon({iconUrl: 'images/ring.png'});
var audio = new LeafIcon({iconUrl: 'images/audio.png'});
var picture = new LeafIcon({iconUrl: 'images/picture.png'});
var recipe = new LeafIcon({iconUrl: 'images/recipe.png'});
var socket = new LeafIcon({iconUrl: 'images/socket.png'});
var sun = new LeafIcon({iconUrl: 'images/eye.png'});
var book = new LeafIcon({iconUrl: 'images/book.png'});
var letter = new LeafIcon({iconUrl: 'images/letter.png'});

add_danger_zone_markers();
add_teleport_markers();
add_markers();

var mymap = L.map('mapid', {
    crs: L.CRS.Map,
    center: [-1024.0, -1024.0],
    zoom: 2,
    minZoom: 0,
    maxZoom: 7,
    layers: l,
    maxBounds: terrainCorners,
    attributionControl: false,
    //zoomSnap: 0.5,
    //zoomDelta: 0.5,
});

var hash = new L.Hash(mymap);

var baseMap = { "base": layer };

L.control.layers(baseMap, overlay, {hideSingleBase: true}).addTo(mymap);
L.control.scale({maxWidth: 400, updateWhenIdle: true}).addTo(mymap);

var url1 = "<a href='elex_map.html?l=de&f=webp' title='Deutsch'>[DE WebP]</a>"
var url2 = "<a href='elex_map.html?l=en&f=webp' title='English'>[EN WebP]</a>"
var url3 = "<a href='elex_map.html?l=ru&f=webp' title='Русский'>[RU WebP]</a>"
var url4 = "<a href='elex_map.html?l=de&f=jpg' title='Deutsch'>[DE JPEG]</a>"
var url5 = "<a href='elex_map.html?l=en&f=jpg' title='English'>[EN JPEG]</a>"
var url6 = "<a href='elex_map.html?l=ru&f=jpg' title='Русский'>[RU JPEG]</a>"
var url7 = "<a href='https://github.com/hhrhhr/LuaELEX' title='source on Github'>[map source]</a>" 
L.control.attribution()
.addAttribution(url1)
.addAttribution(url2)
.addAttribution(url3)
.addAttribution(url4)
.addAttribution(url5)
.addAttribution(url6)
.addAttribution(url7)
.addTo(mymap);
