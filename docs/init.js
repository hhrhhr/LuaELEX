function _GET(key) {
	var s = window.location.search;
	s = s.match(new RegExp(key + '=([^&=]+)'));
	return s ? s[1] : false;
};

var LANG = "ru";
var TILE_FMT = "webp";

var g = _GET("l");
if ("en" === g)
    LANG = "en";
else if ("de" === g)
    LANG = "de";

g = _GET("f");
if ("jpg" === g)
    TILE_FMT = "jpg";

_GET = null;

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
_ADD("elex_map.js");
