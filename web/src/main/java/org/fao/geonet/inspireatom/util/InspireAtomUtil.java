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
package org.fao.geonet.inspireatom.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import jeeves.exceptions.BadInputEx;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.AtomFeedNotFoundEx;
import org.fao.geonet.exceptions.MetadataNotFoundEx;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.lib.Lib;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * Utility class for INSPIRE Atom.
 *
 * @author Jose García
 */
public class InspireAtomUtil {


    /** Service uuid param name **/
	public static final String SERVICE_IDENTIFIER_PARAM = "fileIdentifier";

    /** Dataset identifier param name **/
    public static final String DATASET_IDENTIFIER_CODE_PARAM = "spatial_dataset_identifier_code";

    /** Dataset namespace param name **/
    public static final String DATASET_IDENTIFIER_NS_PARAM = "spatial_dataset_identifier_namespace";

    /** Dataset crs param name **/
    public static final String DATASET_CRS_PARAM = "crs";
    
    /** Service identifier param name **/
    public static final String SERVICE_IDENTIFIER = "id";

    /** Xslt process to get the related dataset identifiers in service metadata. **/
    public static final String EXTRACT_DATASET_IDENTIFIERS = "extract-dataset-identifiers.xsl";

    /** Xslt process to get the related dataset fileidentifiers in service metadata. **/
    public static final String EXTRACT_DATASET_FILEIDENTIFIERS = "extract-dataset-fileidentifiers.xsl";

    /** Xslt process to get the related datasets in service metadata. **/
    public static final String EXTRACT_DATASET_ENTRY_INFO = "extract-dataset-entry-info.xsl";

    /** Xslt process to get if a metadata is a service or a dataset. **/
    public static final String EXTRACT_MD_TYPE = "extract-type.xsl";

    /** Xslt process to get the atom feed link from the metadata. **/
    public static final String EXTRACT_ATOM_FEED = "extract-atom-feed.xsl";

    /**
     * Filters a dataset feed removing all the downloads that are not related to the CRS provided.
     *
     * This method changes feed content.
     *
     * @param feed          JDOM element with dataset feed content.
     * @param crs           CRS to use in the filter.
     *
     * @throws Exception    Exception.
     */
    public static List<String> getDatasetsCrsList(final Element datasetFeed,
                                              final String crs)
            throws Exception {

        List<String> crsList = new ArrayList<String>();

        Iterator it = datasetFeed.getChildren().iterator();

        // Filters the entry elements for the CRS, creating a list of entry elements to remove from the feed.
        while (it.hasNext()) {
            Element el = (Element) it.next();
            String name = el.getName();
            if (name.equalsIgnoreCase("categoryTerm")) {
                    String term = el.getAttributeValue("term");
                if (!StringUtils.contains(term, crs)) {
                    crsList.add(term);
                }
            }
        }
        return crsList;
    }

    public static boolean isServiceMetadata(DataManager dm, /*String schema, */Element md) throws Exception {
        String styleSheet = dm.getSchemaDir("iso19139") + "extract-type.xsl";
        String mdType = Xml.transform(md, styleSheet).getText().trim();
        return "service".equalsIgnoreCase(mdType);
    }

    public static boolean isDatasetMetadata(DataManager dm, /*String schema, */Element md) throws Exception {
        String styleSheet = dm.getSchemaDir("iso19139") + "extract-type.xsl";
        Map<String, String> paramsM = new HashMap<String, String>();
        String mdType = Xml.transform(md, styleSheet, paramsM).getText().trim();

        return "dataset".equalsIgnoreCase(mdType);
    }

    public static boolean isAtomDownloadServiceMetadata(DataManager dm, /*String schema, */Element md) throws Exception {
        String styleSheet = dm.getSchemaDir("iso19139") + "extract-service-type.xsl";
        Element service = Xml.transform(md, styleSheet);
        String serviceType = service.getChildText("serviceType").trim();
        String serviceTypeVersion = service.getChildText("serviceTypeVersion").trim();
        return "download".equalsIgnoreCase(serviceType) && "INSPIRE ATOM V3.1".equalsIgnoreCase(serviceTypeVersion);
    }

    public static List<String> extractRelatedDatasetIdentifiers(/*final String schema, */final Element md, final DataManager dataManager)
            throws Exception {
        String styleSheet = dataManager.getSchemaDir("iso19139") + EXTRACT_DATASET_IDENTIFIERS;
        List<Element> identifiersEl = Xml.transform(md, styleSheet).getChildren();
        List<String> identifiers = new ArrayList<String>();

        //--- needed to detach md from the document
        md.detach();

        for (Element identifierEl: identifiersEl) {
            String identifier = identifierEl.getText();

            if (!StringUtils.isEmpty(identifier)) identifiers.add(identifier);
        }

        return identifiers;
    }

    public static List<String> extractRelatedDatasetFileIdentifiers(/*final String schema, */final Element md, final DataManager dataManager)
            throws Exception {
        String styleSheet = dataManager.getSchemaDir("iso19139") + EXTRACT_DATASET_FILEIDENTIFIERS;
        List<Element> fileIdentifiersEl = Xml.transform(md, styleSheet).getChildren();
        List<String> fileIdentifiers = new ArrayList<String>();

        //--- needed to detach md from the document
        md.detach();

        for (Element fileIdentifierEl: fileIdentifiersEl) {
            String fileIdentifier = fileIdentifierEl.getText();

            if (!StringUtils.isEmpty(fileIdentifier)) fileIdentifiers.add(fileIdentifier);
        }

        return fileIdentifiers;
    }

    public static Element extractDatasetEntryInfo(/*final String schema, */final Element md, final DataManager dataManager)
            throws Exception {
        String styleSheet = dataManager.getSchemaDir("iso19139") + EXTRACT_DATASET_ENTRY_INFO;
        Element datasetEl = Xml.transform(md, styleSheet);
        md.detach();
        return datasetEl;
    }


    public static Map<String, String> retrieveServiceMetadataWithAtomFeeds(final DataManager dataManager, final String schema, String id,
                                                                           final Element md,
                                                                           final String atomProtocol)
            throws Exception {

        return processAtomFeedsInternal(dataManager, schema, id, md, "service", atomProtocol);
    }

    public static Map<String, String> retrieveDatasetMetadataWithAtomFeeds(final DataManager dataManager, final String schema, String id,
                                                                           final Element md,
                                                                           final String atomProtocol)
            throws Exception {

        return processAtomFeedsInternal(dataManager, schema, id, md, "dataset", atomProtocol);
    }

    private static Map<String, String> processAtomFeedsInternal(DataManager dataManager, String schema, String id,
                                                                Element md, String type,
                                                                String atomProtocol) throws Exception {

        Map<String, String> metadataAtomFeeds = new HashMap<String, String>();

        String atomFeed = extractAtomFeedUrl(schema, md, dataManager, atomProtocol);

        if (StringUtils.isNotEmpty(atomFeed)) {
            metadataAtomFeeds.put(id + "", atomFeed);
        }

        return metadataAtomFeeds;
    }

    /**
     *
     * @param schema        Metadata schema.
     * @param md            JDOM element with metadata content.
     * @param dataManager   DataManager.
     * @return              Atom feed URL.
     * @throws Exception    Exception.
     */
    public static String extractAtomFeedUrl(final String schema,
                                            final Element md,
                                            final DataManager dataManager, String atomProtocol)
            throws Exception {
        String styleSheet = dataManager.getSchemaDir(schema) + EXTRACT_ATOM_FEED;
        Map<String, String> params = new HashMap<String, String>();
        params.put("atomProtocol", atomProtocol);

        String atomFeed = Xml.transform(md, styleSheet, params).getText().trim();

        //--- needed to detach md from the document
        md.detach();

        return atomFeed;
    }

    public static String getFileIdentifierByDatasetIdentifier(ServiceContext context, String datasetIdentifier) throws Exception {
    	String datasetUuid = null;
		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
        String fieldName = "_uuid";
        List<String> fieldnames = new ArrayList<String>();
        fieldnames.add(fieldName);
        Map<String,String> fieldsMap =  LuceneSearcher.getMetadataFromIndex(webappName, context.getLanguage(), "identifier", datasetIdentifier, fieldnames);
        // If dataset metadata not found, ignore
        if (!fieldsMap.isEmpty() && !StringUtils.isBlank(fieldsMap.get(fieldName))) {
        	datasetUuid = fieldsMap.get(fieldName);
    	}
        return datasetUuid;
    }

    public static Element getDatasetFeed(Element params, ServiceContext context) throws Exception {
        String datasetIdCode = Util.getParam(params, DATASET_IDENTIFIER_CODE_PARAM);
        String datasetIdNs = Util.getParam(params, DATASET_IDENTIFIER_NS_PARAM);
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		Log.debug(Geonet.ATOM, "Processing dataset feed  (" + InspireAtomUtil.DATASET_IDENTIFIER_CODE_PARAM + ": " +
                datasetIdCode);

    	String fileIdentifier = InspireAtomUtil.getFileIdentifierByDatasetIdentifier(context, datasetIdCode);
        if (!StringUtils.isBlank(fileIdentifier)) {
	        // Retrieve metadata to check existence and permissions.
	        String id = dm.getMetadataId(dbms, fileIdentifier);
	        if (StringUtils.isEmpty(id)) throw new MetadataNotFoundEx(fileIdentifier);

            Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);
            Element md = dm.getMetadata(dbms, id);
            if (!InspireAtomUtil.isDatasetMetadata(dm, /*schema, */md)) {
                throw new Exception("No dataset metadata found with uuid:" + fileIdentifier);
            }
            
            List<Namespace> nss = new ArrayList<Namespace>();
            nss.addAll(md.getAdditionalNamespaces());
            nss.add(md.getNamespace());
            Object o = Xml.selectSingle(md, "gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString|gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString", nss);
            if (o!=null && o instanceof Element) {
            	String codeSpaceValue = ((Element)o).getText();
            	{
                    if (!StringUtils.isBlank(codeSpaceValue) && codeSpaceValue.equals(datasetIdNs)) {
                		Element datasetEl = new Element("dataset");
                		try {
                			return datasetEl.addContent(InspireAtomUtil.getDatasetEntryInfo(fileIdentifier, context));
                		} catch (AtomFeedNotFoundEx e) {
                        	throw new AtomFeedNotFoundEx(fileIdentifier);
                		}
                    }
            	}
            }
        	throw new MetadataNotFoundEx(fileIdentifier);
        } else {
        	throw new MetadataNotFoundEx(fileIdentifier);
        }
    }

    public static Element getServiceFeed(String fileIdentifier, ServiceContext context) throws Exception {
        Log.debug(Geonet.ATOM, "Processing service feed  (" + SERVICE_IDENTIFIER + ": " + fileIdentifier +  " )");

		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        String id = dm.getMetadataId(dbms, fileIdentifier);
        if (StringUtils.isEmpty(id)) throw new MetadataNotFoundEx(fileIdentifier);

        // Check if allowed to the metadata
        Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);

		Element serviceEl = new Element("service");
        // Check if it is a service metadata
        Element md = dm.getMetadata(dbms, id);
//        String schema = dm.getMetadataSchema(dbms, id);
        if (!InspireAtomUtil.isServiceMetadata(dm, /*schema, */md)) {
            throw new Exception("No service metadata found with uuid:" + fileIdentifier);
        }

        if (!InspireAtomUtil.isAtomDownloadServiceMetadata(dm, /*schema, */md)) {
            throw new Exception("No ATOM download service metadata found with uuid:" + fileIdentifier);
        }

        // Get dataset identifiers referenced by service metadata.
        List<String> datasetFileIdentifiers = null;

        datasetFileIdentifiers = InspireAtomUtil.extractRelatedDatasetFileIdentifiers(/*schema, */md, dm);
        
		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
//        String keywords =  LuceneSearcher.getMetadataFromIndex(webappName, context.getLanguage(), fileIdentifier, "keyword");

        // Process datasets information
        Element datasetsEl = processDatasetsInfo(dm, dbms, datasetFileIdentifiers, fileIdentifier, context, webappName);

        // Build response.
        return serviceEl.addContent(md.addContent(datasetsEl));
    }
 
    public static Element getDatasetEntryInfo(String datasetFileIdentifier, ServiceContext context) throws Exception {
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        if (!StringUtils.isBlank(datasetFileIdentifier)) {
	        // Retrieve metadata to check existence and permissions.
	        String id = dm.getMetadataId(dbms, datasetFileIdentifier);
	        if (StringUtils.isEmpty(id)) throw new MetadataNotFoundEx(datasetFileIdentifier);

	        Element md = dm.getMetadata(dbms, id);
//	        String schema = dm.getMetadataSchema(dbms, id);
            Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);
            // Get dataset identifiers referenced by service metadata.
            Element entry = InspireAtomUtil.extractDatasetEntryInfo(/*schema, */md, dm);
            if (entry.getChildren().size()>0) {
            	return entry;
            } else {
            	throw new AtomFeedNotFoundEx(datasetFileIdentifier);
            }
        } else {
        	throw new MetadataNotFoundEx(datasetFileIdentifier);
        }
    }

    private static Element processDatasetsInfo(DataManager dm, Dbms dbms, final List<String> datasetFileIdentifiers, final String serviceIdentifier,
            final ServiceContext context, String webappName)
            		throws Exception {
		Element datasetsEl = new Element("datasets");

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);

		for (String fileIdentifier : datasetFileIdentifiers) {
			try {
				datasetsEl.addContent(/*InspireAtomUtil.getDatasetFeed(
						datasetIdentifier, context)*/InspireAtomUtil.getDatasetEntryInfo(fileIdentifier, context));
			} catch (MetadataNotFoundEx e) {
				Log.debug(Geonet.ATOM, "Dataset with id " + fileIdentifier
						+ " not exists (uuid: " + e.toString() + ")");
			} catch (AtomFeedNotFoundEx e) {
				Log.debug(Geonet.ATOM, "Dataset with id " + fileIdentifier
						+ " has no download url with application profile INSPIRE-Download-Atom (uuid: " + e.toString() + ")");
			}		
		}
		return datasetsEl;
	}
    
    public static int countDatasetsForCrs(Element params, ServiceContext context) throws Exception {
        String datasetIdCode = Util.getParam(params, DATASET_IDENTIFIER_CODE_PARAM);
        String datasetIdNs = Util.getParam(params, DATASET_IDENTIFIER_NS_PARAM);
        int downloadCount = 0;
        Element entry = getDatasetFeed(params, context);
        return 0;
    }
}