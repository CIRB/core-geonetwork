/*
 * Copyright (C) 2001-2011 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 * 
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */
Ext.namespace('GeoNetwork');

GeoNetwork.Lang = {};

GeoNetwork.Util = {
    defaultLocale: 'eng',
    /**
     * Supported GeoNetwork GUI languages
     */
    locales: [
/*            ['ar', 'عربي', 'ara'], 
            ['ca', 'Català', 'cat'], 
            ['cn', '中文', 'chi'], 
            ['de', 'Deutsch', 'ger'], 
*/
			['en', 'English', 'eng'], 
//            ['es', 'Español', 'spa'], 
            ['fr', 'Français', 'fre'], 
//            ['it', 'Italiano', 'ita'], 
            ['nl', 'Nederlands', 'dut']/*, 
            ['no', 'Norsk', 'nor'],
            ['pl', 'Polski', 'pol'], 
            ['pt', 'Рortuguês', 'por'], 
            ['ru', 'Русский', 'rus'],
            ['fi', 'Suomeksi', 'fin'],
            ['tr', 'Türkçe', 'tur']*/
                       
    ],
    /** api: method[setLang] 
     *  :param lang: String ISO 3 letters code
     *  :param baseUrl: String Base URL use to load Ext loc files
     *
     *  Set OpenLayers lang and load ext required lang files
     */
    setLang: function(lang, baseUrl){
        lang = lang || GeoNetwork.Util.defaultLocale;
        // translate to ISO2 language code
        var openlayerLang = this.getISO2LangCode(lang);

        OpenLayers.Lang.setCode(openlayerLang);
        var s = document.createElement("script");
        s.type = 'text/javascript';
        s.src = baseUrl + "/js/ext/src/locale/ext-lang-" + openlayerLang + ".js";
        document.getElementsByTagName("head")[0].appendChild(s);
    },
    /** api: method[setLang] 
     *  :param lang: String ISO 3 letters code
     *  
     *  
     *  Return a valid language code if translation is available.
     *  Catalogue use ISO639-2 code.
     */
    getCatalogueLang: function(lang){
        var i;
        for (i = 0; i < GeoNetwork.Util.locales.length; i++) {
            if (GeoNetwork.Util.locales[i][0] === lang) {
                return GeoNetwork.Util.locales[i][2];
            }
        }
        return 'eng';
    },
    /** api: method[setLang] 
     *  :param lang: String ISO 3 letters code
     *  
     *  Return ISO2 language code (Used by OpenLayers lang and before GeoNetwork 2.7.0)
     *  for corresponding ISO639-2 language code.
     */
    getISO2LangCode: function(lang){
        var i;
        for (i = 0; i < GeoNetwork.Util.locales.length; i++) {
            if (GeoNetwork.Util.locales[i][2] === lang) {
                return GeoNetwork.Util.locales[i][0];
            }
        }
        return 'en';
    },
    /** api: method[getParameters] 
     *  :param url: String URL to parse
     *  
     *  Get list of URL parameters including anchor
     */
    getParameters: function(url){
        var parameters = OpenLayers.Util.getParameters(url);
        if (OpenLayers.String.contains(url, '#')) {
            var start = url.indexOf('#') + 1;
            var end = url.length;
            var paramsString = url.substring(start, end);
            
            var pairs = paramsString.split(/[\/]/);
            for (var i = 0, len = pairs.length; i < len; ++i) {
                var keyValue = pairs[i].split('=');
                var key = keyValue[0];
                var value = keyValue[1] || '';
                parameters[key] = value;
            }
        }
        return parameters;
    },
    getBaseUrl: function(url){
        return url.substring(0, url.indexOf('?') || url.indexOf('#') || url.length);
    },

    // TODO : add function to compute color map
    defaultColorMap: [
                       "#2205fd", 
                       "#28bc03", 
                       "#bc3303", 
                       "#e4ff04", 
                       "#ff04a0", 
                       "#a6ff96", 
                       "#408d5d", 
                       "#7d253e", 
                       "#2ce37e", 
                       "#10008c", 
                       "#ff9e05", 
                       "#ff7b5d", 
                       "#ff0000", 
                       "#00FF00"],
   /** api: method[generateColorMap] 
    *  :param classes: integer Number of classes
    *  
    *   Return a random color map
    */
   generateColorMap: function (classes) {
        var colors = [];
        for (var i = 0; i < classes; i++) {
            // http://paulirish.com/2009/random-hex-color-code-snippets/
            colors[i] = '#'+('00000'+(Math.random()*(1<<24)|0).toString(16)).slice(-6);
        }
        return colors;
    },
    /** api: method[buildPermalinkMenu] 
     *  :param l: String or Function If String the link is added as is, if a function
     *  the function is called on 'show' event
     *  :param scope: Object The scope on which the l function is called.
     *  
     *  Create a permalink menu which is updated on show.
     *  
     *  TODO : maybe move on widget package - this is GUI related?
     *  
     *   Return Ext.menu.Menu
     */
    buildPermalinkMenu: function (l, scope) {
        var menu = new Ext.menu.Menu();
        var permalinkMenu = new Ext.menu.TextItem({text: '<input/><br/><a>&nbsp;</a>'});
        menu.add(
                '<b class="menu-title">' + OpenLayers.i18n('permalinkInfo') + '</b>',
                permalinkMenu
            );
        // update link when item is displayed
        var updatePermalink = function() {
            var link = l;
            if (typeof(l) == 'function') {
                link = l.apply(scope);
            }
            var id = 'permalink-' + permalinkMenu.getId();
            permalinkMenu.update('<input id="' + id + '" value="' + link + '"/>'
                + '</br>'
                + '<a href="' + link + '">Link</a>', 
                true, 
                // Select permalink input for user to easily copy/paste link
                function() {
                    // On IE8, select() on an element scroll to top of page, why ?
                    if (!Ext.isIE8) {
                        // update callback is not really called after update
                        // so add a short timeout TODO
                        setTimeout(function(){
                            var e = Ext.get(id);
                            if (e) {
                                e.dom.select();
                            }
                        }, 100);
                    }
            });
            
        };
        // onstatechange does not work because the menu item may be not be rendered
        //this.permalinkProvider.on('statechange', onStatechange, this.permalinkMenu);
        menu.on('show', updatePermalink, scope);
        return new Ext.Button({
            iconCls: 'linkIcon',
            menu: menu
        });
    },
    /** 
     *  Initialize all div with class cal.
     *  
     *  Those divs will be replaced by an Ext DateTime or DateField.
     *
     */
    initComboBox: function(editorPanel){
        var combos = Ext.DomQuery.select('div.combobox'), i;
        var scope = this;
        for (i = 0; i < combos.length; i++) {
            var combo = combos[i];
            var id = "s" + combo.id.substring(0,combo.id.indexOf("_combobox")); // Give render div id to calendar input and change
            // its id.
//            combo.id = id + 'Id'; // In order to get the input if a get by id is made
            // later (eg. gn_search.js).
            
            if (combo.firstChild === null || combo.childNodes.length === 0) { // Check if
                // already
                // initialized
                // or not
                
                var valueEl = Ext.getDom(/*id + '_combobox'*/id.substring(1), editorPanel.dom);
                var value = (valueEl ? valueEl.value : '');
                var config = combo.getAttribute("config");
                var jsonConfig = Ext.decode(config);
                var data = new Array();
                for (var j=0;j<jsonConfig.optionValues.length;j++) {
                	data.push([jsonConfig.optionValues[j],jsonConfig.optionLabels[j]]);
                }
                var dCombo = new Ext.form.ComboBox({
                    renderTo: combo,
                    id: id,
                    style: 'width: 60%',
                    name: id,
                    mode:'local',
                    value: value,
                    editable:true,
                    triggerAction:'all',
                    selectOnFocus:true,
                    displayField:'label',
                    valueField:'value',
                    forceSelection:false,
                    autoShow:true,
                    store:new Ext.data.SimpleStore({
                        fields:[
                            'value', 'label'
                        ],
                        data: data,
                        autoLoad:true
                    }),
                    onchangeFunction: jsonConfig.onchangeFunction,
                    onchangeParams: jsonConfig.onchangeParams,
                    onkeyupFunction: jsonConfig.onkeyupFunction,
                    onkeyupParams: jsonConfig.onkeyupParams,
                    listeners: {
                        change: function(cb, newValue, oldValue){
                        	Ext.get(this.id.substring(1)).dom.value =  this.getValue();
                            if (this.onchangeFunction && this.onchangeFunction.length>0) {
                                if (this.onchangeParams && this.onchangeParams.length>0) {
                                	scope.executeFunctionByName(this.onchangeFunction,window,this.onchangeParams.split(','));
                                } else {
                                	scope.executeFunctionByName(this.onchangeFunction,window);
                                }
                            }
                        }/*,
                        keyup: function(textField, e){
                            if (this.onkeyupFunction && this.onkeyupFunction.length>0) {
                                if (this.onkeyupParams && this.onkeyupParams.length>0) {
                                	scope.executeFunctionByName(this.onchangeFunction,window,this.onkeyupParams.split(','));
                                } else {
                                	scope.executeFunctionByName(this.onkeyupFunction,window);
                                }
                            }
                        }*/
                    }
                });

                //Small hack to put date button on its place
                if (Ext.isChrome){
                    dCombo.getEl().parent().setHeight("18");
                }
/*
                dCombo.on('change', function() {
                    Ext.get(this.id.substring(1)).dom.value =  this.getValue();
                });
*/                
            }
        }
    },
    executeFunctionByName: function(functionName, context , args) {
//      var args = Array.prototype.slice.call(arguments, 2);
      var namespaces = functionName.split(".");
      var func = namespaces.pop();
      for (var i = 0; i < namespaces.length; i++) {
          context = context[namespaces[i]];
      }
      return context[func].apply(context, args);
  }
  
};
