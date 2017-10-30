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
    errorTileUrl: '404.webp',
    tileSize: tileRes,
    noWrap: true,
    continuousWorld: true,
});
layer.setUrl('map_512/elex-{z}-{y}-{x}.webp')

var Teleport = new L.LayerGroup(),
    Amulet = new L.LayerGroup(),
    Audio = new L.LayerGroup(),
    Picture = new L.LayerGroup(),
    Recipe = new L.LayerGroup(),
    Socket = new L.LayerGroup(),
    Book = new L.LayerGroup();
    Letter = new L.LayerGroup();

var l = [ layer, Teleport, Amulet, Audio, Picture, Recipe, Socket, Book, Letter ];

var icons = {
    "<img src='images/teleport.png' />Teleport": Teleport,
    "<img src='images/ring.png' />Amulet": Amulet,
    "<img src='images/audio.png' />Audio": Audio,
    "<img src='images/picture.png' />Picture": Picture,
    "<img src='images/recipe.png' />Recipe": Recipe,
    "<img src='images/socket.png' />Socket": Socket,
    "<img src='images/book.png' />Book": Book,
    "<img src='images/letter.png' />Letter": Letter
};

var LeafIcon = L.Icon.extend({
    options: {
        iconSize:     [16, 16],
        iconAnchor:   [8, 8],
        popupAnchor:  [0, 0]
}});

var teleport = new LeafIcon({iconUrl: 'images/teleport.png'});
var amulet = new LeafIcon({iconUrl: 'images/ring.png'});
var audio = new LeafIcon({iconUrl: 'images/audio.png'});
var picture = new LeafIcon({iconUrl: 'images/picture.png'});
var recipe = new LeafIcon({iconUrl: 'images/recipe.png'});
var socket = new LeafIcon({iconUrl: 'images/socket.png'});
var book = new LeafIcon({iconUrl: 'images/book.png'});
var letter = new LeafIcon({iconUrl: 'images/letter.png'});

add_teleport_markers();
add_markers();

var mymap = L.map('mapid', {
    crs: L.CRS.Map,
    center: [0, 0],
    zoom: 1,
    minZoom: 0,
    maxZoom: 7,
    layers: l,
    maxBounds: terrainCorners,
    attributionControl: false,
    //zoomSnap: 0.5,
    //zoomDelta: 0.5,
});

var baseMap = { "base": layer };

L.control.layers(baseMap, icons, {hideSingleBase: true}).addTo(mymap);
L.control.scale({maxWidth: 400, updateWhenIdle: true}).addTo(mymap);

var url1 = "<a href='elex_map_DE.html' title='Deutsch'>[DE]</a>"
var url2 = "<a href='elex_map_EN.html' title='English'>[EN]</a>"
var url3 = "<a href='elex_map_RU.html' title='Русский'>[RU]</a>"
var url4 = "<a href='https://github.com/hhrhhr/LuaELEX' title='source on Github'>[map source]</a>" 
L.control.attribution()
.addAttribution(url1)
.addAttribution(url2)
.addAttribution(url3)
.addAttribution(url4)
.addTo(mymap);
