<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:java="java:org.fao.geonet.util.XslUtil" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmx="http://www.isotc211.org/2005/gmx">
	<!-- This file defines what parts of the metadata are indexed by Lucene
	     Searches can be conducted on indexes defined here.
	     The Field@name attribute defines the name of the search variable.
		 If a variable has to be maintained in the user session, it needs to be
		 added to the GeoNetwork constants in the Java source code.
		 Please keep indexes consistent among metadata standards if they should
		 work accross different metadata resources -->
	<!-- ========================================================================================= -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:include href="convert/functions.xsl"/>
	<xsl:include href="../../../../../xsl/utils-index-fields.xsl"/>
	<!-- ========================================================================================= -->
	<xsl:param name="thesauriDir"/>
	<xsl:param name="inspire">false</xsl:param>

	<xsl:variable name="isoDocLangId">
		<xsl:call-template name="langId19139"/>
	</xsl:variable>
	<xsl:template match="/">
		<Documents>
			<xsl:for-each select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:locale/gmd:PT_Locale">
				<!--<xsl:variable name="langId" select="@id"/>-->
<!--				<xsl:variable name="isoLangId" select="java:twoCharLangCode(normalize-space(string(gmd:languageCode/gmd:LanguageCode/@codeListValue)))" />-->
				<xsl:variable name="isoLangId" select="normalize-space(string(gmd:languageCode/gmd:LanguageCode/@codeListValue))"/>
				<xsl:if test="$isoLangId!=$isoDocLangId">
					<Document locale="{$isoLangId}">
						<Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
						<Field name="_docLocale" string="{$isoDocLangId}" store="true" index="true"/>
				        <xsl:variable name="pound2LangId" select="concat('#',upper-case(java:twoCharLangCode($isoLangId)))" />
						<xsl:variable name="pound3LangId" select="concat('#',upper-case($isoLangId))"/>
						<xsl:variable name="_defaultTitle">
							<xsl:call-template name="defaultTitle">
								<xsl:with-param name="isoDocLangId" select="$isoLangId" />
							</xsl:call-template>
						</xsl:variable>
						<!-- not tokenized title for sorting -->
						<Field name="_defaultTitle" string="{string($_defaultTitle)}" store="true" index="true"/>
						<xsl:variable name="identification" select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']/gmd:identificationInfo/*[name(.)='gmd:MD_DataIdentification' or @gco:isoType='gmd:MD_DataIdentification' or name(.)='srv:SV_ServiceIdentification' or @gco:isoType='srv:SV_ServiceIdentification']"></xsl:variable>
				        <xsl:variable name="title" select="$identification/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]"/>
						<!-- not tokenized title for sorting -->
						<Field name="_title" string="{string($title)}" store="true" index="true"/>
                        <xsl:variable name="_defaultAbstract">
                            <xsl:call-template name="defaultAbstract">
                                <xsl:with-param name="isoDocLangId" select="$isoLangId"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <Field name="_defaultAbstract" string="{string($_defaultAbstract)}" store="true" index="true"/>
				        <xsl:variable name="abstract" select="$identification/gmd:citation/*/gmd:abstract//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]"/>
						<Field name="_abstract" string="{string($abstract)}" store="true" index="true"/>
						<xsl:apply-templates select="/*[name(.)='gmd:MD_Metadata' or @gco:isoType='gmd:MD_Metadata']" mode="metadata">
							<xsl:with-param name="isoLangId" select="$isoLangId"/>
						</xsl:apply-templates>
					</Document>
				</xsl:if>
			</xsl:for-each>
		</Documents>
	</xsl:template>
	<!-- ========================================================================================= -->
	<xsl:template match="*" mode="metadata">
		<xsl:param name="isoLangId"/>
        <xsl:variable name="pound2LangId" select="concat('#',upper-case(java:twoCharLangCode($isoLangId)))" />
        <xsl:variable name="pound3LangId" select="concat('#',upper-case($isoLangId))" />
		<!-- === Data or Service Identification === -->
		<!-- the double // here seems needed to index MD_DataIdentification when
           it is nested in a SV_ServiceIdentification class -->
		<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification|        gmd:identificationInfo/*[@gco:isoType='gmd:MD_DataIdentification']|        gmd:identificationInfo/srv:SV_ServiceIdentification|        gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']">
			<xsl:for-each select="gmd:citation/gmd:CI_Citation">
				<xsl:for-each select="gmd:identifier/gmd:MD_Identifier/gmd:code//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="identifier" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<!-- not tokenized title for sorting -->
				<Field name="_defaultTitle" string="{string(gmd:title/gco:CharacterString)}" store="true" index="true"/>
				<!-- not tokenized title for sorting -->
				<Field name="_title" string="{string(gmd:title//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId])}" store="true" index="true"/>
				<xsl:for-each select="gmd:title//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="title" string="{string(.)}" store="true" index="true"/>
					<Field name="any" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:alternateTitle//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="altTitle" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/gco:Date">
					<Field name="revisionDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date/gco:Date">
					<Field name="createDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']/gmd:date/gco:Date">
					<Field name="publicationDate" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<!-- fields used to search for metadata in paper or digital format -->
				<xsl:for-each select="gmd:presentationForm">
					<xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Digital')">
						<Field name="digital" string="true" store="true" index="true"/>
					</xsl:if>
					<xsl:if test="contains(gmd:CI_PresentationFormCode/@codeListValue, 'Hardcopy')">
						<Field name="paper" string="true" store="true" index="true"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:abstract//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
				<Field name="abstract" string="{string(.)}" store="true" index="true"/>
				<Field name="any" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="*/gmd:EX_Extent">
				<xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="latLon"/>
				<xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:description//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="extentDesc" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent|      gmd:temporalElement/gmd:EX_SpatialTemporalExtent/gmd:extent">
					<xsl:for-each select="gml:TimePeriod/gml:beginPosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>
					<xsl:for-each select="gml:TimePeriod/gml:endPosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>
					<xsl:for-each select="gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>
					<xsl:for-each select="gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>
					<xsl:for-each select="gml:TimeInstant/gml:timePosition">
						<Field name="tempExtentBegin" string="{string(.)}" store="true" index="true"/>
						<Field name="tempExtentEnd" string="{string(.)}" store="true" index="true"/>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="//gmd:MD_Keywords">
			  
				<xsl:for-each select="gmd:keyword//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
					<Field name="keyword" string="{string(.)}" store="true" index="true"/>
					<Field name="any" string="{string(.)}" store="true" index="true"/>
                    <xsl:if test="string-length(.) &gt; 0 and normalize-space(lower-case(.))='reporting inspire'">
                   		<Field name="reportinginspire" string="on" store="false" index="true"/>
               		</xsl:if>
                    <xsl:if test="$inspire='true'">
                        <xsl:if test="string-length(.) &gt; 0">
                         
                          <xsl:variable name="inspireannex">
                            <xsl:call-template name="determineInspireAnnex">
                              <xsl:with-param name="keyword" select="string(.)"/>
                              <xsl:with-param name="thesauriDir" select="$thesauriDir"/>
                            </xsl:call-template>
                          </xsl:variable>
                          
                          <!-- Add the inspire field if it's one of the 34 themes -->
                          <xsl:if test="normalize-space($inspireannex)!=''">
                            <!-- Maybe we should add the english version to the index to not take the language into account 
                            or create one field in the metadata language and one in english ? -->
                            <Field name="inspiretheme" string="{string(.)}" store="false" index="true"/>
                          	<Field name="inspireannex" string="{$inspireannex}" store="false" index="true"/>
                            <!-- FIXME : inspirecat field will be set multiple time if one record has many themes -->
                          	<Field name="inspirecat" string="true" store="false" index="true"/>
                          </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>

				<xsl:for-each select="gmd:type/gmd:MD_KeywordTypeCode/@codeListValue">
					<Field name="keywordType" string="{string(.)}" store="false" index="true"/>
				</xsl:for-each>
			</xsl:for-each>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString">
				<Field name="orgName" string="{string(.)}" store="true" index="true"/>
				<Field name="any" string="{string(.)}" store="true" index="true"/>
				
				<xsl:variable name="role" select="../../gmd:role/*/@codeListValue"/>
				<xsl:variable name="logo" select="../..//gmx:FileName/@src"/>
			
				<Field name="responsibleParty" string="{concat($role, '|resource|', ., '|', $logo)}" store="true" index="false"/>
				
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- 
			<xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
				<Field name="orgName" string="{string(.)}" store="true" index="true"/>
				<Field name="_orgName" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
-->
			<xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString|     gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualFirstName/gco:CharacterString|     gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:individualLastName/gco:CharacterString">
				<Field name="creator" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:choose>
				<xsl:when test="gmd:resourceConstraints/gmd:MD_SecurityConstraints">
					<Field name="secConstr" string="true" store="true" index="true"/>
				</xsl:when>
				<xsl:otherwise>
					<Field name="secConstr" string="false" store="true" index="true"/>
				</xsl:otherwise>
			</xsl:choose>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
				<Field name="topicCat" string="{string(.)}" store="true" index="true"/>
				<Field name="subject" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:language/gco:CharacterString">
				<Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:spatialRepresentationType">
			  <Field name="spatialRepresentationType" string="{gmd:MD_SpatialRepresentationTypeCode/@codeListValue}" store="true" index="true"/>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
				<xsl:for-each select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer">
					<Field name="denominator" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:distance/gco:Distance">
					<Field name="distanceVal" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="gmd:distance/gco:Distance/@uom">
					<Field name="distanceUom" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:for-each select="gmd:graphicOverview/gmd:MD_BrowseGraphic">
				<xsl:variable name="fileName" select="gmd:fileName/gco:CharacterString"/>
				<xsl:if test="$fileName != ''">
					<xsl:variable name="fileDescr" select="gmd:fileDescription/gco:CharacterString"/>
					<xsl:choose>
						<xsl:when test="contains($fileName ,'://')">
							<Field name="image" string="{concat('unknown|', $fileName)}" store="true" index="false"/>
						</xsl:when>
						<xsl:when test="string($fileDescr)='thumbnail'">
							<!-- FIXME : relative path -->
							<Field name="image" string="{concat($fileDescr, '|', '../../srv/eng/resources.get?uuid=', //gmd:fileIdentifier/gco:CharacterString, '&amp;fname=', $fileName, '&amp;access=public')}" store="true" index="false"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<!--  Fields use to search on Service -->
			<xsl:for-each select="srv:serviceType/gco:LocalName">
				<Field name="serviceType" string="{string(.)}" store="true" index="true"/>
				<Field name="type" string="service-{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="srv:serviceTypeVersion/gco:CharacterString">
				<Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="//srv:SV_OperationMetadata/srv:operationName/gco:CharacterString">
				<Field name="operation" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="srv:operatesOn/@uuidref">
				<Field name="operatesOn" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<xsl:for-each select="srv:coupledResource">
				<xsl:for-each select="srv:SV_CoupledResource/srv:identifier/gco:CharacterString">
					<Field name="operatesOnIdentifier" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
				<xsl:for-each select="srv:SV_CoupledResource/srv:operationName/gco:CharacterString">
					<Field name="operatesOnName" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="//srv:SV_CouplingType/srv:code/@codeListValue">
				<Field name="couplingType" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Distribution === -->
		<xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
			<xsl:for-each select="gmd:distributionFormat/gmd:MD_Format/gmd:name//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
				<Field name="format" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
			<!-- index online protocol -->
			<xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
				<Field name="protocol" string="{string(.)}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Service stuff ===  -->
		<!-- Service type           -->
		<xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName|    gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceType/gco:LocalName">
			<Field name="serviceType" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- Service version        -->
		<xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceTypeVersion/gco:CharacterString|    gmd:identificationInfo/*[@gco:isoType='srv:SV_ServiceIdentification']/srv:serviceTypeVersion/gco:CharacterString">
			<Field name="serviceTypeVersion" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === General stuff === -->
		<xsl:choose>
			<xsl:when test="gmd:hierarchyLevel">
				<xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue">
					<Field name="type" string="{string(.)}" store="true" index="true"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<Field name="type" string="dataset" store="true" index="true"/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<xsl:for-each select="gmd:hierarchyLevelName//gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId]">
			<Field name="levelName" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<xsl:for-each select="gmd:fileIdentifier/gco:CharacterString">
			<Field name="fileId" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<xsl:for-each select="gmd:parentIdentifier/gco:CharacterString">
			<Field name="parentUuid" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<xsl:for-each select="gmd:dateStamp/gco:DateTime">
			<Field name="changeDate" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
		<!-- === Reference system info === -->
		<xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
			<xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
				<xsl:variable name="crs" select="concat(string(gmd:codeSpace/gco:CharacterString),'::',string(gmd:code/gco:CharacterString))"/>
				<xsl:if test="$crs != '::'">
					<Field name="crs" string="{$crs}" store="true" index="true"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- === Free text search === -->
<!--
		<Field name="any" store="false" index="true">
			<xsl:attribute name="string">
				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Sitation/gmd:title" mode="allTextByLanguage">
					<xsl:with-param name="isoLangId" select="$isoLangId"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract" mode="allTextByLanguage">
					<xsl:with-param name="isoLangId" select="$isoLangId"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword" mode="allTextByLanguage">
					<xsl:with-param name="isoLangId" select="$isoLangId"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
				<xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
			</xsl:attribute>
		</Field>
-->
 		<xsl:apply-templates select="." mode="codeList"/>
	</xsl:template>
</xsl:stylesheet>
