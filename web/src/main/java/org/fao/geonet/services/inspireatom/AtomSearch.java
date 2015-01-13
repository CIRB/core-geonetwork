//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.services.inspireatom;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.MetadataNotFoundEx;
import org.fao.geonet.guiservices.schemas.GetSchemaInfo;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.main.Result;
import org.fao.geonet.services.main.Search;
import org.jdom.Element;

import com.google.common.base.Joiner;

/**
 * INSPIRE atom search service.
 *
 * @author Jose García
 */
public class AtomSearch implements Service
{
    private Search search = new Search();
    private Result result = new Result();

    public void init(String appPath, ServiceConfig params) throws Exception {
        search.init(appPath, params);
        result.init(appPath, params);
    }

    //--------------------------------------------------------------------------
    //---
    //--- Exec
    //---
    //--------------------------------------------------------------------------

    public Element exec(Element params, ServiceContext context) throws Exception
    {
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        String fileIdentifier = params.getChildText("fileIdentifier");

		// If fileIdentifier is provided search only in the related datasets
        if (StringUtils.isNotEmpty(fileIdentifier)) {
            String id = dm.getMetadataId(dbms, fileIdentifier);
            if (id == null) throw new MetadataNotFoundEx("Metadata not found.");

            Element md = dm.getMetadata(dbms, id);
//            String schema = dm.getMetadataSchema(dbms, id);

            // Check if allowed to the metadata
            Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);

            // Retrieve the datasets related to the service metadata
            List<String> datasetIdentifiers = InspireAtomUtil.extractRelatedDatasetIdentifiers(/*schema, */md, dm);
            String values = Joiner.on(" or ").join(datasetIdentifiers);
    		Element request = new Element("request");
//    		request.addContent(new Element("serviceTypeVersion").setText(InspireAtomUtil.ATOM_SERVICE_TYPE_VERSION));
    		request.addContent(new Element("serviceType").setText(InspireAtomUtil.ATOM_SERVICE_TYPE));
    		request.addContent(new Element("fast").setText("true"));
            request.addContent(new Element("identifier").setText(values));
    		String searchTerms = null;
    		try {
    			searchTerms = Util.getParam(params,
    					InspireAtomUtil.DATASET_Q_PARAM);
    		} catch (Exception e) {
    		}
    		if (!StringUtils.isEmpty(searchTerms)) {
    			request.addContent(new Element("any").setText(searchTerms));
    		}
            search.exec(request, context);
    	    Element searchResult = result.exec(request, context);
    	    List<String> selectedDatasetFileIdentifiers = new ArrayList<String>();
    	    List<?> nodes = Xml.selectNodes(searchResult,
    				"metadata/*/uuid");
    		if (nodes != null) {
    			for (Object node : nodes) {
    				selectedDatasetFileIdentifiers.add(((Element)node).getText());
    			}
    		}
        	return InspireAtomUtil.getServiceFeed(fileIdentifier, context, selectedDatasetFileIdentifiers);
        }
        throw new MetadataNotFoundEx("The fileIdentifier is required in the url");
    }
}