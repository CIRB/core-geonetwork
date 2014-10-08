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

package org.fao.geonet.services.metadata;

import java.util.ArrayList;
import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.jdom.Element;
import org.jdom.Namespace;

//=============================================================================

/** Inserts a new metadata to the system (data is validated)
  */

public class XmlChildElementTextUpdate implements Service
{
	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

    private String stylePath;

	public void init(String appPath, ServiceConfig params) throws Exception
    {
        this.stylePath = appPath + Geonet.Path.UPDATE_STYLESHEETS;
    }

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		Element response = new Element(Jeeves.Elem.RESPONSE);
		Element modifiedRecords = new Element("modified");
		response.addContent(modifiedRecords);
		Element unchangedRecords = new Element("unchanged");
		Element unchangedByErrorRecords = new Element("unchangedbyerror");
		response.addContent(unchangedRecords);
		String childTextValue = Util.getParam(params, "childTextValue", "");
		String xpathExpression = Util.getParam(params, "xpathExpression", "");
		String uuids      = Util.getParam(params, "uuids", "");
		List<Element> userGroups = params.getChildren(Params.GROUPS);

		String filterChoice = Util.getParam(params, "filterChoice", "");
        if (!StringUtils.isBlank(xpathExpression) && !StringUtils.isBlank(filterChoice) &&
        		((filterChoice.equals("1") && !StringUtils.isBlank(uuids)) ||
				(filterChoice.equals("2") && userGroups!=null && userGroups.size()>0) ||
				filterChoice.equals("3")) && !StringUtils.isBlank(childTextValue)) {
    		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
			DataManager dm = gc.getDataManager();
	        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
	        List<String> uuidList = new ArrayList<String>();
	        String whereClause = getWhereClause(uuidList, filterChoice, uuids, userGroups);
            Element result = dbms.select("SELECT id, schemaid, uuid FROM metadata " + whereClause + " ORDER BY id ASC");
            for(int i = 0; i < result.getContentSize(); i++) {
                Element record = (Element) result.getContent(i);
                String id = record.getChildText("id");
                String uuid = record.getChildText("uuid");
            	try {
                    Element md = dm.getMetadataNoInfo(context, id);
    	            if (md == null) {
    	                continue;
    	            }
    	            md.detach();
    	            boolean isModified = false;
                    List<Namespace> nss = new ArrayList<Namespace>();
                    nss.addAll(md.getAdditionalNamespaces());
                    nss.add(md.getNamespace());
                    Object extentObject = Xml.selectSingle(md, "gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent", nss);
            		System.out.println("Processing record with uuid " + uuid);
            		if (extentObject!=null) {
                        System.out.println(Xml.getString((Element)extentObject));
            		}
                    Object o = Xml.selectSingle(md, xpathExpression, nss);
                    if (o!=null && o instanceof Element) {
                    	String oldChildTextValue = ((Element)o).getText(); 
                    	((Element)o).setText(childTextValue);
                    	if (!childTextValue.equals(oldChildTextValue)) {
        	                dm.getXmlSerializer().update(dbms, id, md, null, false, context);
        	                dbms.commit();
        	            	isModified = true;
    	            		System.out.println("Updated");
    	                    modifiedRecords.addContent(new Element(Params.UUID).setText(uuid + " (" + oldChildTextValue + "->" + childTextValue + ")"));
                    	}
    				}
        	        if (!isModified) {
	            		unchangedRecords.addContent(new Element(Params.UUID).setText(uuid));
    	            }
            	} catch (Exception e) {
            		unchangedByErrorRecords.addContent(new Element(Params.UUID).setText(uuid));
            	}
            	if (uuidList!=null) {
            		uuidList.remove(uuid);
            	}
            }
        	if (uuidList!=null) {
	            for (String uuid : uuidList) {
	        		unchangedRecords.addContent(new Element(Params.UUID).setText(uuid + " harvested"));
	            }
        	}
        }
		return response;
	}

	private String getWhereClause(List<String> uuidList, String filterChoice, String uuids, List<Element> userGroups) {
		String whereClause = "where not (isharvested='y') and istemplate='n' and schemaid in ('iso19139','iso19139.geobru')";
		int filter = Integer.parseInt(filterChoice);
		switch(filter) {
			case 1:
		        uuids = uuids.replaceAll("\\s+","");
		        if (!StringUtils.isBlank(uuids)) {
		        	whereClause += " and uuid in ('" + uuids.replaceAll("\'","").replaceAll(",","\',\'") + "')";
		        	CollectionUtils.addAll(uuidList,uuids.split(","));
		        }
				break;
			case 2:
				List<String> groupIdList = new ArrayList<String>();
				for(Element group : userGroups) {
					groupIdList.add(group.getText());
				}
				whereClause += " and id in (select metadataid from operationallowed where groupid in (" + StringUtils.join(groupIdList, "','") + ") and operationid = '2')"; 
				break;
			case 3:
				break;
		}
		return whereClause;
	};

}

//=============================================================================


