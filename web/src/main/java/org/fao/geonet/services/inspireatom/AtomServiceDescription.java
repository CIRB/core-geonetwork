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
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.jdom.Element;
import org.jdom.Namespace;

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
		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
        String fileIdentifier = Util.getParam(params, InspireAtomUtil.SERVICE_IDENTIFIER, "");
        if (!StringUtils.isEmpty(fileIdentifier)) {
            String keywords = LuceneSearcher.getMetadataFromIndex(webappName, context.getLanguage(), fileIdentifier, "keyword");
        	Element service = InspireAtomUtil.getServiceFeed(fileIdentifier, context);
            String styleSheet = context.getAppPath() + File.separator + Geonet.Path.STYLESHEETS + File.separator + "inspire-atom-feed.xsl";
            Element serviceAtomFeed = Xml.transform(new Element("root").addContent(service), styleSheet);
            Namespace ns = serviceAtomFeed.getNamespace();
            Element response = new Element("response");
            response.addContent(new Element("fileId").setText(fileIdentifier));
            response.addContent(new Element("title").setText(serviceAtomFeed.getChildText("title",ns)));
            response.addContent(new Element("subtitle").setText(serviceAtomFeed.getChildText("subtitle",ns)));
            response.addContent(new Element("lang").setText(context.getLanguage()));
            if (!StringUtils.isEmpty(keywords)) {
            	response.addContent(new Element("keywords").setText(keywords));
            }
            response.addContent(new Element("authorName").setText(serviceAtomFeed.getChild("author",ns).getChildText("name",ns)));
            response.addContent(new Element("url").setText(serviceAtomFeed.getChildText("id",ns)));
            Element datasetsEl = new Element("datasets");
            response.addContent(datasetsEl);
            Namespace inspiredlsns = serviceAtomFeed.getNamespace("inspire_dls");
            Iterator<Element> datasets = (serviceAtomFeed.getChildren("entry", ns)).iterator();
            while(datasets.hasNext()) {
				Element dataset = datasets.next();
				String datasetIdCode = dataset.getChildText("spatial_dataset_identifier_code", inspiredlsns);
				String datasetIdNs = dataset.getChildText("spatial_dataset_identifier_namespace", inspiredlsns);
	            Element datasetAtomFeed = Xml.transform(new Element("root").addContent(InspireAtomUtil.getDatasetFeed(datasetIdCode, datasetIdNs, context)), styleSheet);
				Element datasetEl = buildDatasetInfo(datasetIdCode,datasetIdNs);
	            datasetEl.addContent(new Element("atom_url").setText(datasetAtomFeed.getChildText("id",ns)));
				datasetsEl.addContent(datasetEl);
	            Map<String, Integer> downloadsCountByCrs = new HashMap<String, Integer>();
	            Iterator<Element> entries = (datasetAtomFeed.getChildren("entry", ns)).iterator();
	            while(entries.hasNext()) {
	            	Element entry = entries.next();
	            	Element category = entry.getChild("category",ns);
	            	if (category!=null) {
		            	String term = category.getAttributeValue("term");
		                Integer count = downloadsCountByCrs.get(term);
		                if (count == null) {
		                	count = new Integer(0);
		                }
		                downloadsCountByCrs.put(term, count + 1);
	            	}
	            }
	            entries = (datasetAtomFeed.getChildren("entry", ns)).iterator();
	            while(entries.hasNext()) {
	            	Element entry = entries.next();
	            	Element category = entry.getChild("category",ns);
	            	if (category!=null) {
		            	String term = category.getAttributeValue("term");
		                Integer count = downloadsCountByCrs.get(term);
		                if (count != null) {
		                    Element downloadEl = new Element("file");
		                    String title = entry.getChildText("title",ns);
		                    int iPos = title.indexOf(" in  -");
		                    if (iPos>-1) {
		                    	title = title.substring(0,iPos);
		                    }
		                    downloadEl.addContent(new Element("title").setText(title));
		                    downloadEl.addContent(new Element("lang").setText(context.getLanguage()));
		                    downloadEl.addContent(new Element("url").setText(entry.getChildText("id",ns)));
		                    if (count > 1) {
		                        downloadEl.addContent(new Element("type").setText("application/atom+xml"));
		                    } else {
		                    	Element link = entry.getChild("link", ns);
		                    	if (link!=null) {
		                    		downloadEl.addContent(new Element("type").setText(link.getAttributeValue("type")));
		                    	}
		                    }
		                    downloadEl.addContent(new Element("crs").setText(term));
		                    datasetEl.addContent(downloadEl);
	
		                    // Remove from map to not process further downloads with same CRS,
		                    // only 1 entry with type= is added in result
		                    downloadsCountByCrs.remove(term);
		                }
	            	}
	            }
            }
            return response;
        } else {
            throw new Exception("No service metadata found with uuid:" + fileIdentifier);        	
        }
    }
	/**
	 * Builds JDOM element for dataset information.
	 *
	 * @param identifier    Dataset identifier.
	 * @param namespace     Dataset namespace.
	 * @return
	 */
	private Element buildDatasetInfo(final String identifier, final String namespace) {
	    Element datasetEl = new Element("dataset");
	
	    Element codeEl = new Element("code");
	    codeEl.setText(identifier);
	
	    Element namespaceEl = new Element("namespace");
	    namespaceEl.setText(namespace);
	
	    datasetEl.addContent(codeEl);
	    datasetEl.addContent(namespaceEl);
	
	    return datasetEl;
	}
}