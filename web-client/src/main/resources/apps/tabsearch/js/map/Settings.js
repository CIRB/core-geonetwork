OpenLayers.DOTS_PER_INCH = 90.71;
//OpenLayers.ImgPath = '../js/OpenLayers/theme/default/img/';
OpenLayers.ImgPath = '../js/OpenLayers/img/';

OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;

// Define a constant with the base url to the MapFish web service.
//mapfish.SERVER_BASE_URL = '../../../../../'; // '../../';

// Remove pink background when a tile fails to load
OpenLayers.Util.onImageLoadErrorColor = "transparent";

// Lang
OpenLayers.Lang.setCode(GeoNetwork.defaultLocale);

OpenLayers.Util.onImageLoadError = function() {
	this._attempts = (this._attempts) ? (this._attempts + 1) : 1;
	if (this._attempts <= OpenLayers.IMAGE_RELOAD_ATTEMPTS) {
		this.src = this.src;
	} else {
		this.style.backgroundColor = OpenLayers.Util.onImageLoadErrorColor;
		this.style.display = "none";
	}
};

// add Proj4js.defs here
// Proj4js.defs["EPSG:27572"] = "+proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=0 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +towgs84=-168,-60,320,0,0,0,0 +pm=paris +units=m +no_defs";
Proj4js.defs["EPSG:2154"] = "+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
//new OpenLayers.Projection("EPSG:900913")


GeoNetwork.map.printCapabilities = "../../pdf";

// Config for WGS84 based maps
GeoNetwork.map.PROJECTION = "EPSG:4326";
GeoNetwork.map.UNITS = "dd"; //degrees

/*
* Changed by GVB
* Replaced the default map configuration 
*/
GeoNetwork.map.EXTENT=new OpenLayers.Bounds(4.20,50.7,4.53,50.96);
GeoNetwork.map.RESTRICTEDEXTENT = new OpenLayers.Bounds(-2.319882890625,48.267306835937,10.797792890625,53.903293164062);
GeoNetwork.map.RESOLUTIONS = [/*0.703125, 0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, */0.010986328125, 0.0054931640625, 0.00274658203125, 0.001373291015625, 0.0006866455078125, 0.00034332275390625, 0.000171661376953125, 0.0000858306884765625, 0.00004291534423828125, 0.000021457672119140625, 0.000010728836059570312, 0.000005364418029785156, 0.000002682209014892578, 0.000001341104507446289, 0.0000006705522537231445, 0.00000033527612686157227];
GeoNetwork.map.MAXRESOLUTION = 0.010986328125;
GeoNetwork.map.NUMZOOMLEVELS = 16;
//GeoNetwork.map.RESOLUTIONS = [/*1.40625000000000000000, 0.70312500000000000000, 0.35156250000000000000, 0.17578125000000000000, 0.08789062500000000000, */0.04394531250000000000, 0.02197265625000000000, 0.01098632812500000000, 0.00549316406250000000, 0.00274658203125000000, 0.00137329101562500000, 0.00068664550781250000, 0.00034332275390625000, 0.00017166137695312500, 0.00008583068847656250, 0.00004291534423828120, 0.00002145767211914060, 0.00001072883605957030, 0.00000536441802978516, 0.00000268220901489258, 0.00000134110450744629, 0.00000067055225372314, 0.00000033527612686157];
//GeoNetwork.map.MAXRESOLUTION = 0.04394531250000000000;
//GeoNetwork.map.MAXRESOLUTION = 1.40625000000000000000;
//GeoNetwork.map.NUMZOOMLEVELS = 18;
//GeoNetwork.map.NUMZOOMLEVELS = 23;
GeoNetwork.map.TILESIZE = new OpenLayers.Size(256,256);
//GeoNetwork.map.BACKGROUND_LAYERS=[new OpenLayers.Layer.WMS("Background layer","http://geoserver.gis.irisnetlab.be/geoserver/wms",{layers:"urbisFR",format:"image/jpeg"},{isBaseLayer:true,singleTile: true})];
GeoNetwork.map.BACKGROUND_LAYERS=[new OpenLayers.Layer.WMS("Background layer","http://geoserver.gis.irisnet.be/geoserver/wms",{layers:"urbisFR",format:"image/jpeg"},{isBaseLayer:true,singleTile: true})];
GeoNetwork.map.EXTENT_MAP_OPTIONS = {
	    projection: GeoNetwork.map.PROJECTION,
	    units: GeoNetwork.map.UNITS,
	    resolutions: GeoNetwork.map.RESOLUTIONS,
	    maxResolution: GeoNetwork.map.MAXRESOLUTION,
	    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//		tileSize: GeoNetwork.map.TILESIZE,
//		controls: [],
		maxExtent: GeoNetwork.map.EXTENT,
//		restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
	};
GeoNetwork.map.MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    units: GeoNetwork.map.UNITS,
    resolutions: GeoNetwork.map.RESOLUTIONS,
    maxResolution: GeoNetwork.map.MAXRESOLUTION,
    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//	tileSize: GeoNetwork.map.TILESIZE,
	controls: [],
	maxExtent: GeoNetwork.map.EXTENT,
//	restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
};
//GeoNetwork.map.MAP_OPTIONS={projection:GeoNetwork.map.PROJECTION,restrictedExtent:GeoNetwork.map.EXTENT,controls:[]};
GeoNetwork.map.MAIN_MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    units: GeoNetwork.map.UNITS,
    resolutions: GeoNetwork.map.RESOLUTIONS,
    maxResolution: GeoNetwork.map.MAXRESOLUTION,
    numZoomLevels: GeoNetwork.map.NUMZOOMLEVELS,
//	tileSize: GeoNetwork.map.TILESIZE,
	controls: [],
	maxExtent: GeoNetwork.map.EXTENT,
//	restrictedExtent: GeoNetwork.map.RESTRICTEDEXTENT
};
//GeoNetwork.map.MAIN_MAP_OPTIONS={projection:GeoNetwork.map.PROJECTION,restrictedExtent:GeoNetwork.map.EXTENT,controls:[]};
Ext.namespace("GeoNetwork");
/*
GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-180,-90,180,90);
//GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-5.1,41,9.7,51);

GeoNetwork.map.BACKGROUND_LAYERS = [
    new OpenLayers.Layer.WMS("Background layer", "/geoserver/wms", {layers: 'gn:world,gn:ne_50m_boundary_da,gn:ne_50m_boundary_lines_land,gn:ne_50m_coastline', format: 'image/jpeg'}, {isBaseLayer: true})
    //new OpenLayers.Layer.WMS("Background layer", "http://www2.demis.nl/mapserver/wms.asp?", {layers: 'Countries', format: 'image/jpeg'}, {isBaseLayer: true})
    ];

// Config for OSM based maps
//GeoNetwork.map.PROJECTION = "EPSG:900913";
////GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-550000, 5000000, 1200000, 7000000);
//GeoNetwork.map.EXTENT = new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34);
//GeoNetwork.map.BACKGROUND_LAYERS = [
//    new OpenLayers.Layer.OSM()
//    //new OpenLayers.Layer.Google("Google Streets");
//    ];

GeoNetwork.map.MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    maxExtent: GeoNetwork.map.EXTENT,
    restrictedExtent: GeoNetwork.map.EXTENT,
    controls: []
};
GeoNetwork.map.MAIN_MAP_OPTIONS = {
    projection: GeoNetwork.map.PROJECTION,
    maxExtent: GeoNetwork.map.EXTENT,
    restrictedExtent: GeoNetwork.map.EXTENT,
    controls: []
};
*/