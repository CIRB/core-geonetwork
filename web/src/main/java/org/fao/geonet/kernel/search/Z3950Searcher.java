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

package org.fao.geonet.kernel.search;

import org.jzkit.search.LandscapeSpecification;
import org.jzkit.search.SearchSessionFactory;
import org.jzkit.search.StatelessSearchResultsPageDTO;
import org.jzkit.search.impl.StatelessQueryService;
import org.jzkit.search.landscape.SimpleLandscapeSpecification;
import org.jzkit.search.provider.iface.IRQuery;
import org.jzkit.search.util.QueryModel.QueryModel;
import org.jzkit.search.util.QueryModel.PrefixString.PrefixString;
import org.jzkit.search.util.RecordModel.ArchetypeRecordFormatSpecification;
import org.jzkit.search.util.RecordModel.ExplicitRecordFormatSpecification;
import org.jzkit.search.util.RecordModel.InformationFragment;
import org.jzkit.search.util.RecordModel.RecordFormatSpecification;
import org.jzkit.search.util.ResultSet.IRResultSetStatus;
import org.jzkit.service.z3950server.ZSetInfo;

import java.io.File;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.Vector;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Result;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import jeeves.exceptions.BadParameterEx;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.lib.Lib;
import org.jdom.Element;
import org.jdom.input.DOMBuilder;
import org.springframework.context.ApplicationContext;
import org.w3c.dom.Document;

//--------------------------------------------------------------------------------
// search metadata remotely using Z39.50
//--------------------------------------------------------------------------------

class Z3950Searcher extends MetaSearcher
{
	//public final static int EXECUTING = SearchTask.TASK_EXECUTING;
	//public final static int FAILURE   = SearchTask.TASK_FAILURE;
	//public final static int COMPLETE  = SearchTask.TASK_COMPLETE;
	//public final static int IDLE      = SearchTask.TASK_IDLE;

	private SearchManager _sm;
	private String        _styleSheetName;
	private int size = 0;
	private int status = 0;

	//private SearchTask    _st;
	private boolean				_html;

	private ZSetInfo zinfo ;
	RecordFormatSpecification def_request_spec = new ArchetypeRecordFormatSpecification("F");
	RecordFormatSpecification def_html_request_spec = new ArchetypeRecordFormatSpecification("H");

	//--------------------------------------------------------------------------------
	// constructor
	public Z3950Searcher(SearchManager sm, String styleSheetName)
	{
		_sm             = sm;
		_styleSheetName = styleSheetName;
	}

	//--------------------------------------------------------------------------------
	// MetaSearcher API

	public void search(ServiceContext srvContext, Element request, ServiceConfig config) throws Exception
	{
		Dbms dbms = (Dbms) srvContext.getResourceManager().open(Geonet.Res.MAIN_DB);

		Log.debug(Geonet.SEARCH_ENGINE, "CRITERIA:\n"+ Xml.getString(request));
		String query  = request.getChildText(Geonet.SearchResult.ZQUERY);

		// --  process params if we don't have a fully specified zquery 
		if (query == null) { 
			request.addContent(Lib.db.select(dbms, "Regions", "region"));

			Element xmlQuery = _sm.transform(_styleSheetName, request);

			Log.debug(Geonet.SEARCH_ENGINE, "OUTGOING XML QUERY:\n"+ Xml.getString(xmlQuery));
			query = newQuery(xmlQuery);
		}

		Log.debug(Geonet.SEARCH_ENGINE, "OUTGOING QUERY: " + query);

		// get request parameters
		Vector servers = new Vector();
		for (Iterator iter = request.getChildren(Geonet.SearchResult.SERVERS).iterator(); iter.hasNext(); )
		{
			String server = ((Element)iter.next()).getText();
			servers.add(server);
		}
		String sTimeout  = request.getChildText("timeout");
		int timeout;
		if (sTimeout == null) timeout = 10;
		else
		{
			try { timeout = Integer.parseInt(sTimeout); }
			catch (NumberFormatException nfe) { throw new IllegalArgumentException("Bad 'timeout' parameter parameter: " + sTimeout); }
		}
		String sHtml  = request.getChildText("serverhtml");
		_html = sHtml.equals("on");

		// perform the search
		// initialize the collection
		Vector collection_ids = new Vector();
		for (int i = 0; i < servers.size(); i++)
		{
			String name = (String)servers.elementAt(i);
			collection_ids.add(name);
		}

		QueryModel qm = new PrefixString(query);

		// get hold of JZKit SearchSession
		StatelessQueryService sqs = getQueryService(srvContext);

		LandscapeSpecification landscape = new SimpleLandscapeSpecification( collection_ids );
		ExplicitRecordFormatSpecification exp = null;

		Log.debug(Geonet.SEARCH_ENGINE, "Starting remote search");

		String query_id = null;

		// search, but not retrieve
		StatelessSearchResultsPageDTO res = sqs.getResultsPageFor(query_id, qm , landscape  , 0, 0, def_request_spec, exp, null);

		this.status = res.getSearchStatus();
		if ( res.getSearchStatus() == IRResultSetStatus.FAILURE ) {
		 	Log.debug(Geonet.SEARCH_ENGINE, "failure during search");
		} else {
			this.zinfo = new ZSetInfo(query_id, qm, landscape);
			this.size = res.total_hit_count;
		}

		Log.debug(Geonet.SEARCH_ENGINE, "Remote search completed. Status is : "+ getStatus());
		initSearchRange(srvContext);
	}

	//-----------------------------------------------------------------------------

	private StatelessQueryService getQueryService(ServiceContext srvContext) {
		GeonetContext gc = (GeonetContext) srvContext.getHandlerContext(Geonet.CONTEXT_NAME);
		ApplicationContext app_context = gc.getApplicationContext();
		StatelessQueryService sqs = (StatelessQueryService)app_context.getBean("StatelessQueryService");
		return sqs;
	}

	//-----------------------------------------------------------------------------

	public Element present(ServiceContext srvContext, Element request, ServiceConfig config) throws Exception {
		Log.debug(Geonet.SEARCH_ENGINE, "Presenting Z39.50 record for request:\n" + Xml.getString(request));
		updateSearchRange(request);

		// get results
		Element response =  new Element("response");
		response.setAttribute("from",  getFrom()+"");
		response.setAttribute("to",    getTo()+""); 

		Log.debug(Geonet.SEARCH_ENGINE, "Range is from:"+ getFrom() +", to:"+getTo());

		Element summary = makeSummary();
		response.addContent(summary);

		if (getTo() > 0)
		{
			StatelessQueryService sqs = getQueryService(srvContext);
			InformationFragment fragshtml[] = null;

			if (_html) {
				ExplicitRecordFormatSpecification htmlrfs = new ExplicitRecordFormatSpecification("html", null, "f");
				StatelessSearchResultsPageDTO res = sqs.getResultsPageFor(this.zinfo.getSetname(),this.zinfo.getQueryModel(),this.zinfo.getLandscape(),getFrom(),getTo(),def_html_request_spec,htmlrfs,null);
				fragshtml = res.records; 
			}

			ExplicitRecordFormatSpecification rfs = new ExplicitRecordFormatSpecification("xml", null, "f");
			StatelessSearchResultsPageDTO res = sqs.getResultsPageFor(this.zinfo.getSetname(),this.zinfo.getQueryModel(),this.zinfo.getLandscape(),getFrom(),getTo(),def_request_spec,rfs,null);
			InformationFragment frags[] = res.records;

			// FIXME: we may not get all the records we want back sometimes!
			int theLimit = Math.min(getPageSize(),frags.length);
			for (int i = 0; i < theLimit; i++) {
				InformationFragment fraghtml = null;
				if (_html) {
					fraghtml = fragshtml[i];
				}
				InformationFragment frag = frags[i];
				try {
					DOMBuilder builder = new DOMBuilder();
	
					org.w3c.dom.Document doc = (Document)frag.getOriginalObject();
					org.w3c.dom.Element  el  = doc.getDocumentElement();
					Element md = builder.build(el);
					md.detach();

					String elementFileName = "none";
					String htmlError = "";
					if (_html) {
						Object docObj = fraghtml.getOriginalObject();
						if (docObj instanceof org.w3c.dom.Document) {
							org.w3c.dom.Document dochtml = (Document)fraghtml.getOriginalObject();	
							String fileid = UUID.randomUUID().toString();
							String filename = srvContext.getAppPath()+_sm.getHtmlCacheDir()+File.separator+fileid+".html";
							elementFileName = srvContext.getBaseUrl()+"/"+_sm.getHtmlCacheDir()+"/"+fileid+".html";
							File outHtmlFile = new File(filename);
							try {
								Transformer xformer = TransformerFactory.newInstance().newTransformer();
								xformer.setOutputProperty(OutputKeys.METHOD, "text");
								Source source = new DOMSource(dochtml);
								Result result = new StreamResult(outHtmlFile.toURI().getPath());
								xformer.transform(source,result);
							} catch (TransformerConfigurationException e) {
								e.printStackTrace();
							} catch (TransformerException e) {
								e.printStackTrace();
							}
						} else {
							htmlError = "HTML result not available. Error message: "+docObj.toString();
						}
					}
	
					Element info = new Element(Edit.RootChild.INFO, Edit.NAMESPACE);
					md.removeChild(Edit.RootChild.INFO, Edit.NAMESPACE);

					addElement(info, Edit.Info.Elem.ID,     (getFrom() + i)+"");
					addElement(info, Edit.Info.Elem.SERVER, frag.getSourceRepositoryID());
					addElement(info, Edit.Info.Elem.COLLECTION, frag.getSourceCollectionName());
					if (_html) {
						Element html = new Element(Edit.Info.Elem.HTML).setText(elementFileName);
						if (!htmlError.equals("")) html.setAttribute("error", htmlError);
						info.addContent(html);
					}

					md.addContent(info);

					response.addContent(md);
				} catch (Exception ex) {
					ex.printStackTrace();
					Element error = new Element("error");;
					error.setAttribute("server",  frag.getSourceRepositoryID());
					error.setAttribute("collection",  frag.getSourceCollectionName());
					error.setAttribute("id",      (getFrom() + i)+"");
					error.setAttribute("message", ex.getClass().getName() + ": " + ex.getMessage());
					Log.error(Geonet.SEARCH_ENGINE, "Exception raised during Z3950 search and retrieval "+" Server: "+error.getAttributeValue("server")+" id: "+error.getAttributeValue("id"));
					response.addContent(error);
				}
			}

			// if we didn't get all results for a page then something went wrong!
			for (int i = theLimit; i < getPageSize();i++) {
				Element error = new Element("error");;
				error.setAttribute("message", "Unable to retrieve record "+(getFrom()+i));
				response.addContent(error);
			}
		}
		Log.debug(Geonet.SEARCH_ENGINE, "Presented metadata is:\n" + Xml.getString(response));

		return response;
	}

	//-----------------------------------------------------------------------------

	public int getSize()
	{
		return this.size;
	}

	//-----------------------------------------------------------------------------

	public Element getSummary()
	{
		Element response =  new Element("response");
		response.addContent(makeSummary());
		return response;
	}

	//-----------------------------------------------------------------------------
	/** closes the connection(s)
	  */
	public void close()
	{
	}

	//--------------------------------------------------------------------------------
	// private methods

	// makes a new query
	private String newQuery(Element xmlQuery) throws Exception
	{
		String name = xmlQuery.getName();
		if (name.equals("query"))
		{
			String attrset = xmlQuery.getAttributeValue("attrset");
			List children = xmlQuery.getChildren();
			if (children.size() == 0)
				throw new BadParameterEx("Z39.50-query", Xml.getString(xmlQuery));

			Element child = (Element)children.get(0);
			return "@attrset " + attrset + " " + newQuery(child);
		}
		else if (name.equals("and") || name.equals("or") || name.equals("not"))
		{
			Element leftChild  = (Element)xmlQuery.getChildren().get(0);
			Element rightChild = (Element)xmlQuery.getChildren().get(1);
			return "@" + name + " " + newQuery(leftChild) + " " + newQuery(rightChild);
		}
		else if (name.equals("term"))
		{
			String  use       = xmlQuery.getAttributeValue("use");
			String  structure = xmlQuery.getAttributeValue("structure");
			String  relation  = xmlQuery.getAttributeValue("relation");
			String  text      = xmlQuery.getText();

			StringBuffer term = new StringBuffer();
			if (use       != null) term.append("@attr 1=" + use       + " ");
			if (structure != null) term.append("@attr 4=" + structure + " ");
			if (relation  != null) term.append("@attr 2=" + relation  + " ");
			boolean toQuote = !isAlpha(text);
			if (toQuote) term.append('"');
			term.append(text);
			if (toQuote) term.append('"');
			return term.toString();
		}
		else throw new Exception("unknown Z39.50 query type: " + name);
	}

	//-----------------------------------------------------------------------------

	private boolean isAlpha(String text)
	{
		for (int i = 0; i < text.length(); i++)
			if (!Character.isLetter(text.charAt(i))) return false;
		return true;
	}

	//-----------------------------------------------------------------------------

	private Element makeSummary()
	{
		Log.debug(Geonet.SEARCH_ENGINE, "z3590 searcher: makeSummary with: size:" +  this.size + " status: "+this.status + "\n");
		Element summary = new Element("summary");
		summary.setAttribute("count", getSize()+"");
		summary.setAttribute("status", getStatus());
		summary.setAttribute("type", "remote");
		if (_html)
			summary.setAttribute("format","html");
		else
			summary.setAttribute("format","xml");

		return summary;
	}

	//-----------------------------------------------------------------------------
	/** returns the current status
	  */
	private String getStatus()
	{
		return IRResultSetStatus.getCode(this.status);
	}

	//-----------------------------------------------------------------------------

	private int getPageSize() {
		return (getTo() - getFrom()) + 1;	
	}
}