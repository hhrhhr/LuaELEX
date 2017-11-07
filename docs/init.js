////////////////////////////////////////////////////////////////////////////////

var src_icon = [];
src_icon[0] = [ "zone", "images/exclamation-red.png" ];
src_icon[1] = [ "teleport", "images/teleport.png" ];
src_icon[2] = [ "amulet", "images/ring.png" ];
src_icon[3] = [ "audio", "images/audio.png" ];
src_icon[4] = [ "picture", "images/picture.png" ];
src_icon[5] = [ "recipe", "images/recipe.png" ];
src_icon[6] = [ "socket", "images/socket.png" ];
src_icon[7] = [ "sunglass", "images/binocular.png" ];
src_icon[8] = [ "book", "images/book.png" ];
src_icon[9] = [ "letter", "images/letter.png" ];
src_icon[10] = [ "street", "images/road.png" ];
src_icon[11] = [ "orevein", "images/empty.png" ];
src_icon[12] = [ "empty", "images/empty.png"];
src_icon[13] = [ "elex", "images/elex.png" ];
src_icon[14] = [ "iron", "images/iron.png" ];
src_icon[15] = [ "gold", "images/gold.png" ];
src_icon[16] = [ "sulfur", "images/sulfur.png" ];

var src_layer = [
[ src_icon[0][0], "<img src='" + src_icon[0][1] + "' />" ],
[ src_icon[1][0], "<img src='" + src_icon[1][1] + "' />" ],
[ src_icon[2][0], "<img src='" + src_icon[2][1] + "' />" ],
[ src_icon[3][0], "<img src='" + src_icon[3][1] + "' />" ],
[ src_icon[4][0], "<img src='" + src_icon[4][1] + "' />" ],
[ src_icon[5][0], "<img src='" + src_icon[5][1] + "' />" ],
[ src_icon[6][0], "<img src='" + src_icon[6][1] + "' />" ],
[ src_icon[7][0], "<img src='" + src_icon[7][1] + "' />" ],
[ src_icon[8][0], "<img src='" + src_icon[8][1] + "' />" ],
[ src_icon[9][0], "<img src='" + src_icon[9][1] + "' />" ],
[ src_icon[10][0], "<img src='" + src_icon[10][1] + "' />" ],
[ src_icon[11][0], "<img src='" + src_icon[11][1] + "' />" ]
];

////////////////////////////////////////////////////////////////////////////////

var leaf_icon = L.Icon.extend({
    options: { iconSize: [16, 16], iconAnchor: [8, 8], popupAnchor: [0, 0] }
});

var icon = {}
for (var i = 0; i < src_icon.length; i++) {
    icon[src_icon[i][0]] = new leaf_icon( { iconUrl: src_icon[i][1] } );
};

var layer = {}
var overlays = {}
function init_overlay() {
    for (var i = 0; i < src_layer.length; i++) {
        var s = src_layer[i];
        layer[s[0]] = new L.LayerGroup();
        var str = s[1];
        if (s[2])
            str += "&nbsp;" + lang[s[2]];
        else
            str += s[0].toUpperCase();
        overlays[str] = layer[s[0]];
    };
};

var init_marker = [];
function add_markers() {
    for (var i = 0; i < init_marker.length; i++) {
        init_marker[i]();
    };
};


////////////////////////////////////////////////////////////////////////////////

function _GET(key) {
	var s = window.location.search;
	s = s.match(new RegExp(key + '=([^&=]+)'));
	return s ? s[1] : false;
};

var LANG = "ru";
var g = _GET("l");
if ("en" === g)
    LANG = "en";
else if ("de" === g)
    LANG = "de";
g = _GET("f");


var has_WebP = false;
(function () {
  var p = new Image();
  p.onload = function() {
    has_WebP = !!(p.height > 0 && p.width > 0);
  };
  p.onerror = function() {
    has_WebP = false;
  };
  p.src = '404.webp';
})();


function _ADD(src) {
    var js = document.createElement("script");
    js.src = src;
    js.async = false;
    document.body.appendChild(js);
};

_ADD("lang_" + LANG + ".js");
_ADD("danger_zone.js");
_ADD("street.js");
_ADD("teleport.js");
_ADD("items.js");
_ADD("orevein.js")
_ADD("elex_map.js");

lang = null;

