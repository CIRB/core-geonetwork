<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="#all">

	<xsl:include href="convert/functions.xsl"/>

	<!-- ================================================================= -->

	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Metadata">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			
			<gmd:fileIdentifier>
				<gco:CharacterString>
					<xsl:value-of select="/root/env/uuid"/>
				</gco:CharacterString>
			</gmd:fileIdentifier>
			
			<xsl:apply-templates select="gmd:language"/>
			<xsl:apply-templates select="gmd:characterSet"/>
			
			<xsl:choose>
				<xsl:when test="/root/env/parentUuid!=''">
					<gmd:parentIdentifier>
						<gco:CharacterString>
							<xsl:value-of select="/root/env/parentUuid"/>
						</gco:CharacterString>
					</gmd:parentIdentifier>
				</xsl:when>
<!--
				<xsl:when test="gmd:parentIdentifier">
					<xsl:copy-of select="gmd:parentIdentifier"/>
				</xsl:when>
 -->
				<xsl:when test="gmd:parentIdentifier">
					<xsl:apply-templates select="gmd:parentIdentifier"/>
				</xsl:when>
				<xsl:otherwise>
					<gmd:parentIdentifier gco:nilReason="missing">
						<gco:CharacterString/>
					</gmd:parentIdentifier>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="node()[name()!='gmd:language' and name()!='gmd:characterSet' and name()!='gmd:parentIdentifier']"/>
		</xsl:copy>
	</xsl:template>


	<!-- ================================================================= -->
	<!-- Do not process MD_Metadata header generated by previous template  -->

	<xsl:template match="gmd:MD_Metadata/gmd:fileIdentifier" priority="10"/>

    <!-- ================================================================= -->

    <xsl:template match="gmd:minimumValue" priority="10">
        <xsl:choose>
            <xsl:when test="string(gco:Real)">
                <gmd:minimumValue>
                    <xsl:apply-templates select="*"/>
                </gmd:minimumValue>
            </xsl:when>

            <xsl:otherwise>
                <gmd:minimumValue gco:nilReason="missing" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:maximumValue" priority="10">
        <xsl:choose>
            <xsl:when test="string(gco:Real)">
                <gmd:maximumValue>
                    <xsl:apply-templates select="*"/>
                </gmd:maximumValue>
            </xsl:when>

            <xsl:otherwise>
                <gmd:maximumValue gco:nilReason="missing" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gco:Date" priority="10">
		<xsl:choose>
			<xsl:when test="string(.)">
				<gco:Date><xsl:value-of select="." /></gco:Date>
			</xsl:when>
			<xsl:otherwise>
				<gco:Date xsi:nil="true"></gco:Date>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================= -->	 

	<xsl:template match="gmd:dateStamp">
    <xsl:choose>
        <xsl:when test="/root/env/changeDate">
            <xsl:copy>
                    <gco:DateTime>
                        <xsl:value-of select="/root/env/changeDate"/>
                    </gco:DateTime>
            </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="."/>
        </xsl:otherwise>
    </xsl:choose>
	</xsl:template>

	<!-- ================================================================= -->
	
	<xsl:template match="gmd:dateTime">
	    <xsl:copy>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:if test="normalize-space(gco:DateTime)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				<xsl:apply-templates select="*[not(name()='gco:DateTime')]"/>
			</xsl:if>
			<xsl:if test="not(normalize-space(gco:DateTime)='')">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	
	<!-- Only set metadataStandardName and metadataStandardVersion
	if not set. -->
	<xsl:template match="gmd:metadataStandardName[@gco:nilReason='missing' or gco:CharacterString='']" priority="10">
        <xsl:variable name="service" select="../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service'"/>
		<xsl:copy>
			<xsl:if test="$service">
				<gco:CharacterString>ISO 19119</gco:CharacterString>
			</xsl:if>
			<xsl:if test="not($service)">
				<gco:CharacterString>ISO 19115</gco:CharacterString>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="gmd:metadataStandardVersion[@gco:nilReason='missing' or gco:CharacterString='']" priority="10">
        <xsl:variable name="service" select="../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service'"/>
		<xsl:copy>
			<xsl:if test="$service">
				<gco:CharacterString>2005/Amd 1:2008</gco:CharacterString>
			</xsl:if>
			<xsl:if test="not($service)">
				<gco:CharacterString>2003/Cor.1:2006</gco:CharacterString>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	
	<xsl:template match="@gml:id">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:attribute name="gml:id">
					<xsl:value-of select="generate-id(.)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ==================================================================== -->
	<!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat 
	     ordering) by default -->

	<xsl:template match="@srsName">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:attribute name="srsName">
					<xsl:text>CRS:84</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>
  
	<!-- ================================================================= -->
	
	<xsl:template match="*[gco:CharacterString]">
		<xsl:call-template name="updateElementWithCharacterStringChild"/>
	</xsl:template>

	<xsl:template name="updateElementWithCharacterStringChild">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:choose>
				<xsl:when test="normalize-space(gco:CharacterString)=''">
					<xsl:attribute name="gco:nilReason">
						<xsl:choose>
							<xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
							<xsl:otherwise>missing</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
					<xsl:copy-of select="@gco:nilReason"/>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- codelists: set @codeList path -->
	<!-- ================================================================= -->
	<xsl:template match="gmd:LanguageCode[@codeListValue]" priority="10">
		<gmd:LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#gmd:LanguageCode">
			<xsl:apply-templates select="@*[name(.)!='codeList']"/>
		</gmd:LanguageCode>
	</xsl:template>


	<xsl:template match="gmd:*[@codeListValue]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="codeList">
			  <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#',local-name(.))"/>
			</xsl:attribute>
		</xsl:copy>
	</xsl:template>

	<!-- can't find the location of the 19119 codelists - so we make one up -->

	<xsl:template match="srv:*[@codeListValue]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="codeList">
				<xsl:value-of select="concat('http://www.isotc211.org/2005/iso19119/resources/codelist/gmxCodelists.xml#',local-name(.))"/>
			</xsl:attribute>
		</xsl:copy>
	</xsl:template>
	<!-- ================================================================= -->
  <xsl:template match="gmx:FileName[name(..)!='gmd:contactInstructions']">
    <xsl:copy>
			<xsl:attribute name="src">
				<xsl:choose>
					<xsl:when test="/root/env/config/downloadservice/simple='true'">
						<xsl:value-of select="concat(/root/env/siteURL,'/resources.get?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
					</xsl:when>
					<xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
						<xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
					</xsl:when>
					<xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

	<!-- Do not allow to expand operatesOn sub-elements 
		and constrain users to use uuidref attribute to link
		service metadata to datasets. This will avoid to have
		error on XSD validation. -->
	<xsl:template match="srv:operatesOn|gmd:featureCatalogueCitation">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:MD_FeatureCatalogueDescription">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="/root/env/createdFromTemplate='y'">
				<gmd:includedWithDataset>
					<gco:Boolean>true</gco:Boolean>
				</gmd:includedWithDataset>
				<gmd:featureCatalogueCitation uuidref=""/>
			</xsl:if>
			<xsl:if test="/root/env/createdFromTemplate='n'">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:series">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="/root/env/createdFromTemplate='y'">
				<gmd:CI_Series>
					<gmd:name><gco:CharacterString/></gmd:name>
				</gmd:CI_Series>
			</xsl:if>
			<xsl:if test="/root/env/createdFromTemplate='n'">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

		<!-- ================================================================= -->
	<!-- Set local identifier to the first 3 letters of iso code. Locale ids
		are used for multilingual charcterString using #iso2code for referencing.
	-->
	<xsl:template match="gmd:PT_Locale">
		<xsl:variable name="id" select="upper-case(
			substring(gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>

		<xsl:choose>
			<xsl:when test="@id and (normalize-space(@id)!='' and normalize-space(@id)=$id)">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<gmd:PT_Locale>
					<xsl:attribute name="id">
						<xsl:value-of select="$id"/>
					</xsl:attribute>
					<xsl:copy-of select="./*"/>
				</gmd:PT_Locale>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- Initialize dataset RS_Identifier if created from template -->
	<!-- ================================================================= -->
	<xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:if test="/root/env/createdFromTemplate='y'">
				<gmd:code>
					<gco:CharacterString><xsl:value-of select="/root/env/mduuid"/></gco:CharacterString>
				</gmd:code>
				<gmd:codeSpace gco:nilReason="missing">
					<gco:CharacterString/>
				</gmd:codeSpace>
			</xsl:if>
			<xsl:if test="/root/env/createdFromTemplate='n'">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- Initialize dataset MD_Identifier if created from template -->
	<!-- ================================================================= -->
	<xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:if test="/root/env/createdFromTemplate='y'">
				<gmd:code>
					<gco:CharacterString><xsl:value-of select="/root/env/mduuid"/></gco:CharacterString>
				</gmd:code>
			</xsl:if>
			<xsl:if test="/root/env/createdFromTemplate='n'">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- Updating reference system RS_Identifier gmd:code -->
	<!-- ================================================================= -->
	<xsl:template match="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
	    <xsl:copy>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:if test="normalize-space(gco:CharacterString)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				<gco:CharacterString/>
			</xsl:if>
			<xsl:if test="not(normalize-space(gco:CharacterString)='')">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<!-- ================================================================= -->
	<!-- Emptying title if created from template -->
	<!-- ================================================================= -->
	<xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title">
		<xsl:if test="/root/env/createdFromTemplate='y'">
			<gmd:title gco:nilReason="missing">
				<gco:CharacterString/>
			</gmd:title>
		</xsl:if>
		<xsl:if test="/root/env/createdFromTemplate='n'">
			<xsl:call-template name="updateElementWithCharacterStringChild"/>
		</xsl:if>
	</xsl:template>

	<!-- Apply same changes as above to the gmd:LocalisedCharacterString -->
	<xsl:variable name="language" select="//gmd:PT_Locale" /> <!-- Need list of all locale -->
	<xsl:template  match="gmd:LocalisedCharacterString">
		<xsl:element name="gmd:{local-name()}">
			<xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
			<xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', ''))=string($currentLocale)]"/>
			<xsl:variable name="id" select="upper-case(substring($ptLocale/gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="$id != '' and ($currentLocale='' or @locale!=concat('#', $id)) ">
				<xsl:attribute name="locale">
					<xsl:value-of select="concat('#',$id)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- copy everything else as is -->
	
	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- Adjust the namespace declaration - In some cases name() is used to get the 
		element. The assumption is that the name is in the format of  <ns:element> 
		however in some cases it is in the format of <element xmlns=""> so the 
		following will convert them back to the expected value. This also corrects the issue 
		where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
	<!-- Note: Only included prefix gml, gmd and gco for now. -->
	<!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
	<!-- ================================================================= -->

	<xsl:template name="correct_ns_prefix">
		<xsl:param name="element" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="local-name($element)=name($element) and $prefix != '' ">
				<xsl:element name="{$prefix}:{local-name($element)}">
					<xsl:apply-templates select="@*|node()"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="gmd:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gmd'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="gco:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gco'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="gml:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gml'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Replace gmx:Anchor element by a simple gco:CharacterString.
		gmx:Anchor is usually used for linking element using xlink.
		TODO : Currently gmx:Anchor is not supported
	-->
	<xsl:template match="gmx:Anchor">
		<gco:CharacterString>
			<xsl:value-of select="."/>
		</gco:CharacterString>
	</xsl:template>

	<xsl:template match="srv:serviceType">
	    <xsl:copy>
			<xsl:if test="normalize-space(gco:LocalName)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:topicCategory">
	    <xsl:copy>
			<xsl:if test="normalize-space(gmd:MD_TopicCategoryCode)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:linkage">
	    <xsl:copy>
			<xsl:variable name="url" select="normalize-space(gmd:URL)"/>
			<xsl:if test="normalize-space($url)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:variable name="fileIdentifier" select="/root/gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString"/>
			<xsl:if test="contains($url, $fileIdentifier)">
				<gmd:URL><xsl:value-of select="concat(substring-before($url, $fileIdentifier),/root/env/uuid,substring-after($url, $fileIdentifier))"/></gmd:URL>
			</xsl:if>
			<xsl:if test="not(contains($url, $fileIdentifier))">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[*[@codeListValue]]">
		<xsl:copy>
			<xsl:if test="count(*[normalize-space(@codeListValue)=''])>0">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:parentIdentifier|gmd:voice|gmd:facsimile">
	    <xsl:copy>
			<xsl:copy-of select="@*[not(name()='gco:nilReason')]"/>
			<xsl:if test="normalize-space(gco:CharacterString)=''">
				<xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				<gco:CharacterString/>
			</xsl:if>
			<xsl:if test="not(normalize-space(gco:CharacterString)='')">
				<xsl:apply-templates select="*"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>