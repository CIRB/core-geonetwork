<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/2005/Atom"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:georss="http://www.georss.org/georss"
                xmlns:gml="http://www.opengis.net/gml"
				xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:opensearchextensions="http://example.com/opensearchextensions/1.0/"
                xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
                exclude-result-prefixes="gmx xsl gmd gco srv java">
	<xsl:variable name="protocol">WWW:DOWNLOAD-1.0-HTTP--DOWNLOAD</xsl:variable>
	<xsl:variable name="applicationProfile">INSPIRE-Download-Atom</xsl:variable>
	<xsl:variable name="guiLang" select="/root/gui/language"/>
    <xsl:variable name="baseUrl" select="concat('http://',/root/gui/env/server/host,':',/root/gui/env/server/port,/root/gui/url)"/>

	<xsl:template match="/root">
		<feed xsi:schemaLocation="http://www.w3.org/2005/Atom http://inspire-geoportal.ec.europa.eu/schemas/inspire/atom/1.0/atom.xsd" xml:lang="en" xml:base="http://inspire-geoportal.ec.europa.eu/demos/ccm/">
			<xsl:apply-templates mode="service" select="service/gmd:MD_Metadata"/>
			<xsl:apply-templates mode="dataset" select="dataset/gmd:MD_Metadata">
				<xsl:with-param name="isServiceEntry" select="false()"/>
			</xsl:apply-templates>
		</feed>
	</xsl:template>

    <xsl:template mode="service" match="gmd:MD_Metadata">

        <!-- Get first element. TODO: Check if can be several -->
        <xsl:variable name="baseUrl" select="concat('http://',/root/gui/env/server/host,':',/root/gui/env/server/port,/root/gui/url)"/>
		<xsl:variable name="fileIdentifier" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:variable name="docLang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
		<xsl:variable name="titleNode" select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
		<xsl:variable name="title"><xsl:apply-templates mode="get-translation" select="$titleNode"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></xsl:variable>
		<xsl:variable name="updated" select="gmd:dateStamp/gco:DateTime"/>
       	<title><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="2"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$title"/></title>
       	<subtitle><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="2"/></xsl:call-template><xsl:text> </xsl:text><xsl:apply-templates mode="get-translation" select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:abstract"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></subtitle>
       	<xsl:call-template name="csw-link">
			<xsl:with-param name="lang" select="$guiLang"/>
			<xsl:with-param name="baseUrl" select="$baseUrl"/>
			<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
      		</xsl:call-template>
		<xsl:call-template name="atom-link">
			<xsl:with-param name="title"><xsl:value-of select="$title"/></xsl:with-param>
			<xsl:with-param name="lang" select="$guiLang"/>
			<xsl:with-param name="baseUrl" select="$baseUrl"/>
			<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
			<xsl:with-param name="rel">self</xsl:with-param>
		</xsl:call-template>
       	<link rel="search" type="application/opensearchdescription+xml">
       		<xsl:attribute name="title"><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="1"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$title"/></xsl:attribute>
       		<xsl:attribute name="href" select="concat($baseUrl,'/opensearch/',$guiLang,'/',$fileIdentifier,'/OpenSearchDescription.xml')"/>
       	</link>
       	<xsl:for-each select="gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue">
       		<xsl:if test="$guiLang!=.">
				<xsl:call-template name="atom-link">
					<xsl:with-param name="title"><xsl:apply-templates mode="get-translation" select="$titleNode"><xsl:with-param name="lang" select="."/></xsl:apply-templates></xsl:with-param>
					<xsl:with-param name="lang" select="."/>
					<xsl:with-param name="baseUrl" select="$baseUrl"/>
					<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
					<xsl:with-param name="rel"><xsl:if test="$guiLang=.">self</xsl:if><xsl:if test="$guiLang!=.">alternate</xsl:if></xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
   		<xsl:if test="$guiLang!=$docLang">
			<xsl:call-template name="atom-link">
				<xsl:with-param name="title"><xsl:apply-templates mode="get-translation" select="$titleNode"><xsl:with-param name="lang" select="$docLang"/></xsl:apply-templates></xsl:with-param>
				<xsl:with-param name="lang" select="$docLang"/>
				<xsl:with-param name="baseUrl" select="$baseUrl"/>
				<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
				<xsl:with-param name="rel">alternate</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<id>
			<xsl:call-template name="atom-link-href">
				<xsl:with-param name="lang"><xsl:value-of select="$guiLang"/></xsl:with-param>
				<xsl:with-param name="baseUrl"><xsl:value-of select="$baseUrl"/></xsl:with-param>
				<xsl:with-param name="fileIdentifier"><xsl:value-of select="$fileIdentifier"/></xsl:with-param>
			</xsl:call-template>
   		</id>
   		<rights><xsl:apply-templates mode="translated-rights" select="gmd:identificationInfo/srv:SV_ServiceIdentification"/></rights>
		<updated><xsl:value-of select="$updated"/></updated>
		<author>
			<name><xsl:value-of select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/></name>
			<email><xsl:value-of select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/*[name(.)='gmd:CI_Address' or @gco:isoType='CI_Address_Type']/gmd:electronicMailAddress/gco:CharacterString"/></email>
		</author>
		<xsl:for-each select="datasets/gmd:MD_Metadata">
			<entry>
				<inspire_dls:spatial_dataset_identifier_code><xsl:value-of select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString|gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:code/gco:CharacterString"/></inspire_dls:spatial_dataset_identifier_code>
				<inspire_dls:spatial_dataset_identifier_namespace><xsl:value-of select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString|gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString"/></inspire_dls:spatial_dataset_identifier_namespace>
				<xsl:apply-templates mode="dataset" select=".">
					<xsl:with-param name="isServiceEntry" select="true()"/>
				</xsl:apply-templates>
			</entry>
		</xsl:for-each>
    </xsl:template>
    
    <xsl:template mode="dataset" match="gmd:MD_Metadata">
    	<xsl:param name="isServiceEntry"/>
		<xsl:variable name="fileIdentifier" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:variable name="docLang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
		<xsl:variable name="datasetTitleNode" select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
		<xsl:variable name="datasetTitle"><xsl:apply-templates mode="get-translation" select="$datasetTitleNode"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></xsl:variable>
		<xsl:variable name="identifierCode" select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString|gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:code/gco:CharacterString"/>
		<xsl:variable name="identifierCodeSpace" select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString|gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString"/>
		<xsl:variable name="updated" select="gco:DateTime"/>
		<xsl:if test="not($isServiceEntry)">
	       	<title><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="3"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$datasetTitle"/></title>
	       	<subtitle><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="3"/></xsl:call-template><xsl:text> </xsl:text><xsl:apply-templates mode="get-translation" select="gmd:MD_DataIdentification/gmd:abstract"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></subtitle>
		</xsl:if>
		<xsl:if test="$isServiceEntry">
			<xsl:for-each select="gmd:CI_OnlineResource[upper-case(gmd:protocol/gco:CharacterString) = $protocol and gmd:applicationProfile/gco:CharacterString=$applicationProfile]/gmd:description">
				<category>
					<xsl:variable name="crs" select="normalize-space(.)"/>
					<xsl:attribute name="label">
						<xsl:call-template name="get-crs-label"><xsl:with-param name="crs" select="$crs"/></xsl:call-template>
					</xsl:attribute>
					<xsl:attribute name="term" select="$crs"/>
				</category>
			</xsl:for-each>
		</xsl:if>
       	<xsl:call-template name="csw-link">
			<xsl:with-param name="lang" select="$guiLang"/>
			<xsl:with-param name="baseUrl" select="$baseUrl"/>
			<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
   		</xsl:call-template>
		<xsl:call-template name="atom-link">
			<xsl:with-param name="title"><xsl:apply-templates mode="get-translation" select="$datasetTitleNode"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></xsl:with-param>
			<xsl:with-param name="lang" select="$guiLang"/>
			<xsl:with-param name="baseUrl" select="$baseUrl"/>
			<xsl:with-param name="identifier" select="$identifierCode"/>
			<xsl:with-param name="codeSpace"><xsl:value-of select="$identifierCodeSpace"/></xsl:with-param>
			<xsl:with-param name="rel"><xsl:if test="name(../..)='root'">self</xsl:if><xsl:if test="name(..)='datasets'">alternate</xsl:if></xsl:with-param>
		</xsl:call-template>
		<xsl:if test="not($isServiceEntry)">
	       	<xsl:for-each select="gmd:locale/gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue">
	       		<xsl:if test="$guiLang!=.">
					<xsl:call-template name="atom-link">
						<xsl:with-param name="title"><xsl:apply-templates mode="get-translation" select="$datasetTitleNode"><xsl:with-param name="lang" select="."/></xsl:apply-templates></xsl:with-param>
						<xsl:with-param name="lang" select="."/>
						<xsl:with-param name="baseUrl" select="$baseUrl"/>
						<xsl:with-param name="identifier" select="$identifierCode"/>
						<xsl:with-param name="codeSpace"><xsl:value-of select="$identifierCodeSpace"/></xsl:with-param>
						<xsl:with-param name="rel"><xsl:if test="$guiLang=.">self</xsl:if><xsl:if test="$guiLang!=.">alternate</xsl:if></xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
	   		<xsl:if test="$guiLang!=$docLang">
				<xsl:call-template name="atom-link">
					<xsl:with-param name="title"><xsl:apply-templates mode="get-translation" select="$datasetTitleNode"><xsl:with-param name="lang" select="$docLang"/></xsl:apply-templates></xsl:with-param>
					<xsl:with-param name="lang" select="$docLang"/>
					<xsl:with-param name="baseUrl" select="$baseUrl"/>
					<xsl:with-param name="identifier" select="$identifierCode"/>
					<xsl:with-param name="codeSpace"><xsl:value-of select="$identifierCodeSpace"/></xsl:with-param>
					<xsl:with-param name="rel">alternate</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
   		<id>
			<xsl:call-template name="atom-link-href">
				<xsl:with-param name="lang"><xsl:value-of select="$guiLang"/></xsl:with-param>
				<xsl:with-param name="baseUrl"><xsl:value-of select="$baseUrl"/></xsl:with-param>
				<xsl:with-param name="identifier"><xsl:value-of select="$identifierCode"/></xsl:with-param>
				<xsl:with-param name="codeSpace"><xsl:value-of select="$identifierCodeSpace"/></xsl:with-param>
			</xsl:call-template>
   		</id>
   		<rights><xsl:apply-templates mode="translated-rights" select="gmd:MD_DataIdentification"/></rights>
		<xsl:if test="$isServiceEntry">
	       	<summary><xsl:apply-templates mode="get-translation" select="gmd:MD_DataIdentification/gmd:abstract"><xsl:with-param name="lang" select="$guiLang"/></xsl:apply-templates></summary>
	       	<title><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$guiLang"/><xsl:with-param name="type" select="3"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$datasetTitle"/></title>
		</xsl:if>
		<updated><xsl:value-of select="$updated"/></updated>
		<xsl:variable name="w" select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal/text())"/>
		<xsl:variable name="e" select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal/text())"/>
		<xsl:variable name="s" select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal/text())"/>
		<xsl:variable name="n" select="normalize-space(gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal/text())"/>
		<xsl:variable name="fw" select="java:formatNumber($w,'5')"/>
		<xsl:variable name="fe" select="java:formatNumber($e,'5')"/>
		<xsl:variable name="fs" select="java:formatNumber($s,'5')"/>
		<xsl:variable name="fn" select="java:formatNumber($n,'5')"/>
		<xsl:if test="$isServiceEntry">
			<xsl:if test="$w!='' and $e!='' and $s!='' and $n!=''">
				<georss:polygon><xsl:value-of select="concat($fs,' ',$fw,' ',$fn,' ',$fw,' ',$fn,' ',$fe,' ',$fs,' ',$fe,' ',$fs,' ',$fw)"/></georss:polygon>
			</xsl:if>
		</xsl:if>
		<xsl:if test="not($isServiceEntry)">
			<author>
				<name><xsl:value-of select="gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/></name>
				<email><xsl:value-of select="gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/*[name(.)='gmd:CI_Address' or @gco:isoType='CI_Address_Type']/gmd:electronicMailAddress/gco:CharacterString"/></email>
			</author>
			<xsl:for-each select="gmd:CI_OnlineResource[upper-case(gmd:protocol/gco:CharacterString) = $protocol and gmd:applicationProfile/gco:CharacterString=$applicationProfile]">
				<entry>				
					<xsl:variable name="crs" select="normalize-space(gmd:description)"/>
					<xsl:variable name="crsLabel">
						<xsl:call-template name="get-crs-label"><xsl:with-param name="crs" select="$crs"/></xsl:call-template>
					</xsl:variable>
					<xsl:variable name="mimeFileType" select="normalize-space(gmd:name/gmx:MimeFileType/@type)"/>
					<xsl:variable name="entryTitle" select="concat($datasetTitle,' in ', $crsLabel, ' - ', /root/gui/strings/mimetypeChoice[@value=$mimeFileType])"/>
					<inspire_dls:spatial_dataset_identifier_code><xsl:value-of select="$identifierCode"/></inspire_dls:spatial_dataset_identifier_code>
					<inspire_dls:spatial_dataset_identifier_namespace><xsl:value-of select="$identifierCodeSpace"/></inspire_dls:spatial_dataset_identifier_namespace>
					<xsl:variable name="crs" select="normalize-space(gmd:description)"/>
					<category>
						<xsl:attribute name="term" select="$crs"/>
						<xsl:attribute name="label" select="$crsLabel"/>
					</category>
					<id><xsl:value-of select="gmd:linkage/gmd:URL"/></id>
<!--					<link rel="alternate" href="http://www.cirb.irisnet.be/fr/nos-solutions/urbis-solutions/urbis-data/addrespoints_4258.zip" type="application/x-shapefile" hreflang="en" length="34987" title="The dataset encoded as a zipped shapefiles in ETRS89(http://www.opengis.net/def/crs/EPSG/0/4258)"/>-->
					<link title="{$entryTitle}" rel="alternate">
						<xsl:attribute name="type"><xsl:value-of select="normalize-space(gmd:name/gmx:MimeFileType/@type)"/></xsl:attribute>
						<xsl:attribute name="href"><xsl:value-of select="gmd:linkage/gmd:URL"/></xsl:attribute></link>
					<title><xsl:value-of select="$entryTitle"/></title>
					<updated><xsl:value-of select="$updated"/></updated>
					<georss:polygon><xsl:value-of select="concat($fs,' ',$fw,' ',$fn,' ',$fw,' ',$fn,' ',$fe,' ',$fs,' ',$fe,' ',$fs,' ',$fw)"/></georss:polygon>
				</entry>
			</xsl:for-each>
		</xsl:if>
    </xsl:template>

	<xsl:template name="translated-description">
		<xsl:param name="lang"/>
		<xsl:param name="type"/>
		<xsl:variable name="suffix"><xsl:choose><xsl:when test="$lang='dut'">voor</xsl:when><xsl:when test="$lang='fre'">pour</xsl:when><xsl:otherwise>for</xsl:otherwise></xsl:choose></xsl:variable>
		<xsl:choose>
			<xsl:when test="$type=1"><xsl:value-of select="concat('Open Search Description ', $suffix)"/></xsl:when>
			<xsl:when test="$type=2"><xsl:value-of select="concat('INSPIRE Download Service Atom feed ', $suffix)"/></xsl:when>
			<xsl:when test="$type=3"><xsl:value-of select="concat('INSPIRE Dataset Atom feed ', $suffix)"/></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="translated-rights" match="srv:SV_ServiceIdentification|gmd:MD_DataIdentification">
<!--		<xsl:variable name="useLimitation" select="normalize-space(gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation/gco:CharacterString)"/>
		<xsl:variable name="translated-useLimitation" select="normalize-space(gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',upper-case($guiLang))])"/>
		<xsl:choose>
			<xsl:when test="$translated-useLimitation!=''"><xsl:value-of select="$translated-useLimitation"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$useLimitation"/></xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
-->
		<xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints">
			<xsl:variable name="accessConstraints" select="gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
			<xsl:variable name="otherConstraints" select="normalize-space(gmd:otherConstraints/gco:CharacterString)"/>
			<xsl:variable name="translated-otherConstraints" select="normalize-space(gmd:otherConstraints/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',upper-case($guiLang))])"/>
			<xsl:variable name="resultValue">
				<xsl:choose>
					<xsl:when test="$accessConstraints='otherRestrictions' and $otherConstraints!=''"><xsl:if test="$translated-otherConstraints!=''"><xsl:value-of select="$translated-otherConstraints"/></xsl:if><xsl:if test="$translated-otherConstraints=''"><xsl:value-of select="$otherConstraints"/></xsl:if></xsl:when>
					<xsl:otherwise><xsl:value-of select="/root/gui/schemas/iso19139/codelists/codelist[@name = 'gmd:MD_RestrictionCode']/entry[code = $accessConstraints]/description"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="normalize-space($resultValue)"/><xsl:if test="not(ends-with(normalize-space($resultValue),'.'))">.</xsl:if><xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="gmd:resourceConstraints/gmd:MD_SecurityConstraints">
			<xsl:variable name="classificationConstraints" select="gmd:classification/gmd:MD_ClassificationCode/@codeListValue"/>
			<xsl:variable name="resultValue" select="/root/gui/schemas/iso19139/codelists/codelist[@name = 'gmd:MD_ClassificationCode']/entry[code = $classificationConstraints]/description"/>
			<xsl:value-of select="normalize-space($resultValue)"/><xsl:if test="not(ends-with(normalize-space($resultValue),'.'))">.</xsl:if><xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="csw-link">
		<xsl:param name="lang"/>
		<xsl:param name="baseUrl"/>
		<xsl:param name="fileIdentifier"/>
		<link rel="describedby" type="application/vnd.iso.19139+xml">
			<xsl:attribute name="href" select="concat($baseUrl,'/srv/',$lang,'/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputschema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full&amp;id=',$fileIdentifier)"/>
       	</link>
	</xsl:template>

	<xsl:template name="atom-link">
		<xsl:param name="lang"/>
		<xsl:param name="baseUrl"/>
		<xsl:param name="fileIdentifier"/>
		<xsl:param name="identifier"/>
		<xsl:param name="codeSpace"/>
		<xsl:param name="title"/>
		<xsl:param name="rel"/>
		<xsl:variable name="type" select="if ($fileIdentifier!='') then 2 else 3"/>
       	<link type="application/atom+xml">
       		<xsl:if test="$lang!=$guiLang">
   				<xsl:attribute name="hreflang" select="$lang"/>
			</xsl:if>
			<xsl:if test="$rel!=''">
   				<xsl:attribute name="rel" select="$rel"/>
			</xsl:if>
       		<xsl:attribute name="title"><xsl:call-template name="translated-description"><xsl:with-param name="lang" select="$lang"/><xsl:with-param name="type" select="$type"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$title"/></xsl:attribute>
       		<xsl:attribute name="href">
				<xsl:call-template name="atom-link-href">
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="baseUrl" select="$baseUrl"/>
					<xsl:with-param name="fileIdentifier" select="$fileIdentifier"/>
					<xsl:with-param name="identifier" select="$identifier"/>
					<xsl:with-param name="codeSpace" select="$codeSpace"/>
				</xsl:call-template>
       		</xsl:attribute>
       	</link>
	</xsl:template>

	<xsl:template name="atom-link-href">
		<xsl:param name="lang"/>
		<xsl:param name="baseUrl"/>
		<xsl:param name="fileIdentifier"/>
		<xsl:param name="identifier"/>
		<xsl:param name="codeSpace"/>
		<xsl:if test="$fileIdentifier!=''"><xsl:value-of select="concat($baseUrl,'/srv/',$lang,'/atom?id=',$fileIdentifier)"/></xsl:if>
		<xsl:if test="$identifier!=''"><xsl:value-of select="concat($baseUrl,'/srv/',$lang,'/atom?spatial_dataset_identifier_code=',$identifier,'&amp;spatial_dataset_identifier_namespace=',$codeSpace)"/></xsl:if>
	</xsl:template>

	<xsl:template mode="get-translation" match="*|@*">
		<xsl:param name="lang"/>
		<xsl:variable name="translation" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',upper-case($lang))]"/>
		<xsl:choose>
			<xsl:when test="$translation!=''"><xsl:value-of select="$translation"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="normalize-space(gco:CharacterString)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template name="get-crs-label">
		<xsl:param name="crs"/>
		<xsl:choose>
			<xsl:when test="$crs='http://www.opengis.net/def/crs/EPSG/0/25832'">ETRS89 / UTM zone 32N</xsl:when>
			<xsl:when test="$crs='http://www.opengis.net/def/crs/EPSG/0/4258'">ETRS89</xsl:when>
			<xsl:when test="$crs='http://www.opengis.net/def/crs/OGC/1.3/CRS84'">CRS 84</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>