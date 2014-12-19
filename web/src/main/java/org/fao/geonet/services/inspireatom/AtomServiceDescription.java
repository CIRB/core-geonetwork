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

import java.util.List;

import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.MetadataNotFoundEx;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.lib.Lib;
import org.jdom.Element;

/**
 * INSPIRE OpenSearchDescription atom service.
 *
 * @author Jose García
 *
 */
public class AtomServiceDescription implements Service
{
    public void init(String appPath, ServiceConfig params) throws Exception {

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

        String fileIdentifier = Util.getParam(params, InspireAtomUtil.SERVICE_IDENTIFIER_PARAM, "");
        if (StringUtils.isEmpty(fileIdentifier)) {
            return new Element("response");
        }

        String id = dm.getMetadataId(dbms, fileIdentifier);
        if (id == null) throw new MetadataNotFoundEx("Metadata not found.");

        Element md = dm.getMetadata(dbms, id);
//        String schema = dm.getMetadataSchema(dbms, id);

        // Check if allowed to the metadata
        Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);

        // Check if it is a service metadata
        if (!InspireAtomUtil.isServiceMetadata(dm, /*schema, */md)) {
            throw new Exception("No service metadata found with uuid:" + fileIdentifier);
        }

        if (!InspireAtomUtil.isAtomDownloadServiceMetadata(dm, /*schema, */md)) {
            throw new Exception("No ATOM download service metadata found with uuid:" + fileIdentifier);
        }

        // Get dataset identifiers referenced by service metadata.
        List<String> datasetIdentifiers = null;

        datasetIdentifiers = InspireAtomUtil.extractRelatedDatasetIdentifiers(/*schema, */md, dm);
        
		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
        String keywords =  LuceneSearcher.getMetadataFromIndex(webappName, context.getLanguage(), fileIdentifier, "keyword");

        return InspireAtomUtil.getDatasetFeed(params, context);
    }
}