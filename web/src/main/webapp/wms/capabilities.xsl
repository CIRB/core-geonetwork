<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:sld="http://www.opengis.net/sld" xmlns:ms="http://mapserver.gis.umn.edu/mapserver" xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0" xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" xmlns="http://www.opengis.net/wms" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:wfs="http://www.opengis.net/wfs" xmlns:wcs="http://www.opengis.net/wcs" xmlns:wms="http://www.opengis.net/wms" xmlns:ows="http://www.opengis.net/ows" xmlns:owsg="http://www.opengeospatial.net/ows" xmlns:ows11="http://www.opengis.net/ows/1.1" xmlns:wps="http://www.opengeospatial.net/wps" xmlns:wps1="http://www.opengis.net/wps/1.0.0" exclude-result-prefixes="#all">
	<!-- ============================================================================= -->
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- ============================================================================= -->
	<xsl:include href="params.xsl"/>
	<xsl:include href="params-fre.xsl"/>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- ============================================================================= -->
	<xsl:template match="WMT_MS_Capabilities|wfs:WFS_Capabilities|wcs:WCS_Capabilities|
	       wps:Capabilities|wps1:Capabilities|wms:WMS_Capabilities|WMS_Capabilities">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xsi:schemaLocation">http://inspire.ec.europa.eu/schemas/inspire_vs/1.0 http://inspire.ec.europa.eu/schemas/inspire_vs/1.0/inspire_vs.xsd</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='Title' and local-name(..)='Service']">
		<xsl:message>Updating Title</xsl:message>
		<xsl:copy>
			<xsl:value-of select="$title"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='Abstract' and local-name(..)='Service']">
		<xsl:message>Updating Abstract</xsl:message>
		<xsl:copy>
			<xsl:value-of select="$abstract"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='ContactOrganization' and local-name(..)='ContactPersonPrimary']">
		<xsl:message>Updating ContactOrganization</xsl:message>
		<xsl:copy>
			<xsl:call-template name="getOrganisationName"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='ContactInformation' and local-name(..)='Service']">
		<xsl:copy>
			<xsl:apply-templates select="*[local-name()='ContactPersonPrimary']"/>
			<xsl:copy-of select="*[local-name()!='ContactPersonPrimary']"/>
		</xsl:copy>
		<Fees>
			<xsl:value-of select="$fees"/>
		</Fees>
		<AccessConstraints>
			<xsl:value-of select="$accessConstraints"/>
		</AccessConstraints>
	</xsl:template>
	
	<xsl:template match="*[local-name()='Fees' and local-name(..)='Service']">
		<xsl:message>Neglecting Fees</xsl:message>
	</xsl:template>

	<xsl:template match="*[local-name()='AccessConstraints' and local-name(..)='Service']">
		<xsl:message>Neglecting AccessConstraints</xsl:message>
	</xsl:template>

	<xsl:template match="*[local-name()='Layer' and local-name(..)='Capability']">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:message>Neglecting common CRS List</xsl:message>
			<xsl:apply-templates select="*[local-name()!='CRS']"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='Layer' and local-name(..)='Layer']">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[local-name()='Name']"/>
			<xsl:apply-templates select="*[local-name()='Title']"/>
			<xsl:apply-templates select="*[local-name()='Abstract']"/>
			<xsl:apply-templates select="*[local-name()='KeywordList']"/>
			<xsl:apply-templates select="*[local-name()='CRS']"/>
			<xsl:apply-templates select="*[local-name()='EX_GeographicBoundingBox']"/>
			<xsl:apply-templates select="*[local-name()='BoundingBox']"/>
			<xsl:apply-templates select="*[local-name()='Dimension']"/>
			<xsl:apply-templates select="*[local-name()='Attribution']"/>
			<xsl:apply-templates select="*[local-name()='AuthorityURL']"/>
			<xsl:apply-templates select="*[local-name()='Identifier']"/>
			<MetadataURL type="ISO19115:2003">
				<Format>text/xml</Format>
				<xsl:variable name="layerName" select="*[local-name()='Name']/normalize-space(.)"/>
				<xsl:message select="concat('Layer with name:',$layerName)"/>
				<OnlineResource xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="http://www.geo.irisnetlab.be/geonetwork/'srv/eng/csw?Request=GetRecordById&amp;Service=CSW&amp;Version=2.0.2&amp;elementSetName=full&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;id={$Layers/Layer[@name=$layerName]/fileIdentifier}aaaaaaaaaaaaaaa"/>
			</MetadataURL>
			<xsl:apply-templates select="*[local-name()='DataURL']"/>
			<xsl:apply-templates select="*[local-name()='FeatureListURL']"/>
			<xsl:apply-templates select="*[local-name()='Style']"/>
			<xsl:apply-templates select="*[local-name()='MinScaleDenominator']"/>
			<xsl:apply-templates select="*[local-name()='MaxScaleDenominator']"/>
			<xsl:apply-templates select="*[local-name()='Layer']"/>
		</xsl:copy>
	</xsl:template>
	<!--
	<xsl:template match="*[local-name()='MetadataURL' and @format!='']">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='format' or name()='type')]"/>
			<xsl:attribute name="type">19115</xsl:attribute>
			<xsl:attribute name="format">text/xml</xsl:attribute>
			<xsl:value-of select="replace(replace(replace(replace(replace(normalize-space(.),'geonetwork.geobru.irisnet','www.geo.irisnet'),'geobru.irisnet','www.geo.irisnet'),'apps/search/index.html.uuid','srv/eng/csw?Request=GetRecordById&amp;Service=CSW&amp;Version=2.0.2&amp;elementSetName=full&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;id'),'newgeonetwork','geonetwork'),'irisnetlab','irisnet')"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[local-name()='MetadataURL' and count(*[local-name()='Format'])>0]">
		<xsl:copy>
			<xsl:copy-of select="@*[not(name()='type')]"/>
			<xsl:attribute name="type">ISO19115:2003</xsl:attribute>
			<Format>text/xml</Format>
			<xsl:variable name="onlineResource" select="replace(replace(replace(replace(replace(*[local-name()='OnlineResource']/@xlink:href, 'geonetwork.geobru.irisnet','www.geo.irisnet'),'geobru.irisnet','www.geo.irisnet'),'apps/search/index.html.uuid','srv/eng/csw?Request=GetRecordById&amp;Service=CSW&amp;Version=2.0.2&amp;elementSetName=full&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;id'),'newgeonetwork','geonetwork'),'irisnetlab','irisnet')"/>
			<OnlineResource xlink:href="{$onlineResource}"/>
			<xsl:message select="concat('Modified URL:',$onlineResource)"/>
		</xsl:copy>
	</xsl:template>
-->
	<xsl:template match="sld:UserDefinedSymbolization|sld:DescribeLayer|sld:GetLegendGraphic|ms:GetStyles"/>
	<xsl:template match="*[local-name(.)='Exception']">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="*"/>
		</xsl:copy>
		<inspire_vs:ExtendedCapabilities>
			<inspire_common:ResourceLocator>
				<inspire_common:URL>
					<xsl:value-of select="concat('http://www.geo.irisnetlab.be/geonetwork/wms/',$organisationShortName,'-1.3.0-20150225-static-',$lang,'.xml')"/>
				</inspire_common:URL>
				<inspire_common:MediaType>application/vnd.ogc.wms_xml</inspire_common:MediaType>
			</inspire_common:ResourceLocator>
			<inspire_common:ResourceType>service</inspire_common:ResourceType>
			<inspire_common:TemporalReference>
				<inspire_common:DateOfLastRevision>2015-02-25</inspire_common:DateOfLastRevision>
			</inspire_common:TemporalReference>
			<inspire_common:Conformity>
				<inspire_common:Specification xsi:type="inspire_common:citationInspireInteroperabilityRegulation_{$lang}">
					<xsl:choose>
						<xsl:when test="$lang='fre'">
							<inspire_common:Title>RÈGLEMENT (UE) N o 1089/2010 DE LA COMMISSION du 23 novembre 2010 portant modalités d&apos;application de la directive 2007/2/CE du Parlement européen et du Conseil en ce qui concerne l&apos;interopérabilité des séries et des services de données géographiques</inspire_common:Title>
							<inspire_common:DateOfPublication>2010-12-08</inspire_common:DateOfPublication>
							<inspire_common:URI>OJ:L:2010:323:0011:0102:FR:PDF</inspire_common:URI>
							<inspire_common:ResourceLocator>
								<inspire_common:URL>
									http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2010:323:0011:0102:FR:PDF
								</inspire_common:URL>
								<inspire_common:MediaType>application/pdf</inspire_common:MediaType>
							</inspire_common:ResourceLocator>
						</xsl:when>
						<xsl:when test="$lang='dut'">
							<inspire_common:Title>VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</inspire_common:Title>
							<inspire_common:DateOfPublication>2010-12-08</inspire_common:DateOfPublication>
							<inspire_common:URI>OJ:L:2010:323:0011:0102:NL:PDF</inspire_common:URI>
							<inspire_common:ResourceLocator>
								<inspire_common:URL>
									http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2010:323:0011:0102:NL:PDF
								</inspire_common:URL>
								<inspire_common:MediaType>application/pdf</inspire_common:MediaType>
							</inspire_common:ResourceLocator>
						</xsl:when>
						<xsl:otherwise>
							<inspire_common:Title>COMMISSION REGULATION (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services</inspire_common:Title>
							<inspire_common:DateOfPublication>2010-12-08</inspire_common:DateOfPublication>
							<inspire_common:URI>OJ:L:2010:323:0011:0102:EN:PDF</inspire_common:URI>
							<inspire_common:ResourceLocator>
								<inspire_common:URL>
									http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2010:323:0011:0102:EN:PDF
								</inspire_common:URL>
								<inspire_common:MediaType>application/pdf</inspire_common:MediaType>
							</inspire_common:ResourceLocator>
						</xsl:otherwise>
					</xsl:choose>
				</inspire_common:Specification>
				<inspire_common:Degree>notEvaluated</inspire_common:Degree>
			</inspire_common:Conformity>
			<inspire_common:MetadataPointOfContact>
				<inspire_common:OrganisationName>
					<xsl:call-template name="getOrganisationName"/>
				</inspire_common:OrganisationName>
				<inspire_common:EmailAddress>
					<xsl:value-of select="//*[local-name(.)='ContactElectronicMailAddress']"/>
				</inspire_common:EmailAddress>
			</inspire_common:MetadataPointOfContact>
			<inspire_common:MetadataDate>2015-02-25</inspire_common:MetadataDate>
			<inspire_common:SpatialDataServiceType>view</inspire_common:SpatialDataServiceType>
			<inspire_common:MandatoryKeyword xsi:type="inspire_common:classificationOfSpatialDataService">
				<inspire_common:KeywordValue>infoMapAccessService</inspire_common:KeywordValue>
			</inspire_common:MandatoryKeyword>
			<xsl:choose>
				<xsl:when test="$organisationShortName='BRUGIS'">
					<inspire_common:Keyword xsi:type="inspire_common:inspireTheme_dut">
						<inspire_common:OriginatingControlledVocabulary xsi:type="inspire_common:originatingControlledVocabularyGemetInspireThemes">
							<inspire_common:Title>GEMET - INSPIRE themes</inspire_common:Title>
							<inspire_common:DateOfPublication>2008-06-01</inspire_common:DateOfPublication>
						</inspire_common:OriginatingControlledVocabulary>
						<inspire_common:KeywordValue>Beschermde gebieden</inspire_common:KeywordValue>
					</inspire_common:Keyword>
				</xsl:when>
				<xsl:when test="$organisationShortName='CIRB'">
					<inspire_common:Keyword xsi:type="inspire_common:inspireTheme_fre">
						<inspire_common:OriginatingControlledVocabulary xsi:type="inspire_common:originatingControlledVocabularyGemetInspireThemes">
							<inspire_common:Title>GEMET - INSPIRE themes</inspire_common:Title>
							<inspire_common:DateOfPublication>2008-06-01</inspire_common:DateOfPublication>
						</inspire_common:OriginatingControlledVocabulary>
						<inspire_common:KeywordValue>Ortho-imagerie</inspire_common:KeywordValue>
					</inspire_common:Keyword>
				</xsl:when>
			</xsl:choose>
			<inspire_common:SupportedLanguages xsi:type="inspire_common:supportedLanguagesType">
				<inspire_common:DefaultLanguage>
					<inspire_common:Language>
						<xsl:value-of select="$lang"/>
					</inspire_common:Language>
				</inspire_common:DefaultLanguage>
			</inspire_common:SupportedLanguages>
			<inspire_common:ResponseLanguage>
				<inspire_common:Language>
					<xsl:value-of select="$lang"/>
				</inspire_common:Language>
			</inspire_common:ResponseLanguage>
			<inspire_common:MetadataUrl xsi:type="inspire_common:resourceLocatorType">
				<inspire_common:URL>http://www.geo.irisnetlab.be/geonetwork/srv/fr/csw?service=CSW&amp;Request=GetRecordById&amp;elementSetName=full&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;id=8916478c-45ba-d860-390f-d20f-c29e-e4bb-3b9fd2b5&amp;version=2.0.2</inspire_common:URL>
				<inspire_common:MediaType>application/vnd.iso.19139+xml</inspire_common:MediaType>
			</inspire_common:MetadataUrl>
		</inspire_vs:ExtendedCapabilities>
	</xsl:template>
	<xsl:template name="getOrganisationName">
		<xsl:choose>
			<xsl:when test="$organisationShortName='BRUXELLES-MOBILITE'">Bruxelles Mobilité / Mobiel Brussel</xsl:when>
			<xsl:when test="$organisationShortName='CIRB'">CIRB / CIBG</xsl:when>
			<xsl:when test="$organisationShortName='IBGE'">Bruxelles Environnement / Leefmilieu Brussel</xsl:when>
			<xsl:when test="$organisationShortName='STIB'">STIB / MIVB</xsl:when>
			<xsl:when test="$organisationShortName='IBSA'">IBSA / BISA</xsl:when>
			<xsl:when test="$organisationShortName='BRUGIS'">Bruxelles Développement Urbain / Brussel Stedelijke Ontwikkeling</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
