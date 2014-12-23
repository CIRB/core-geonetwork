//=============================================================================
//===	Copyright (C) 2001-2010 Food and Agriculture Organization of the
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
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * Service to get a data file related to dataset.
 *
 * This service if a dataset has only 1 download format for a CRS returns the file,
 * otherwise returns a feed with downloads for the dataset.
 *
 * @author Jose García
 */
public class AtomGetData implements Service {

    public void init(String appPath, ServiceConfig params) throws Exception {

    }

    //--------------------------------------------------------------------------
    //---
    //--- Exec
    //---
    //--------------------------------------------------------------------------

    public Element exec(Element params, ServiceContext context) throws Exception
    {
        String datasetIdCode = Util.getParam(params, InspireAtomUtil.DATASET_IDENTIFIER_CODE_PARAM);
        String datasetIdNs = Util.getParam(params, InspireAtomUtil.DATASET_IDENTIFIER_NS_PARAM);
        String datasetCrs = Util.getParam(params, InspireAtomUtil.DATASET_CRS_PARAM);
        String styleSheet = context.getAppPath() + File.separator + Geonet.Path.STYLESHEETS + File.separator + "inspire-atom-feed.xsl";
        Element datasetAtomFeed = Xml.transform(new Element("root").addContent(InspireAtomUtil.getDatasetFeed(datasetIdCode, datasetIdNs, context)), styleSheet);
        Namespace ns = datasetAtomFeed.getNamespace();
        Map<Integer, Element> result = countDatasetsForCrs(datasetAtomFeed, datasetCrs, ns);
        int downloadCount = result.keySet().iterator().next();
        Element selectedEntry = result.get(downloadCount);

        // No download  for the CRS specified
        if (downloadCount == 0) {
            throw new Exception("No downloads available for dataset: " + datasetIdCode +  " and CRS: " + datasetCrs);

        // Only one download for the CRS specified
        } else if (downloadCount == 1) {
        	String type = null;
        	Element link = selectedEntry.getChild("link", ns);
        	if (link!=null) {
        		type = link.getAttributeValue("type");
        	}
            // Jeeves checks for <reponse redirect="true" url="...." mime-type="..." /> to manage about redirecting
            // to the provided file
            return new Element("response")
                    .setAttribute("redirect", "true")
                    .setAttribute("url", selectedEntry.getChildText("id",ns))
                    .setAttribute("mime-type",type);

        // Otherwise, return a feed with the downloads for the specified CRS
        } else {
            // Retrieve the dataset feed
            // Filter the dataset feed by CRS code.
            InspireAtomUtil.filterDatasetFeedByCrs(datasetAtomFeed, datasetCrs, ns);

            return datasetAtomFeed;
        }
    }

    private Map<Integer,Element> countDatasetsForCrs(Element datasetAtomFeed, String datasetCrs, Namespace ns) {
        int downloadCount = 0;
        Map<Integer,Element> entryMap = new HashMap<Integer, Element>();
        Element selectedEntry = null;
        Iterator<Element> entries = (datasetAtomFeed.getChildren("entry", ns)).iterator();
        while(entries.hasNext()) {
        	Element entry = entries.next();
        	Element category = entry.getChild("category",ns);
        	if (category!=null) {
            	String term = category.getAttributeValue("term");
	           if (datasetCrs.equals(term)) {
	                selectedEntry = entry;
	                downloadCount++;
	            }
        	}
        }
        entryMap.put(downloadCount, selectedEntry);
        return entryMap;
    }
}