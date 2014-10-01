Ext.namespace('GeoNetwork');

var catalogue;
var app;
var cookie;

GeoNetwork.app = function() {
	// private vars:
	var geonetworkUrl;
	var searching = false;
	var editorWindow;
	var editorPanel;
	var resultPanel;

	/**
	 * Application parameters are : * any search form ids (eg. any) * mode=1 for
	 * visualization * advanced: to open advanced search form by default *
	 * search: to trigger the search * uuid: to display a metadata record based
	 * on its uuid * extent: to set custom map extent
	 */
	var urlParameters = {};

	/**
	 * Catalogue manager
	 */
	var catalogue;

	/**
	 * An interactive map panel for data visualization
	 */
	var iMap;

	var searchForm;

	var optionsForm;

	var resultsPanel;

	var metadataResultsView;

	var tBar, bBar;

	var mainTagCloudViewPanel, tagCloudViewPanel;

	var visualizationModeInitialized = false;

	function setTab(id) {
		var tabPanel = Ext.getCmp("GNtabs"), tabs = tabPanel.find('id', id);
		if (tabs[0]) {
			tabPanel.setActiveTab(tabs[0]);
		}
	}

	function addWMSLayer(arr) {
/*
* Modified by GVB
*/
		// app.switchMode();
		// app.getIMap().addWMSLayer(arr);
	}

	/**
	 * Create a mapControl
	 * 
	 * @return
	 */
	function initMap() {
		iMap = new GeoNetwork.mapApp();
		iMap.init(GeoNetwork.map.BACKGROUND_LAYERS,
				GeoNetwork.map.MAIN_MAP_OPTIONS);
		metadataResultsView.addMap(iMap.getMap());
		visualizationModeInitialized = true;
		return iMap;
	}

	/**
	 * Create a language switcher mode
	 * 
	 * @return
	 */
	function createLanguageSwitcher(lang) {
		return new Ext.form.FormPanel({
			renderTo : 'lang-form',
			width : 100,
			border : false,
			layout : 'hbox',
			hidden : GeoNetwork.Util.locales.length === 1 ? true : false,
			items : [ new Ext.form.ComboBox({
				mode : 'local',
				triggerAction : 'all',
				width : 100,
				store : new Ext.data.ArrayStore({
					idIndex : 2,
					fields : [ 'id', 'name', 'id2' ],
					data : GeoNetwork.Util.locales
				}),
				valueField : 'id2',
				displayField : 'name',
				value : lang,
				listeners : {
					select : function(cb, record, idx) {
						window.location.replace('?hl=' + cb.getValue());
					}
				}
			}) ]
		});
	}

	/**
	 * Error message in case of bad login
	 * 
	 * @param cat
	 * @param user
	 * @return
	 */
	function loginAlert(cat, user) {
		Ext.Msg.show({
			title : 'Login',
			msg : 'Login failed. Check your username and password.',
			/* TODO : Get more info about the error */
			icon : Ext.MessageBox.ERROR,
			buttons : Ext.MessageBox.OK
		});
	}

	/**
	 * Create a default login form and register extra events in case of error.
	 * 
	 * @return
	 */
	function createLoginForm() {
		var loginForm = new GeoNetwork.LoginForm({
			renderTo : 'login-form',
			catalogue : catalogue,
			layout : 'hbox',
			bodyStyle : {
				"background-color" : "transparent"
			},
			hideLoginLabels : GeoNetwork.hideLoginLabels
		});

		catalogue.on('afterBadLogin', loginAlert, this);

		// Store user info in cookie to be displayed if user reload the page
		// Register events to set cookie values
		catalogue.on('afterLogin', function() {
			cookie.set('user', catalogue.identifiedUser);
		});
		catalogue.on('afterLogout', function() {
			cookie.set('user', undefined);
		});

		// Refresh login form if needed
		var user = cookie.get('user');
		if (user) {
			catalogue.identifiedUser = user;
			loginForm.login(catalogue, true);
		}
	}
	function getResultsMap() {
		// Create map panel
		var map = new OpenLayers.Map({
			div : 'results_map'
		});
		map.setOptions(GeoNetwork.map.MAP_OPTIONS);
		map.addLayers(GeoNetwork.map.BACKGROUND_LAYERS);
		map.zoomToMaxExtent();

		var mapPanel = new GeoExt.MapPanel({
			id : "resultsMap",
			height : 125,
			width : 250,
			stateful : false,
			map : map
		});

		return mapPanel;
	}

	/**
	 * Create a default search form with advanced mode button
	 * 
	 * @return
	 */
	function createSearchForm() {
		// Add advanced mode criteria to simple form - start
		var advancedCriteria = [];
		var services = catalogue.services;

		// Multi select organisation field
		var orgNameStore = new GeoNetwork.data.OpenSearchSuggestionStore({
			url : services.opensearchSuggest,
			rootId : 1,
			baseParams : {
				field : 'orgName'
			}
		});

		var orgNameField = new Ext.ux.form.SuperBoxSelect({
			hideLabel : false,
			minChars : 0,
			queryParam : 'q',
			hideTrigger : false,
			id : 'E_orgName',
			name : 'E_orgName',
			store : orgNameStore,
			valueField : 'value',
			displayField : 'value',
			valueDelimiter : ' or ',
			// tpl: tpl,
			fieldLabel : OpenLayers.i18n('org'),
            /*
             * Added by GVB
             */
            emptyText: OpenLayers.i18n('orgEmptyText'),
            editable: false
		});

		// Multi select keyword
		var themekeyStore = new GeoNetwork.data.OpenSearchSuggestionStore({
			url : services.opensearchSuggest,
			rootId : 1,
			baseParams : {
				field : 'keyword'
			}
		});

        var tpl = '<tpl for="."><div class="x-combo-list-item" ext:qtip="{values.value}">{values.value}</div></tpl>';
        var displayFieldTpl = '<tpl for="."><span ext:qtip="{values.value}">{values.value}</span></tpl>';
        var themekeyField = new Ext.ux.form.SuperBoxSelect({
			hideLabel : false,
			minChars : 0,
			queryParam : 'q',
			hideTrigger : false,
			id : 'E_themekey',
			name : 'E_themekey',
			store : themekeyStore,
			valueField : 'value',
			displayField : 'value',
			valueDelimiter : ' or ',
			fieldLabel : OpenLayers.i18n('keyword'),
            displayFieldTpl: displayFieldTpl,
            tpl: tpl
			/*
			* Added by GVB
			*/
			, emptyText : OpenLayers.i18n('keywordEmptyText'),
            editable: false
		});

		var catalogueField = GeoNetwork.util.SearchFormTools.getCatalogueField(
				services.getSources, services.logoUrl, true);
		var groupField = GeoNetwork.util.SearchFormTools.getGroupField(
				services.getGroups, true);
		var metadataTypeField = GeoNetwork.util.SearchFormTools
				.getMetadataTypeField(true);
		var categoryField = GeoNetwork.util.SearchFormTools.getCategoryField(
				services.getCategories, '../images/default/category/', true);
		var validField = GeoNetwork.util.SearchFormTools.getValidField(true);
		var spatialTypes = GeoNetwork.util.SearchFormTools
				.getSpatialRepresentationTypeField(null, true);
		var resourceTypeField = GeoNetwork.util.SearchFormTools
				.getTypesField(null, true);
		var denominatorField = GeoNetwork.util.SearchFormTools
				.getScaleDenominatorField(true);

		// Add hidden fields to be use by quick metadata links from the admin
		// panel (eg. my metadata).
		var ownerField = new Ext.form.TextField({
			name : 'E__owner',
			hidden : true
		});
		var isHarvestedField = new Ext.form.TextField({
			name : 'E__isHarvested',
			hidden : true
		});

		advancedCriteria.push(themekeyField,
/*
* Added by GVB
*/
				GeoNetwork.util.INSPIRESearchFormTools
						.getThemesField(
								catalogue.services,
								true));
								
        if (GeoNetwork.Settings.nodeType.toLowerCase() == "cirb") {
        	advancedCriteria.push(orgNameField);
        }
		
		advancedCriteria.push(/*
* Removed by GVB
*/
				//categoryField,
				spatialTypes,
/*
* Added by GVB
*/
				resourceTypeField,
/*
* Removed by GVB
*/
//				denominatorField,
				catalogueField,
/*
* Removed by GVB
*/
//				groupField,
				metadataTypeField
/*
* Removed by GVB
*/
//				, validField, ownerField, isHarvestedField
				);
        if (GeoNetwork.Settings.nodeType.toLowerCase() != "cirb") {
			advancedCriteria.push(GeoNetwork.util.INSPIRESearchFormTools.getReportingField());			
		}
		// Hide or show extra fields after login event
		var adminFields = [
/*
* Removed by GVB
*/
//			groupField,
/*
* Added by GVB
*/
			catalogueField,
			metadataTypeField
/*
* Removed by GVB
*/
//			,validField
        ];
		Ext.each(adminFields, function(item) {
			item.setVisible(false);
		});

		catalogue.on('afterLogin', function() {
			Ext.each(adminFields, function(item) {
				item.setVisible(true);
			});
			/*
			* Added by GVB
			*/
            GeoNetwork.util.SearchFormTools.reload(this);
            Ext.getCmp('searchForm').doLayout();
//			Ext.getCmp("advSearchTabs").doLayout();
		});
		catalogue.on('afterLogout', function() {
			Ext.each(adminFields, function(item) {
				item.setVisible(false);
			});
			/*
			* Added by GVB
			*/
            GeoNetwork.util.SearchFormTools.reload(this);
            Ext.getCmp('searchForm').doLayout();
//			Ext.getCmp("advSearchTabs").doLayout();
		});

		var hideInspirePanel = catalogue.getInspireInfo().enable === "false";
		/*
		* Moved by GVB
		*/

		var searchCb = function() {
			var any = Ext.get('E_any');
			if (any) {
				if (any.getValue() === OpenLayers.i18n('fullTextSearch')) {
					any.setValue('');
				}
			}
			catalogue.startRecord = 1; // Reset
			// start
			// record
			search();
			setTab('results');

			// / Trigger the onsearch event which update search form state
			Ext.getCmp('searchForm').fireEvent('onsearch');
		};

		return new GeoNetwork.SearchFormPanel(
				{
               		id : 'searchForm',
					stateId : 's',
					bodyStyle : 'text-align: center;',
					border : false,
					searchBt : null,
					resetBt : null,
		            autoScroll: true,
		/*
		            listeners: {
		                afterrender: function(){
		                    //Ext.getCmp("advSearchTabs").getEl().toggle();
		                    }
		            },
		*/
		            items:[
		                // Simple search form and search buttons
		                {
		                    layout: {
		                        type: 'hbox',
		                        pack: 'center',
		                        align: 'center'
		                    },
		                    bodyStyle:'padding-top:65px;border-width:0px',
		                    border:true,
		                    items:[
		                   		new Ext.form.Label({
		                    		text: OpenLayers.i18n('Searchforspatialdataon'),
		        	               	style:'padding-top:5px;padding-right:10px;font-weight:bold;font-size:150%'/*,
		                       		listeners: {
		                    		   render: function(textField) {
		                    			   Ext.QuickTips.register({
		                    				   target: textField.getEl(),
		                    				   text: "Zoek in alle tekstvelden en codelijsten"
		                    			   });
		                    		   }
		                    	   }*/
		                   		}),
	                   			new GeoNetwork.form.OpenSearchSuggestionTextField(
									{
										id: 'openSearchSuggestionTextField',
										// hideLabel: true,
										width : 400,
										height : 40,
										minChars : 2,
										loadingText : '...',
										hideTrigger : true,
										url : catalogue.services.opensearchSuggest
									})
									/*
									* Moved by GVB
									*/
									/*
									,new Ext.Button(
										{
											text : OpenLayers
													.i18n('Simple'),
											tooltip : OpenLayers
													.i18n('resetSearchForm'),
											// iconCls: 'md-mn-reset',
											id : 'toggleSearchTypeBt',
											margins : '3 5 3 5',
											listeners : {
												click : function() {
													app.toggleSearchType(this);
												}
											}
										})
									,new Ext.Button(
										{
											text : OpenLayers
													.i18n('reset'),
											tooltip : OpenLayers
													.i18n('resetSearchForm'),
											// iconCls: 'md-mn-reset',
											id : 'resetBt',
											margins : '3 5 3 5',
											icon : '../images/default/cross.png',
											iconAlign : 'right',
											listeners : {
												click : function() {
													Ext
															.getCmp(
																	'searchForm')
															.getForm()
															.reset();
												}
											}
										}),
									new Ext.Button(
										{
											text : OpenLayers
													.i18n('search'),
											id : 'searchBt',
											margins : '3 5 3 5',
											icon : '../images/default/find.png',
											iconAlign : 'right',
											listeners : {
												click : searchCb
											}
										}),
									new Ext.Button(
										{
											text : OpenLayers
													.i18n('reset'),
											tooltip : OpenLayers
													.i18n('resetSearchForm'),
											// iconCls: 'md-mn-reset',
											id : 'resetBt',
											margins : '3 5 3 5',
											icon : '../images/default/cross.png',
											iconAlign : 'right',
											listeners : {
												click : function() {
													Ext
															.getCmp(
																	'searchForm')
															.getForm()
															.reset();
												}
											}
										})*/
								]
							},
							/*
							* Removed by GVB
							*/
/*
							// Panel with Advanced search, Help and About Links
							{
								layout : {
									type : 'hbox',
									pack : 'center',
									align : 'center'
								},
								id : 'advSearch',
								autoScroll : true,
								border : false,
								height : 60,
								defaults : {
									bodyStyle : {},
									margins : '0 10 0 10',
									border : false
								},
								items : [
										{
											html : "<a href='javascript:void(0)' onclick='this.innerHTML=(this.innerHTML==\""
													+ OpenLayers
														.i18n('Simple')
													+ "\"?\""
													+ OpenLayers
														.i18n('Advanced')
													+ "\":\""
													+ OpenLayers
													.i18n('Simple')
													+ "\");Ext.get(\"advSearchTabs\").toggle();'>"
													+ OpenLayers
														.i18n('Advanced')
													+ "</a>"
										},
										{
											html : '<a href="javascript:void(app.getHelpWindow().show());">'
													+ OpenLayers.i18n('Help')
													+ '</a>'
										}
										,{
											html : '<a href="javascript:void(app.getAboutWindow().show());">'
													+ OpenLayers.i18n('About')
													+ '</a><br/><br/>'
										} ]
							},
*/
							// Advanced search form
/*
 * Modified by GVB
 */
							{
//								hidden:true,
//								collapsed:true,
			                    id:'advSearchTabs',
			                    plain:true,
			                    collapsed: true,
			                    layout: 'column',
			                    layoutConfig: { pack: 'center', align: 'center' },
			                    autoHeight: true,
//			                    autoWidth: true,
			                    boxMinWidth: 970,
	                            boxMaxWidth: 1770,
			                    bodyStyle:'border-width:0px',
			                    border:true,
			                    deferredRender: false,
			                    defaults:{style:'padding:15px',bodyStyle:'padding:5px'},
								items : [
			                        {
			                       		border: false,
			                        	columnWidth: 0.2
			                        },
			                        // What panel
			                        {
					                    frame: true,
			                            title: OpenLayers.i18n('what'),
			                            layout:'form',
			                            labelWidth: 150,
			                            autoHeight: true,
//					                            width: 820,
			                            boxMinWidth: 420,
			                            boxMaxWidth: 900,
			                        	columnWidth: 0.6,
			                            items:[
			                                advancedCriteria/*,GeoNetwork.util.SearchFormTools.getTypesField(GeoNetwork.searchDefault.activeMapControlExtent, true),
			                                GeoNetwork.util.INSPIRESearchFormTools.getAnnexField(true),
			                                GeoNetwork.util.INSPIRESearchFormTools.getThemesField(catalogue.services, true),
			                                GeoNetwork.util.INSPIRESearchFormTools.getServiceTypeField(true)
*/			                            ]
			                        },
/*
			                        // Where panel
			                        {
			                            title: OpenLayers.i18n('where'),
			                            bodyStyle:'padding:0px',
			                            layout:'form',
			                            autoHeight: true,
			                            width: 270,
			                            items:[
			                                GeoNetwork.util.SearchFormTools.getSimpleMap(GeoNetwork.map.BACKGROUND_LAYERS, GeoNetwork.map.MAP_OPTIONS,false)]
			                        },
*/
			                        // When panel
			                        {
					                    frame: true,
			                            title:OpenLayers.i18n('when'),
			                            defaultType: 'datefield',
			                            layout:'form',
			                            autoHeight: true,
			                            width: 270,
			                            items:GeoNetwork.util.SearchFormTools.getWhen()
			                        },
			                       	// INSPIRE panel
			                        /*
                                    {
                                        title:'INSPIRE',
                                        hidden: hideInspirePanel,
                                        defaultType: 'datefield',
                                        layout:'form',
                                        autoHeight: true,
                                        width: 250,
                                        items: GeoNetwork.util.INSPIRESearchFormTools.getINSPIREFields(catalogue.services, true)
                                    },
			                        */
			                        //Options
			                        {
			                       		title:'Options',
			                            layout:'form',
			                            width:0,
			                            autoHeight: true,
			                            hidden: true,
			                            items: optionsForm
			                       	},
			                        {
			                       		border: false,
			                        	columnWidth: 0.2
			                        }
								]
							},
							{
								bodyStyle : {
									'padding-top' : '10px'
								},
								layout : {
									type : 'hbox',
									pack : 'center',
									align : 'center'
								},
								border : false,
								items : [
				                   		new Ext.form.Label({
											html : '<span ext:qtip="' + OpenLayers.i18n('searchOptionButton') + '">' + OpenLayers.i18n('search') + '</span>',
											cls: 'geonode_button red',
											id : 'searchBt',
											margins : '3 5 3 5',
											listeners: {
												render: function(c){
													c.getEl().on('click', searchCb, c);
												}
											}
										}),
				                   		new Ext.form.Label({
											html : '<span ext:qtip="' + OpenLayers.i18n('resetSearchForm') + '">' + OpenLayers.i18n('reset') + '</span>',
											cls: 'geonode_button gray',
											id : 'resetBt',
											margins : '3 5 3 5',
											listeners: {
												render: function(c){
													c.getEl().on('click', function() {
															Ext.getCmp('searchForm').getForm().reset();
														}, c);
												}
											}
										}),
										new Ext.form.Label(
											{
												text : OpenLayers.i18n('Advanced'),
												cls : 'geonode_button gray',
//												tooltip : OpenLayers.i18n('simpleTooltip'),
												id : 'toggleSearchTypeBt',
												margins : '3 5 3 5',
												listeners: {
													render: function(c){
														c.getEl().on('click', function() {
																app.toggleSearchType(this);
															}, c);
													}
												}
											})
									]
							}
						]
				});
	}

    function search() {
		searching = true;
		catalogue.search('searchForm', app.loadResults, null,
				catalogue.startRecord, true);
	}

	function initPanels() {
		var resultsPanel = Ext.getCmp('resultsPanel');
		if (!resultsPanel.isVisible()) {
			resultsPanel.show();
		}

	}
	/**
	 * Bottom bar
	 * 
	 * @return
	 */
	function createBBar() {

		var previousAction = new Ext.Action({
			id : 'previousBt',
			text : '&lt;&lt;',
			handler : function() {
				var from = catalogue.startRecord
						- parseInt(Ext.getCmp('E_hitsperpage').getValue(), 10);
				if (from > 0) {
					catalogue.startRecord = from;
					search();
				}
			},
			scope : this
		});

		var nextAction = new Ext.Action({
			id : 'nextBt',
			text : '&gt;&gt;',
			handler : function() {
				catalogue.startRecord += parseInt(Ext.getCmp('E_hitsperpage')
						.getValue(), 10);
				search();
			},
			scope : this
		});
		/*
		 * Added by GVB
		 */
		var hitsPerPage = [ [ '10' ], [ '20' ], [ '50' ], [ '100' ] ];
		return new Ext.Toolbar(
			{
			items : [ previousAction, '|', nextAction, '|', {
					xtype : 'tbtext',
					text : '',
					id : 'info'
				}
/*
 * Added by GVB
 */
				,'| '+OpenLayers.i18n('hitsPerPage'),
				new Ext.form.ComboBox({
					id : 'E_hitsperpage',
					name : 'E_hitsperpage',
					width : 80,
					mode : 'local',
					triggerAction : 'all',
					fieldLabel : OpenLayers.i18n('hitsPerPage'),
					value : hitsPerPage[0], // Set arbitrarily the second value of the
					// array as the default one.
					store : new Ext.data.ArrayStore({
						id : 0,
						fields : [ 'id' ],
						data : hitsPerPage
					}),
					valueField : 'id',
					displayField : 'id',
		            listeners: {
		                select: function(cb, record, idx){
		                	Ext.getCmp('searchBt').getEl().dom.click();
		                }
		            }
				})
			]
		});

	}

	/**
	 * Results panel layout with top, bottom bar and DataView
	 * 
	 * @return
	 */
	function createResultsPanel(permalinkProvider) {
        metadataResultsView = new GeoNetwork.MetadataResultsView({
            catalogue: catalogue,
            displaySerieMembers: true,
            border: false,
            frame: false,
            layout: 'fit',
            bodyStyle:'padding:5px',
            autoHeight: true,
            autoWidth: true,
            tpl: GeoNetwork.Templates.FULL
        });

		catalogue.resultsView = metadataResultsView;

        tBar = new GeoNetwork.MetadataResultsToolbar({
			catalogue : catalogue,
			searchBtCmp : Ext.getCmp('searchBt'),
/*
 * Modified by GVB
 */
			sortByCmp : Ext.getCmp('E_sortBy'),
			metadataResultsView : metadataResultsView,
			permalinkProvider : permalinkProvider
		});

		bBar = createBBar();

		resultPanel = new Ext.Panel({
			id : 'resultsPanel',
			border: false,
//			frame: false,
			layout: 'fit',
			autoWidth: true,
//			autoHeight: true,
			autoScroll:true,
			hidden: true,
			bodyCssClass: 'md-view',
			tbar: tBar,
			items : metadataResultsView,
			// paging bar on the bottom
			bbar : bBar
		});

		return resultPanel;
	}
	function loadCallback(el, success, response, options) {

		if (!success) {
			// createMainTagCloud();
			// createLatestUpdate();
			// } else {
			Ext.get('helpPanel').getUpdater().update({
				url : 'help_eng.html'
			});
		}
	}
	/**
	 * private: methode[creatAboutPanel] About information panel displayed on
	 * load
	 * 
	 * :return:
	 */
	function creatAboutPanel() {
		return new Ext.Panel({
			border : true,
			id : 'infoPanel',
			baseCls : 'md-info',
			autoWidth : true,
			autoLoad : {
				url : catalogue.services.rootUrl + '/about?modal=true',
				callback : loadCallback,
				scope : this,
				loadScripts : true
			}
		});
	}
	/**
	 * private: methode[createHelpPanel] Help panel displayed on load
	 * 
	 * :return:
	 */
	function createHelpPanel() {
		return new Ext.Panel({
			border : false,
			frame : false,
			bodyStyle : {
				'background-color' : 'white',
				padding : '5px'
			},
			autoScroll : true,
			baseCls : 'none',
			id : 'helpPanel',
			autoWidth : true,
			autoLoad : {
				url : 'help_' + catalogue.LANG + '.html',
				callback : initShortcut,
				scope : this,
				loadScripts : false
			}
		});
	}

	/**
	 * Main tagcloud displayed in the information panel
	 * 
	 * @return
	 */
	function createMainTagCloud() {
		var tagCloudView = new GeoNetwork.TagCloudView({
			catalogue : catalogue,
			query : 'fast=true&summaryOnly=true',
			renderTo : 'tag',
			onSuccess : 'app.loadResults'
		});

		return tagCloudView;
	}
	/**
	 * Create latest metadata panel.
	 */
	function createLatestUpdate() {
		var latestView = new GeoNetwork.MetadataResultsView({
			catalogue : catalogue,
			autoScroll : true,
			tpl : GeoNetwork.Settings.latestTpl
		});
		var latestStore = GeoNetwork.Settings.mdStore();
		latestView.setStore(latestStore);
		latestStore.on('load', function() {
			Ext.ux.Lightbox.register('a[rel^=lightbox]');
		});
		var p = new Ext.Panel({
			border : false,
			bodyCssClass : 'md-view',
			items : latestView,
			renderTo : 'latest'
		});
		catalogue.kvpSearch(GeoNetwork.Settings.latestQuery, null, null, null,
				true, latestView.getStore());
	}
	/**
	 * Extra tag cloud to displayed current search summary TODO : not really a
	 * narrow your search component.
	 * 
	 * @return
	 */
	function createTagCloud() {
		var tagCloudView = new GeoNetwork.TagCloudView({
			catalogue : catalogue
		});

		return new Ext.Panel({
			id : 'tagCloudPanel',
			border : true,
			hidden : true,
			baseCls : 'md-view',
			items : tagCloudView
		});
	}

	function edit(metadataId, create, group, child) {

		if (!this.editorWindow) {
			this.editorPanel = new GeoNetwork.editor.EditorPanel({
				defaultViewMode : GeoNetwork.Settings.editor.defaultViewMode,
				catalogue : catalogue,
				xlinkOptions : {
					CONTACT : true
				}
			});

			this.editorWindow = new Ext.Window(
					{
						tools : [ {
							id : 'newwindow',
							qtip : OpenLayers.i18n('newWindow'),
							handler : function(e, toolEl, panel, tc) {
								window
										.open(GeoNetwork.Util
												.getBaseUrl(location.href)
												+ "#edit="
												+ panel
														.getComponent('editorPanel').metadataId);
								panel.hide();
							},
							scope : this
						} ],
						title : OpenLayers.i18n('mdEditor'),
						id : 'editorWindow',
						layout : 'fit',
						modal : false,
						items : this.editorPanel,
						closeAction : 'close',
						collapsible : true,
						collapsed : false,
						maximizable : true,
						maximized : true,
						resizable : true,
						// constrain: true,
						width : 980,
						height : 800
					});
            
            var this_ = this;
            this.editorWindow.on('destroy', function() {
                this_.editorWindow = undefined;
                this_.editorPanel = undefined;
            });
            this.editorPanel.setContainer(this.editorWindow);
			this.editorPanel.on('editorClosed', function() {
				Ext.getCmp('searchBt').getEl().dom.click();
			});
		}
		if (metadataId) {
			this.editorWindow.show();
			this.editorPanel.init(metadataId, create, group, child);
		}
	}
	function createOptionsForm() {
	/*
	 * Modified by GVB
	 */
		var /*hitsPerPage = [ [ '10' ], [ '20' ], [ '50' ], [ '100' ] ],*/ items = [];

		/*
		 * Modified by GVB
		 */
		items.push(GeoNetwork.util.SearchFormTools.getSortByCombo('changeDate#'));
		/*
		 * Removed by GVB
		 */
/*
		items.push(new Ext.form.ComboBox({
			id : 'E_hitsperpage',
			name : 'E_hitsperpage',
			mode : 'local',
			triggerAction : 'all',
			fieldLabel : OpenLayers.i18n('hitsPerPage'),
			value : hitsPerPage[1], // Set arbitrarily the second value of the
			// array as the default one.
			store : new Ext.data.ArrayStore({
				id : 0,
				fields : [ 'id' ],
				data : hitsPerPage
			}),
			valueField : 'id',
			displayField : 'id'
		}));
*/
		return items;
	}

	function createHeader() {
		var info = catalogue.getInfo();
		Ext.getDom('title').innerHTML = '<img class="catLogo" src="images/banner_logo.png" title="'
				+ info.name + '"/>';
		document.title = info.name;
	}

	// public space:
	return {
		init : function() {
			geonetworkUrl = GeoNetwork.URL
					|| window.location.href.match(
							/(http.*\/.*)\/apps\/tabsearch.*/, '')[1];

			urlParameters = GeoNetwork.Util.getParameters(location.href);
			var lang = urlParameters.hl || GeoNetwork.Util.defaultLocale;

			if (urlParameters.extent) {
				urlParameters.bounds = new OpenLayers.Bounds(
						urlParameters.extent[0], urlParameters.extent[1],
						urlParameters.extent[2], urlParameters.extent[3]);
			}

			// Init cookie
			cookie = new Ext.state.CookieProvider({
				expires : new Date(new Date().getTime()
						+ (1000 * 60 * 60 * 24 * 365))
			});

			// set a permalink provider which will be the main state provider.
			var permalinkProvider = new GeoExt.state.PermalinkProvider({
				encodeType : false
			});

			Ext.state.Manager.setProvider(permalinkProvider);

			// Create connexion to the catalogue
			catalogue = new GeoNetwork.Catalogue(
					{
						statusBarId : 'info',
						lang : lang,
						hostUrl : geonetworkUrl,
						mdOverlayedCmpId : 'resultsPanel',
						adminAppUrl : geonetworkUrl + '/srv/' + lang + '/admin',
						// Declare default store to be used for records and
						// summary
						metadataStore : GeoNetwork.Settings.mdStore ? GeoNetwork.Settings
								.mdStore()
								: GeoNetwork.data.MetadataResultsStore(),
						metadataCSWStore : GeoNetwork.data
								.MetadataCSWResultsStore(),
						summaryStore : GeoNetwork.data.MetadataSummaryStore(),
						editMode : 2, // TODO : create constant
						metadataEditFn : edit
					});

            if (Ext.get("title")) {
    			createHeader();
            }

			// Options Panel
			optionsForm = createOptionsForm();

			// Search form
			searchForm = createSearchForm();

			// Top navigation widgets
			// createModeSwitcher();
            if (Ext.get("lang-form")) {
            	createLanguageSwitcher(lang);
            }
            if (Ext.get("login-form")) {
                createLoginForm();
            }
			edit();

			// Results map
			var resultsMap = getResultsMap();

			// Search result
			resultsPanel = createResultsPanel(permalinkProvider);

			tagCloudViewPanel = createTagCloud();

			// Initialize map viewer
/*
* Modified by GVB
*/
//			initMap();

			// Register events on the catalogue
			var margins = '0 0 0 0';

			var viewport = new Ext.Viewport(
					{
						layout : 'border',
						id : 'vp',
						items : [ // todo: should add header here?
								{
									id : 'header',
									height : Ext.get('header') ? 80 : 0,
									region : 'north',
									border : false
								},
								new Ext.TabPanel({
									region : 'center',
									id : 'GNtabs',
									deferredRender : false,
									plain : true,
//									autoScroll : true,
//									defaults : { autoScroll : true },
									margins : '0 0 0 0',
									border : false,
									activeTab : 0,
									items : [ {// basic search panel
		                                title:OpenLayers.i18n('Home'),
		                                //contentEl:'dvZoeken',
		                                layout:'fit',
		                                layoutConfig: { pack: 'center', align: 'center' },
		                                listeners: {
		                                    activate: function(){
		                                        this.doLayout();
		                                    }
		                                },
		                                closable:false,
//										autoScroll : true,
										items : /*[ {
											id : 'alignCenter',
											border : false,
											layout : 'column',
											layoutConfig : {
												pack : 'center',
												align : 'center'
											},
											items : [ {
												columnWidth : 0.05,
												border : false,
												html : '&nbsp;'
											}, {
												columnWidth : 0.90,
												border : false,
												items : [ searchForm ]
											}, {
												border : false,
												columnWidth : 0.05,
												items : [ tagCloudViewPanel ]
											} ]
										} ]*/searchForm
									}, {// search results panel
										id : 'results',
										title : OpenLayers.i18n('List'),
//										autoScroll : true,
										layout : 'border',
										items : [
/*
* Modified by GVB
*/
								         /*
								         {// sidebar searchform
											region : 'west',
											id : 'west',
											border : true,
											width : 250,
											items : [ resultsMap ]
										},
										*/
								        {
											layout : 'fit',
											region : 'center',
											border : false,
//											autoScroll : true,
											items : resultsPanel
										} ],
										/*
										 * Hide tab panel until a search is done
										 * Seem "hidden:true" as in other places
										 * doesn't work for Tabs, and need to
										 * use a listener!
										 * 
										 * See
										 * http://www.sencha.com/forum/showthread.php?65441-Starting-A-Tab-Panel-with-a-Hidden-Tab
										 */
										listeners : {
											render : function(c) {
												c.ownerCt.hideTabStripItem(c);
											}
										}
									}
									/*
									 * Modified by GVB
									 */
									/*
									 * , {// map id : 'map', title :
									 * OpenLayers.i18n('Map'), layout : 'fit',
									 * margins : margins, listeners : { // Only
									 * initialized the map // application when
									 * the tab is // activated // then the
									 * layout is done and all // sub widget like
									 * printPanel could // access the map
									 * layout. activate : function (p) {
									 * p.add(iMap.getViewport()); p.doLayout(); } } }
									 */]
								}),
								{
									id : 'footer',
									region : 'south',
									align : 'left',
									bodyStyle : {
										'text-align' : 'left',
										padding : '0px 3px'
									},
									border : true,
									html : "<span class='madeBy'>"
											+ OpenLayers.i18n('Poweredby')
											+ " <a href='http://geonetwork-opensource.org/'><img style='width:80px' src='../images/default/gn-logo.png' title='GeoNetwork OpenSource' border='0' /></a></span></div>",
									layout : 'fit'
								} ]
					});

			// Hide advanced search options
/*
 * Removed by GVB
 */			
//			Ext.get("advSearchTabs").hide();

			// Ext.getCmp('mapprojectionselector').syncSize();
			// Ext.getCmp('mapprojectionselector').setWidth(130);

			/* Init form field URL according to URL parameters */
			GeoNetwork.util.SearchTools.populateFormFromParams(searchForm,
					urlParameters);

			/* Trigger search if search is in URL parameters */
			if (urlParameters.search !== undefined) {
				Ext.getCmp('searchBt').getEl().dom.click();
			}
			if (urlParameters.edit !== undefined && urlParameters.edit !== '') {
				catalogue.metadataEdit(urlParameters.edit);
			}
			if (urlParameters.create !== undefined) {
				resultPanel.getTopToolbar().createMetadataAction
						.fireEvent('click');
			}
			if (urlParameters.uuid !== undefined) {
				catalogue.metadataShow(urlParameters.uuid, true);
			} else if (urlParameters.id !== undefined) {
				catalogue.metadataShowById(urlParameters.id, true);
			}

			// FIXME : should be in Search field configuration
			Ext.get('E_any').setWidth(400);
			Ext.get('E_any').setHeight(28);

			metadataResultsView.addMap(Ext.getCmp('resultsMap').map);

			if (GeoNetwork.searchDefault.activeMapControlExtent) {
				Ext.getCmp('geometryMap').setExtent();
			}
			if (urlParameters.bounds) {
				Ext.getCmp('geometryMap').map
						.zoomToExtent(urlParameters.bounds);
			}

			// resultPanel.setHeight(Ext.getCmp('center').getHeight());

			var events = [ 'afterDelete', 'afterRating', 'afterLogout',
					'afterLogin' ];
			Ext.each(events, function(e) {
				catalogue.on(e, function() {
					if (searching === true) {
						Ext.getCmp('searchBt').getEl().dom.click();
					}

				});
			});

			// Hack to run search after all app is rendered within a sec ...
			// It could have been better to trigger event in
			// SearchFormPanel#applyState
			// FIXME
			if (urlParameters.s_search !== undefined) {
				setTimeout(function() {
					Ext.getCmp('searchBt').getEl().dom.click();
				}, 500);
			}

			initShortcut();
		},
		getIMap : function() {
			// init map if not yet initialized
			if (!iMap) {
				initMap();
			}

			// TODO : maybe we should switch to visualization mode also ?
			return iMap;
		},
		getHelpWindow : function() {
			return new Ext.Window({
				title : OpenLayers.i18n('Help'),
				layout : 'fit',
				height : 600,
				width : 600,
				closable : true,
				resizable : true,
				draggable : true,
				items : [ createHelpPanel() ]
			});
		},
		getAboutWindow : function() {
			return new Ext.Window({
				title : OpenLayers.i18n('About'),
				layout : 'fit',
				height : 600,
				width : 600,
				closable : true,
				resizable : true,
				draggable : true,
				items : [ creatAboutPanel() ]
			});
		},
		getCatalogue : function() {
			return catalogue;
		},
		getMetadataResultsView : function() {
			return metadataResultsView;
		},
		/**
		 * Do layout
		 * 
		 * @param response
		 * @return
		 */
        loadResults: function(response){
            
            // Show "List results" panel
            var tabPanel = Ext.getCmp("GNtabs");            
            tabPanel.unhideTabStripItem(tabPanel.items.itemAt(1));

            initPanels();

            // FIXME : result panel need to update layout in case of slider
            // Ext.getCmp('resultsPanel').syncSize();

            Ext.getCmp('previousBt').setDisabled(catalogue.startRecord === 1);
            Ext.getCmp('nextBt').setDisabled(catalogue.startRecord +
                parseInt(Ext.getCmp('E_hitsperpage').getValue(), 10) > catalogue.metadataStore.totalLength);
            if (Ext.getCmp('E_sortBy').getValue()) {
                Ext.getCmp('sortByToolBar').setValue(Ext.getCmp('E_sortBy').getValue()  + "#" + Ext.getCmp('sortOrder').getValue() );

            } else {
                Ext.getCmp('sortByToolBar').setValue(Ext.getCmp('E_sortBy').getValue());

            }


            // Fix for width sortBy combo in toolbar
            // See this: http://www.sencha.com/forum/showthread.php?122454-TabPanel-deferred-render-false-nested-toolbar-layout-problem
            Ext.getCmp('sortByToolBar').syncSize();
            Ext.getCmp('sortByToolBar').setWidth(130);
        
            resultsPanel.syncSize();
            

            //resultsPanel.setHeight(Ext.getCmp('center').getHeight());

            //Ext.getCmp('west').syncSize();
            //Ext.getCmp('center').syncSize();
            //Ext.ux.Lightbox.register('a[rel^=lightbox]');
        },
		/**
		 * Activate map tab
		 */
		switchMode : function() {
			setTab('map');
		},

		/*
		* Added by GVB
		*/
		toggleSearchType : function(button){
			var advSearchTabsPanel = Ext.getCmp("advSearchTabs");
			if (button.text==OpenLayers.i18n('Simple')) {
				button.setText(OpenLayers.i18n('Advanced'));
//				button.setTooltip(OpenLayers.i18n('advancedTooltip'));
				Ext
				.getCmp(
						'searchForm')
				.getForm()
				.reset();
				advSearchTabsPanel.collapse();
			} else {
				button.setText(OpenLayers.i18n('Simple'));
//				button.setTooltip(OpenLayers.i18n('simpleTooltip'));
				advSearchTabsPanel.expand();
			}
		}
				
	};
};

Ext.onReady(function() {
	var lang = /hl=([a-z]{3})/.exec(location.href);
	GeoNetwork.Util.setLang(lang && lang[1], '..');

	Ext.QuickTips.init();
	setTimeout(function() {
		Ext.get('loading').remove();
		Ext.get('loading-mask').fadeOut({
			remove : true
		});
	}, 250);

	app = new GeoNetwork.app();
	app.init();
	var openSearchSuggestionTextField = Ext.getCmp('openSearchSuggestionTextField');
	if (openSearchSuggestionTextField) {
		new Ext.KeyNav(openSearchSuggestionTextField.el, {
			"enter" : function(e){
				Ext.getCmp('searchBt').getEl().dom.click();
			}/*,
			scope: openSearchSuggestionTextField*/
		});
	}
	catalogue = app.getCatalogue();

	// overwrite default detail-click action
	catalogue.metadataShow = function(uuid) {
		var tabPanel = Ext.getCmp("GNtabs"), tabs = tabPanel.find('id', uuid);

		if (tabs[0]) {
			tabPanel.setActiveTab(tabs[0]);
		} else {
			// Retrieve information in synchrone mode todo: this doesn't work
			// here
			var store = GeoNetwork.data.MetadataResultsFastStore();
			catalogue.kvpSearch("fast=index&uuid=" + uuid, null, null, null,
					true, store, null, false);
			var record = store.getAt(store.find('uuid', uuid));

			var RowTitle = uuid;

			try {
				RowTitle = record.data.title;
			} catch (e) {
			}
			var RowLabel = RowTitle;
			if (RowLabel.length > 18) {
				RowLabel = RowLabel.substr(0, 17) + "...";
			}

			var aResTab = new GeoNetwork.view.ViewPanel({
				serviceUrl : catalogue.services.mdView + '?uuid=' + uuid,
				lang : catalogue.lang,
//				autoScroll : true,
				resultsView : app.getMetadataResultsView(),
				layout : 'fit',
				// autoHeight:true,
//				padding : '5px 25px',
				currTab : GeoNetwork.defaultViewMode || 'simple',
				printDefaultForTabs : GeoNetwork.printDefaultForTabs || false,
				catalogue : catalogue,
				// maximized: true,
				metadataUuid : uuid,
				record : record
			});

			// Override zoomToAction (maye better way?). TODO: Check as seem
			// calling old handler code
/*
 * Removed by GVB
 */
/*
			aResTab.actionMenu.zoomToAction.setHandler(function() {
				var uuid = this.record.get('uuid');
				this.resultsView.zoomTo(uuid);

				// Custom code to display Map tab
				tabPanel.setActiveTab(tabPanel.items.itemAt(2));
			}, aResTab.actionMenu);
*/
			aResTab.actionMenu.viewAction.hide();

			tabPanel.add({
				title : RowLabel,
				layout: 'fit',
				tabTip : RowTitle,
				iconCls : 'tabs',
				id : uuid,
				closable : true,
				items : [ aResTab ]
			}).show();
		}
	};
});
