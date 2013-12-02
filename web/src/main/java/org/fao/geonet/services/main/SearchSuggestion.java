//=============================================================================
//===	Copyright (C) 2010 Food and Agriculture Organization of the
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

package org.fao.geonet.services.main;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.text.StrBuilder;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.MetaSearcher;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.services.util.SearchDefaults;
import org.jdom.Element;

/**
 * Browse the index for a field and return a list of suggestion. Suggested terms
 * <b>contains</b> the query string.
 * 
 * The response body is converted to JSON using search-suggestion.xsl
 * 
 * To be improved : does not take care of privileges. Suggested terms could come
 * from private metadata records.
 * 
 * OpenSearch suggestion specification:
 * http://www.opensearch.org/Specifications/
 * OpenSearch/Extensions/Suggestions/1.0
 */
public class SearchSuggestion implements Service {
	private ServiceConfig _config;
	/**
	 * Max number of term's values to look in the index. For large catalogue
	 * this value should be increased in order to get better results. If this
	 * value is too high, then looking for terms could take more times. The use
	 * of good analyzer should allow to reduce the number of useless values like
	 * (a, the, ...).
	 */
	private Integer _maxNumberOfTerms;

	/**
	 * Minimum frequency for a term value to be proposed in suggestion.
	 */
	private Integer _threshold;

	/**
	 * Default field to search in. any is full-text search field.
	 */
	private static String _defaultSearchField = "any";

    private static String[] specialChars =  {"À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "ß", "à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ñ", "ò", "ó", "ô", "õ", "ö", "ø", "ù", "ú", "û", "ü", "ý", "ÿ", "Ā", "ā", "Ă", "ă", "Ą", "ą", "Ć", "ć", "Ĉ", "ĉ", "Ċ", "ċ", "Č", "č", "Ď", "ď", "Đ", "đ", "Ē", "ē", "Ĕ", "ĕ", "Ė", "ė", "Ę", "ę", "Ě", "ě", "Ĝ", "ĝ", "Ğ", "ğ", "Ġ", "ġ", "Ģ", "ģ", "Ĥ", "ĥ", "Ħ", "ħ", "Ĩ", "ĩ", "Ī", "ī", "Ĭ", "ĭ", "Į", "į", "İ", "ı", "Ĳ", "ĳ", "Ĵ", "ĵ", "Ķ", "ķ", "Ĺ", "ĺ", "Ļ", "ļ", "Ľ", "ľ", "Ŀ", "ŀ", "Ł", "ł", "Ń", "ń", "Ņ", "ņ", "Ň", "ň", "ŉ", "Ō", "ō", "Ŏ", "ŏ", "Ő", "ő", "Œ", "œ", "Ŕ", "ŕ", "Ŗ", "ŗ", "Ř", "ř", "Ś", "ś", "Ŝ", "ŝ", "Ş", "ş", "Š", "š", "Ţ", "ţ", "Ť", "ť", "Ŧ", "ŧ", "Ũ", "ũ", "Ū", "ū", "Ŭ", "ŭ", "Ů", "ů", "Ű", "ű", "Ų", "ų", "Ŵ", "ŵ", "Ŷ", "ŷ", "Ÿ", "Ź", "ź", "Ż", "ż", "Ž", "ž", "ſ", "ƒ", "Ơ", "ơ", "Ư", "ư", "Ǎ", "ǎ", "Ǐ", "ǐ", "Ǒ", "ǒ", "Ǔ", "ǔ", "Ǖ", "ǖ", "Ǘ", "ǘ", "Ǚ", "ǚ", "Ǜ", "ǜ", "Ǻ", "ǻ", "Ǽ", "ǽ", "Ǿ", "ǿ"};
    private static String[] normalChars = {"A", "A", "A", "A", "A", "A", "AE", "C", "E", "E", "E", "E", "I", "I", "I", "I", "D", "N", "O", "O", "O", "O", "O", "O", "U", "U", "U", "U", "Y", "s", "a", "a", "a", "a", "a", "a", "ae", "c", "e", "e", "e", "e", "i", "i", "i", "i", "n", "o", "o", "o", "o", "o", "o", "u", "u", "u", "u", "y", "y", "A", "a", "A", "a", "A", "a", "C", "c", "C", "c", "C", "c", "C", "c", "D", "d", "D", "d", "E", "e", "E", "e", "E", "e", "E", "e", "E", "e", "G", "g", "G", "g", "G", "g", "G", "g", "H", "h", "H", "h", "I", "i", "I", "i", "I", "i", "I", "i", "I", "i", "IJ", "ij", "J", "j", "K", "k", "L", "l", "L", "l", "L", "l", "L", "l", "l", "l", "N", "n", "N", "n", "N", "n", "n", "O", "o", "O", "o", "O", "o", "OE", "oe", "R", "r", "R", "r", "R", "r", "S", "s", "S", "s", "S", "s", "S", "s", "T", "t", "T", "t", "T", "t", "U", "u", "U", "u", "U", "u", "U", "u", "U", "u", "U", "u", "W", "w", "Y", "y", "Y", "Z", "z", "Z", "z", "Z", "z", "s", "f", "O", "o", "U", "u", "A", "a", "I", "i", "O", "o", "U", "u", "U", "u", "U", "u", "U", "u", "U", "u", "A", "a", "AE", "ae", "O", "o"};

    /**
	 * Set default parameters
	 */
	public void init(String appPath, ServiceConfig config) throws Exception {
		_threshold = Integer.valueOf(config.getValue("threshold"));
		_maxNumberOfTerms = Integer.valueOf(config
				.getValue("max_number_of_terms"));
		_defaultSearchField = config.getValue("default_search_field");
		_config = config;
	}

	/**
	 * Browse the index and return suggestion list.
	 */
	public Element exec(Element params, ServiceContext context)
			throws Exception {
		Element suggestions = new Element("items");

		Element elData  = SearchDefaults.getDefaultSearch(context, params);
		UserSession  session     = context.getUserSession();
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		SearchManager sm = gc.getSearchmanager();
		MetaSearcher searcher = sm.newSearcher(SearchManager.LUCENE, Geonet.File.SEARCH_LUCENE);
        String searchValue = StringUtils.replaceEach(Util.getParam(params, "q", ""), specialChars, normalChars).toLowerCase();
		String fieldName = Util.getParam(params, "field", _defaultSearchField);
		Element result = null;
		try {
			
			// Check is user asked for summary only without building summary
			elData.addContent(new Element(Geonet.SearchResult.FAST).setText("index"));
			elData.addContent(new Element(fieldName).setText(searchValue));
			elData.addContent(new Element("to").setText("" + _maxNumberOfTerms));			
			elData.addContent(new Element("from").setText("1"));
			String summaryOnly = Util.getParam(params, Geonet.SearchResult.SUMMARY_ONLY, "0");
			String sBuildSummary = params.getChildText(Geonet.SearchResult.BUILD_SUMMARY);
			if (sBuildSummary != null && sBuildSummary.equals("false") && !"0".equals(summaryOnly))
				elData.getChild(Geonet.SearchResult.BUILD_SUMMARY).setText("true");
			elData.addContent(new Element(Geonet.SearchResult.BUILD_SUMMARY).setText("true"));
//			elData.addContent(new Element(Geonet.SearchResult.RESULT_TYPE).setText("suggestions"));
			elData.getChild(Geonet.SearchResult.SORT_BY).setText(/*fieldName*/"changeDate");
			elData.removeChild("field");
			elData.removeChild("q");
			searcher.search(context, elData, _config);
			session.setProperty(Geonet.Session.SEARCH_REQUEST, elData);
//			if (!"0".equals(summaryOnly)) {
				result = searcher.getSummary();
/*
			} else {
				elData.addContent(new Element(Geonet.SearchResult.FAST).setText("true"));
				elData.addContent(new Element("from").setText("1"));
				// FIXME ? from and to parameter could be used but if not
				// set, the service return the whole range of results
				// which could be huge in non fast mode ? 
				elData.addContent(new Element("to").setText(searcher.getSize() +""));
				result = searcher.present(context, elData, _config);
			}
*/

/*	
			if (!"0".equals(summaryOnly)) {
				return searcher.getSummary();
			} else {
				elData.addContent(new Element(Geonet.SearchResult.FAST).setText("true"));
				elData.addContent(new Element("from").setText("1"));
				// FIXME ? from and to parameter could be used but if not
				// set, the service return the whole range of results
				// which could be huge in non fast mode ? 
				elData.addContent(new Element("to").setText(searcher.getSize() +""));
		
				Element result = searcher.present(context, elData, _config);
				
				// Update result elements to present
				SelectionManager.updateMDResult(context.getUserSession(), result);
		
				return result;
			}
*/
		} finally {
			searcher.close();
		}
//		System.out.println(Xml.getString(result));
		Map<String, String> suggestionValueCountMap = new HashMap<String, String>();
		if (fieldName.equals("any")) {
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/keywords/keyword"), searchValue);
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/abstracts/abstract"), searchValue);
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/titles/title"), searchValue);
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/organisationNames/organisationName"), searchValue);
		} else if (fieldName.equals("keyword")) {
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/keywords/keyword"), searchValue);
		} else if (fieldName.equals("orgName")) {
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/organisationNames/organisationName"), searchValue);
		}/* else if (fieldName.equals("inspiretheme")) {
			addSuggestions(suggestionValueCountMap, (List<Element>) Xml.selectNodes(result, "summary/inspirethemes/inspiretheme"), searchValue);
		}*/
//		List<SearchManager.TermFrequency> termList = sm.getTermsFequency(fieldName, searchValue, _maxNumberOfTerms, _threshold/*, context.getLanguage()*/);
/*
		Collections.sort(termList);
		Collections.reverse(termList);

		Iterator<SearchManager.TermFrequency> iterator = termList.iterator();
		while (iterator.hasNext()) {
			SearchManager.TermFrequency freq = (SearchManager.TermFrequency) iterator
					.next();
			suggestions.addContent(new Element("item").setAttribute("term",
					freq.getTerm()).setAttribute("freq",
					String.valueOf(freq.getFrequency())));
		}
*/
		for (String suggestion : suggestionValueCountMap.keySet()) {
			suggestions.addContent(new Element("item").setAttribute("term",
					suggestion).setAttribute("freq",
					String.valueOf(suggestionValueCountMap.get(suggestion))));
		}
		// TODO : Could we output JSON directly from a Jeeves service
		// whithout having the XSL transformation ?

		return suggestions;
	}
	
	private void addSuggestions(Map<String, String> suggestionValueCountMap, List<Element> elements, String searchValue) {
		for (Element element : elements) {
			String value = element.getAttributeValue("name");
			if (StringUtils.isNotBlank(value)) {
				String countValue = element.getAttributeValue("count");
				int count = 0;
				if (StringUtils.isNotBlank(countValue)) {
					count = Integer.parseInt(countValue);
				}
				if (StringUtils.isNotBlank(searchValue)) {
					int iPos = StringUtils.replaceEach(value, specialChars, normalChars).toLowerCase().indexOf(searchValue);
					if (iPos > -1) {
						// get the string containing de searchvalue for phrases like titel and abstract
						if (value.length()!=searchValue.length()) {
							String[] firstParts = value.substring(0, iPos+1).split("[\\p{Punct}\\s+]");
							String[] lastParts = value.substring(iPos + searchValue.length() - 1).split("[\\p{Punct}\\s+]");
							value =  firstParts[firstParts.length-1] + value.substring(iPos+1, iPos + searchValue.length() - 1) + lastParts[0];
						}
						value = /*StringUtils.*/capitalize(value);
						String existingCount = suggestionValueCountMap.get(value); 
						if (existingCount==null) {
							existingCount = "0";
						}
						suggestionValueCountMap.put(value, "" + (existingCount + count));
					}
				} else {
					value = /*StringUtils.*/capitalize(value);
					suggestionValueCountMap.put(value, "" + count);
				}
			}
		}
	}

    private static String capitalize(String str) {
        int strLen;
        if (str == null || (strLen = str.length()) == 0) {
            return str;
        }
        return new StrBuilder(strLen)
        	.append(StringUtils.replaceEach(str.substring(0,1), specialChars, normalChars).toUpperCase())
//            .append(Character.toTitleCase(str.charAt(0)))
            .append(str.substring(1))
            .toString();
    }
}