//=============================================================================
//===   Copyright (C) 2011 Food and Agriculture Organization of the
//===   United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===   and United Nations Environment Programme (UNEP)
//===
//===   This program is free software; you can redistribute it and/or modify
//===   it under the terms of the GNU General Public License as published by
//===   the Free Software Foundation; either version 2 of the License, or (at
//===   your option) any later version.
//===
//===   This program is distributed in the hope that it will be useful, but
//===   WITHOUT ANY WARRANTY; without even the implied warranty of
//===   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===   General Public License for more details.
//===
//===   You should have received a copy of the GNU General Public License
//===   along with this program; if not, write to the Free Software
//===   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===   Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===   Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.services.subtemplate;

import java.util.ArrayList;
import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.jdom.Attribute;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * Retrieve sub template from metadata table
 * @author francois
 *
 */
public class Get implements Service {

    private static final char SEPARATOR = '~';

    public void init(String appPath, ServiceConfig params) throws Exception {
    }

    /**
     * Execute the service and return the sub template. 
     * 
     * <p>
     * Sub template are all public - no privileges check. Parameter "uuid" is mandatory.
     * </p>
     * 
     * <p>
     * One or more "process" parameters could be added in order to alter the template extracted.
     * This parameter is composed of one XPath expression pointing to a single {@link Element} or {@link Attribute}
     * and a text value separated by "{@value #SEPARATOR}". Warning, when pointing to an element, the content
     * of the element is removed before the value added (See {@link Element#setText(String)}).
     * </p>
     * 
     * <p>
     * For example, to return a contact template with a custom role use 
     * "&process=gmd:role/gmd:CI_RoleCode/@codeListValue~updatedRole".
     * </p>
     * 
     */
    public Element exec(Element params, ServiceContext context)
            throws Exception {
    	String uuid = null;
    	String root = null;
    	String child = null;
    	String title = null;
    	Element param = params.getChild(Params.UUID);
    	if (param!=null) {
            uuid = param.getTextTrim();
    	}
    	param = params.getChild(Params.ROOT);
    	if (param!=null) {
    		root = param.getTextTrim();
    		int iPos = root.indexOf(";");
    		if (iPos>-1) {
        		title = root.substring(iPos+1);
        		if (title.startsWith("AtomServiceFeed")) {
        			Element processEl = new Element(Params.PROCESS);
        			params.addContent(processEl);
        			GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        			DataManager     dm = gc.getDataManager();
        		    String operationName = "";
        		    int iPos2 = title.indexOf(":");
        		    if (iPos2 > -1) {
        		    	operationName = title.substring(iPos2+1);
        		    	title = title.substring(0,iPos2);
        		    }
        			processEl.setText("gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" + SEPARATOR +
        					dm.getSiteUrl() + context.getBaseUrl() + "/opensearch/" + context.getLanguage() + "/" + uuid + "/" + operationName);
        		}
        		root = root.substring(0,iPos);
    		}
        	param = params.getChild(Params.CHILD);
        	if (param!=null) {
        		child = param.getTextTrim();
        	}
    	}
        
        // Retrieve template
        Dbms dbms = (Dbms) context.getResourceManager().open (Geonet.Res.MAIN_DB);
        Element rec = null;
        if (StringUtils.isNotBlank(root)) {
            if (StringUtils.isNotBlank(child)) {
            	rec = dbms.select("SELECT data FROM metadata WHERE isTemplate = 's' AND root = ? AND data like ?", root, "%" + child + "%");
            } else {
            	if (title!=null) {
                	rec = dbms.select("SELECT data FROM metadata WHERE isTemplate = 's' AND root = ? AND title = ?", root, title);            	
            	} else {
                	rec = dbms.select("SELECT data FROM metadata WHERE isTemplate = 's' AND root = ?", root);            	
            	}
            }
        } else {
        	rec = dbms.select("SELECT data FROM metadata WHERE isTemplate = 's' AND uuid = ?", uuid);
        }
        String xmlData = null;
        List<Element> records = rec.getChildren(Jeeves.Elem.RECORD);
        if (records.size() > 0) {
            xmlData = records.get(0).getChildText("data");
        }
/*
        if (records.size() > 1 && title!=null) {
        	for (Element record : records) {
        		if (record.getChildText("data").contains(searchText)) {
                    xmlData = record.getChildText("data");
                    break;
        		}
        	}
        }
*/
        rec = Xml.loadString(xmlData, false);
        Element tpl = (Element) rec.detach();
        
        
        // Processing parameters process=xpath~value.
        // xpath must point to an Element or an Attribute.
        List<?> replaceList = params.getChildren(Params.PROCESS);
        for (Object replace : replaceList) {
            if (replace instanceof Element) {
                String parameters = ((Element) replace).getText();
                int endIndex = parameters.indexOf(SEPARATOR);
                
                if (endIndex == -1) {
                    continue;
                }
                String xpath = parameters.substring(0, endIndex);
                String value = parameters.substring(endIndex + 1);
                
                List<Namespace> nss = new ArrayList();
                nss.addAll(rec.getAdditionalNamespaces());
                nss.add(rec.getNamespace());
                Object o = Xml.selectSingle(tpl, xpath, nss);
                if (o instanceof Element) {
                    ((Element)o).setText(value);        // Remove all content before adding the value.
                } else if (o instanceof Attribute) {
                    ((Attribute)o).setValue(value);
                }
            }
        }
        
        return tpl;
    }
}
