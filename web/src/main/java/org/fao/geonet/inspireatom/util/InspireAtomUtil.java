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
import org.fao.geonet.exceptions.MultipleMetadataRecordsEx;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.main.Result;
import org.fao.geonet.services.main.Search;
import org.h2.command.dml.SelectUnion;
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

	/** Query param name **/
	public static final String DATASET_Q_PARAM = "q";

	/**
	 * Xslt process to get the related dataset fileidentifiers in service
	 * metadata.
	 **/
	public static final String EXTRACT_DATASET_FILEIDENTIFIERS = "extract-dataset-fileidentifiers.xsl";

	/** Xslt process to get the related datasets in service metadata. **/
	public static final String EXTRACT_DATASET_ENTRY_INFO = "extract-dataset-entry-info.xsl";

	/** Xslt process to get if a metadata is a service or a dataset. **/
	public static final String EXTRACT_MD_TYPE = "extract-type.xsl";

	/** Xslt process to get the atom feed link from the metadata. **/
	public static final String EXTRACT_ATOM_FEED = "extract-atom-feed.xsl";

	public static final String ATOM_SERVICE_TYPE_VERSION = "INSPIRE ATOM V3.1";

	public static final String ATOM_SERVICE_TYPE = "download";

	public static boolean isServiceMetadata(DataManager dm, /* String schema, */
			Element md) throws Exception {
		String styleSheet = dm.getSchemaDir("iso19139") + "extract-type.xsl";
		String mdType = Xml.transform(md, styleSheet).getText().trim();
		return "service".equalsIgnoreCase(mdType);
	}

	public static boolean isDatasetMetadata(DataManager dm, /* String schema, */
			Element md) throws Exception {
		String styleSheet = dm.getSchemaDir("iso19139") + "extract-type.xsl";
		Map<String, String> paramsM = new HashMap<String, String>();
		String mdType = Xml.transform(md, styleSheet, paramsM).getText().trim();

		return "dataset".equalsIgnoreCase(mdType);
	}

	public static boolean isAtomDownloadServiceMetadata(DataManager dm, /*
																		 * String
																		 * schema
																		 * ,
																		 */
			Element md) throws Exception {
		String styleSheet = dm.getSchemaDir("iso19139")
				+ "extract-service-type.xsl";
		Element service = Xml.transform(md, styleSheet);
		String serviceType = service.getChildText("serviceType").trim();
		String serviceTypeVersion = service.getChildText("serviceTypeVersion")
				.trim();
		return ATOM_SERVICE_TYPE.equalsIgnoreCase(serviceType)
				&& ATOM_SERVICE_TYPE_VERSION.equalsIgnoreCase(serviceTypeVersion);
	}

	public static List<String> extractRelatedDatasetIdentifiers(
			/* final String schema, */final Element md,
			final DataManager dataManager) throws Exception {
		String styleSheet = dataManager.getSchemaDir("iso19139")
				+ EXTRACT_DATASET_IDENTIFIERS;
		List<Element> identifiersEl = Xml.transform(md, styleSheet)
				.getChildren();
		List<String> identifiers = new ArrayList<String>();

		// --- needed to detach md from the document
		md.detach();

		for (Element identifierEl : identifiersEl) {
			String identifier = identifierEl.getText();

			if (!StringUtils.isEmpty(identifier))
				identifiers.add(identifier);
		}

		return identifiers;
	}

	public static List<String> extractRelatedDatasetFileIdentifiers(
			/* final String schema, */final Element md,
			final DataManager dataManager) throws Exception {
		String styleSheet = dataManager.getSchemaDir("iso19139")
				+ EXTRACT_DATASET_FILEIDENTIFIERS;
		List<Element> fileIdentifiersEl = Xml.transform(md, styleSheet)
				.getChildren();
		List<String> fileIdentifiers = new ArrayList<String>();

		// --- needed to detach md from the document
		md.detach();

		for (Element fileIdentifierEl : fileIdentifiersEl) {
			String fileIdentifier = fileIdentifierEl.getText();

			if (!StringUtils.isEmpty(fileIdentifier))
				fileIdentifiers.add(fileIdentifier);
		}

		return fileIdentifiers;
	}

	public static Element extractDatasetEntryInfo(
			/* final String schema, */final Element md,
			final DataManager dataManager) throws Exception {
		String styleSheet = dataManager.getSchemaDir("iso19139")
				+ EXTRACT_DATASET_ENTRY_INFO;
		Element datasetEl = Xml.transform(md, styleSheet);
		md.detach();
		return datasetEl;
	}

	public static Map<String, String> retrieveServiceMetadataWithAtomFeeds(
			final DataManager dataManager, final String schema, String id,
			final Element md, final String atomProtocol) throws Exception {

		return processAtomFeedsInternal(dataManager, schema, id, md, "service",
				atomProtocol);
	}

	public static Map<String, String> retrieveDatasetMetadataWithAtomFeeds(
			final DataManager dataManager, final String schema, String id,
			final Element md, final String atomProtocol) throws Exception {

		return processAtomFeedsInternal(dataManager, schema, id, md, "dataset",
				atomProtocol);
	}

	private static Map<String, String> processAtomFeedsInternal(
			DataManager dataManager, String schema, String id, Element md,
			String type, String atomProtocol) throws Exception {

		Map<String, String> metadataAtomFeeds = new HashMap<String, String>();

		String atomFeed = extractAtomFeedUrl(schema, md, dataManager,
				atomProtocol);

		if (StringUtils.isNotEmpty(atomFeed)) {
			metadataAtomFeeds.put(id + "", atomFeed);
		}

		return metadataAtomFeeds;
	}

	/**
	 *
	 * @param schema
	 *            Metadata schema.
	 * @param md
	 *            JDOM element with metadata content.
	 * @param dataManager
	 *            DataManager.
	 * @return Atom feed URL.
	 * @throws Exception
	 *             Exception.
	 */
	public static String extractAtomFeedUrl(final String schema,
			final Element md, final DataManager dataManager, String atomProtocol)
			throws Exception {
		String styleSheet = dataManager.getSchemaDir(schema)
				+ EXTRACT_ATOM_FEED;
		Map<String, String> params = new HashMap<String, String>();
		params.put("atomProtocol", atomProtocol);

		String atomFeed = Xml.transform(md, styleSheet, params).getText()
				.trim();

		// --- needed to detach md from the document
		md.detach();

		return atomFeed;
	}

	public static String getFileIdentifierByDatasetIdentifier(
			ServiceContext context, String datasetIdentifier) throws Exception {
		String datasetUuid = null;
		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
		String fieldName = "_uuid";
		List<String> fieldnames = new ArrayList<String>();
		fieldnames.add(fieldName);
		Map<String, String> fieldsMap = LuceneSearcher.getMetadataFromIndex(
				webappName, context.getLanguage(), "identifier",
				datasetIdentifier, fieldnames);
		// If dataset metadata not found, ignore
		if (!fieldsMap.isEmpty()
				&& !StringUtils.isBlank(fieldsMap.get(fieldName))) {
			datasetUuid = fieldsMap.get(fieldName);
		}
		return datasetUuid;
	}

	public static Element getDatasetFeed(Element params, ServiceContext context, String datasetIdCode, String datasetIdNs, Search search, Result result)
			throws Exception {
		Element identifiers = getIdentifiersBySearch(params, context, datasetIdCode, "identifier", search, result);
		switch (identifiers.getChildren().size()) {
			case 0:
				throw new MetadataNotFoundEx(datasetIdCode);
			case 1:
				String fileIdentifier = identifiers.getChildText("identifier");
				if (!StringUtils.isBlank(fileIdentifier)) {
					GeonetContext gc = (GeonetContext) context
							.getHandlerContext(Geonet.CONTEXT_NAME);
					DataManager dm = gc.getDataManager();
					Dbms dbms = (Dbms) context.getResourceManager()
							.open(Geonet.Res.MAIN_DB);

					Log.debug(Geonet.ATOM, "Processing dataset feed  ("
							+ InspireAtomUtil.DATASET_IDENTIFIER_CODE_PARAM + ": "
							+ datasetIdCode);
					// Retrieve metadata to check existence and permissions.
					String id = dm.getMetadataId(dbms, fileIdentifier);
					if (StringUtils.isEmpty(id)) {
						throw new MetadataNotFoundEx(fileIdentifier);
					}
					Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);
					Element md = dm.getMetadata(dbms, id);
					if (!InspireAtomUtil.isDatasetMetadata(dm, /* schema, */md)) {
						throw new Exception("No dataset metadata found with uuid:"
								+ fileIdentifier);
					}
					boolean bCodeSpaceValueIsEqual = false;
					if (!StringUtils.isBlank(datasetIdNs)) {
						List<Namespace> nss = new ArrayList<Namespace>();
						try {
							nss = dm.getSchema(dm.autodetectSchema(md)).getSchemaNS();
						} catch (Exception e) {
							nss.addAll(md.getAdditionalNamespaces());
							nss.add(md.getNamespace());
						}
						Object o = Xml
								.selectSingle(
										md,
										"gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString|gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString",
										nss);
						if (o != null && o instanceof Element) {
							String codeSpaceValue = ((Element) o).getText();
							if (!StringUtils.isBlank(codeSpaceValue)
									&& codeSpaceValue.equals(datasetIdNs)) {
								bCodeSpaceValueIsEqual = true;
							}
						}
					} else {
						bCodeSpaceValueIsEqual = true;
					}
					if (bCodeSpaceValueIsEqual) {
						Element datasetEl = new Element("dataset");
			    		ThesaurusManager thesaurusMan = gc.getThesaurusManager();
			    		datasetEl.addContent(new Element("thesauriDir").setText(thesaurusMan.getThesauriDirectory()));
						try {
							Element datasetEntryInfo = InspireAtomUtil
									.getDatasetEntryInfo(fileIdentifier,
											context);
							String crs = null;
							try {
								crs = Util.getParam(params,
										DATASET_CRS_PARAM);
							} catch (Exception e) {
							}
							if (!StringUtils.isBlank(crs)) {
								datasetEl.addContent(new Element("crs").setText(crs));
							}
							String serviceIdentifier = getUplink(context, datasetIdCode, search, result);
							if (StringUtils.isNotBlank(serviceIdentifier)) {
								datasetEl.addContent(new Element("serviceIdentifier").setText(serviceIdentifier));
							}
							return datasetEl.addContent(datasetEntryInfo);
						} catch (AtomFeedNotFoundEx e) {
							throw new AtomFeedNotFoundEx(fileIdentifier);
						}
					}
					throw new MetadataNotFoundEx(fileIdentifier);
				} else {
					throw new MetadataNotFoundEx(fileIdentifier);
				}
			default:
				throw new MultipleMetadataRecordsEx(datasetIdCode);
		}
	}

	private static String getUplink(ServiceContext context, String datasetIdCode, Search search,
			Result result) {
		try {
			Element identifiers = getIdentifiersBySearch(null, context, datasetIdCode, "operatesOn", search, result);
			if (identifiers.getChildren().size()==1) {
				String fileIdentifier = identifiers.getChildText("identifier");
				if (!StringUtils.isBlank(fileIdentifier)) {
					return fileIdentifier;
				}
			}
		} catch (Exception e) {
		}
		return null;
	}

	public static Element getIdentifiersBySearch(Element params, ServiceContext context, String datasetIdCode, String mainSearchFieldName, Search search, Result result)
			throws Exception {
		Element identifiersEl = new Element("identifiers");
		Element request = new Element("request");
		if (mainSearchFieldName.equals("identifier")) {
			request.addContent(new Element("has_atom").setText("true"));
		} else {
			request.addContent(new Element("serviceType").setText(ATOM_SERVICE_TYPE));
		}
		request.addContent(new Element("fast").setText("true"));
		if (!StringUtils.isEmpty(datasetIdCode)) {
			request.addContent(new Element(mainSearchFieldName).setText(datasetIdCode));
		}
		String searchTerms = null;
		try {
			searchTerms = Util.getParam(params,
					DATASET_Q_PARAM);
		} catch (Exception e) {
		}
		if (!StringUtils.isEmpty(searchTerms)) {
			request.addContent(new Element("any").setText(searchTerms));
		}
	    search.exec(request, context);
	    Element searchResult = result.exec(request, context);
		List<?> nodes = Xml.selectNodes(searchResult,
				"metadata/*/uuid");
		if (nodes != null) {
			for (Object node : nodes) {
				identifiersEl.addContent(new Element("identifier").setText(((Element)node).getText()));
			}
		}
	    return identifiersEl;
	}

	public static String getKeywordsByFileIdentifier(ServiceContext context, String fileIdentifier, Search search, Result result)
			throws Exception {
		List<String> keywords = new ArrayList<String>();
		Element request = new Element("request");
		request.addContent(new Element("fileId").setText(fileIdentifier));
		request.addContent(new Element("fast").setText("true"));
	    search.exec(request, context);
	    Element searchResult = result.exec(request, context);
		List<?> nodes = Xml.selectNodes(searchResult,
				"summary/keywords/keyword");
		if (nodes != null) {
			for (Object node : nodes) {
				keywords.add(((Element)node).getAttributeValue("name"));
			}
		}
	    return StringUtils.join(keywords.toArray(),", ");
	}

	public static Element getServiceFeed(String fileIdentifier,
			ServiceContext context, List<String> selectedDatasetFileIdentifiers) throws Exception {
		Log.debug(Geonet.ATOM, "Processing service feed  ("
				+ SERVICE_IDENTIFIER + ": " + fileIdentifier + " )");

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager()
				.open(Geonet.Res.MAIN_DB);

		String id = dm.getMetadataId(dbms, fileIdentifier);
		if (StringUtils.isEmpty(id))
			throw new MetadataNotFoundEx(fileIdentifier);

		// Check if allowed to the metadata
		Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);

		Element serviceEl = new Element("service");
		// Check if it is a service metadata
		Element md = dm.getMetadata(dbms, id);
		// String schema = dm.getMetadataSchema(dbms, id);
		if (!InspireAtomUtil.isServiceMetadata(dm, /* schema, */md)) {
			throw new Exception("No service metadata found with uuid:"
					+ fileIdentifier);
		}

		if (!InspireAtomUtil
				.isAtomDownloadServiceMetadata(dm, /* schema, */md)) {
			throw new Exception(
					"No ATOM download service metadata found with uuid:"
							+ fileIdentifier);
		}

		// Get dataset identifiers referenced by service metadata.
		List<String> datasetFileIdentifiers = null;

		datasetFileIdentifiers = InspireAtomUtil
				.extractRelatedDatasetFileIdentifiers(/* schema, */md, dm);

		String baseURL = context.getBaseUrl();
		String webappName = baseURL.substring(1);
		// String keywords = LuceneSearcher.getMetadataFromIndex(webappName,
		// context.getLanguage(), fileIdentifier, "keyword");

		// Process datasets information
		Element datasetsEl = processDatasetsInfo(dm, dbms,
				datasetFileIdentifiers, selectedDatasetFileIdentifiers, fileIdentifier, context, webappName);

		// Build response.
		return serviceEl.addContent(md.addContent(datasetsEl));
	}

	public static Element getDatasetEntryInfo(String datasetFileIdentifier,
			ServiceContext context) throws Exception {
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager dm = gc.getDataManager();
		Dbms dbms = (Dbms) context.getResourceManager()
				.open(Geonet.Res.MAIN_DB);

		if (!StringUtils.isBlank(datasetFileIdentifier)) {
			// Retrieve metadata to check existence and permissions.
			String id = dm.getMetadataId(dbms, datasetFileIdentifier);
			if (StringUtils.isEmpty(id))
				throw new MetadataNotFoundEx(datasetFileIdentifier);

			Element md = dm.getMetadata(dbms, id);
			// String schema = dm.getMetadataSchema(dbms, id);
			Lib.resource.checkPrivilege(context, id, AccessManager.OPER_VIEW);
			// Get dataset identifiers referenced by service metadata.
			Element entry = InspireAtomUtil.extractDatasetEntryInfo(
					/* schema, */md, dm);
			if (entry.getChildren().size() > 0) {
				return entry;
			} else {
				throw new AtomFeedNotFoundEx(datasetFileIdentifier);
			}
		} else {
			throw new MetadataNotFoundEx(datasetFileIdentifier);
		}
	}

	private static Element processDatasetsInfo(DataManager dm, Dbms dbms,
			final List<String> datasetFileIdentifiers, final List<String> selectedDatasetFileIdentifiers,
			final String serviceIdentifier, final ServiceContext context,
			String webappName) throws Exception {
		Element datasetsEl = new Element("datasets");

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);

		for (String fileIdentifier : datasetFileIdentifiers) {
			try {
				if (selectedDatasetFileIdentifiers!=null && !selectedDatasetFileIdentifiers.contains(fileIdentifier)) {
					continue;
				}
				datasetsEl.addContent(/*
									 * InspireAtomUtil.getDatasetFeed(
									 * datasetIdentifier, context)
									 */InspireAtomUtil.getDatasetEntryInfo(
						fileIdentifier, context));
			} catch (MetadataNotFoundEx e) {
				Log.debug(Geonet.ATOM, "Dataset with id " + fileIdentifier
						+ " not exists (uuid: " + e.toString() + ")");
			} catch (AtomFeedNotFoundEx e) {
				Log.debug(
						Geonet.ATOM,
						"Dataset with id "
								+ fileIdentifier
								+ " has no download url with application profile INSPIRE-Download-Atom (uuid: "
								+ e.toString() + ")");
			}
		}
		return datasetsEl;
	}

	public static void filterDatasetFeedByCrs(final Element feed,
			final String crs, final Namespace ns) throws Exception {

		List<Element> elementsToRemove = new ArrayList<Element>();

		Iterator it = feed.getChildren().iterator();

		// Filters the entry elements for the CRS, creating a list of entry
		// elements to remove from the feed.
		while (it.hasNext()) {
			Element el = (Element) it.next();
			String name = el.getName();
			if (name.equalsIgnoreCase("entry")) {
				Element catEl = el.getChild("category", ns);
				if (catEl != null) {
					String term = catEl.getAttributeValue("term");
					if (!StringUtils.contains(term, crs)) {
						elementsToRemove.add(el);
					}
				}
			}
		}

		// Remove entry elements that are not related to the filter CRS
		for (Element element : elementsToRemove) {
			element.getParent().removeContent(element);
		}
	}
}