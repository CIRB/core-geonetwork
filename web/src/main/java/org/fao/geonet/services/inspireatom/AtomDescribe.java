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


import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.jdom.Element;

/**
 * Service to get Atom feed.
 *
 * @author Jose García
 */
public class AtomDescribe implements Service {

    public void init(String appPath, ServiceConfig params) throws Exception {

    }

    //--------------------------------------------------------------------------
    //---
    //--- Exec
    //---
    //--------------------------------------------------------------------------

    public Element exec(Element params, ServiceContext context) throws Exception
    {
        String fileIdentifier = Util.getParam(params, InspireAtomUtil.SERVICE_IDENTIFIER, "");

        if (StringUtils.isEmpty(fileIdentifier)) {
            return InspireAtomUtil.getDatasetFeed(params, context);
        } else {
            return InspireAtomUtil.getServiceFeed(fileIdentifier, context);
        }
    }

}