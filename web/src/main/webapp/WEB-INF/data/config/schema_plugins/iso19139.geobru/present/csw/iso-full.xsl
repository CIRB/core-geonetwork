<?xml version="1.0" encoding="UTF-8"?>
<!-- heikki added geobru namespace declaration and exclude-result-prefix for geobru -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:geobru="http://geobru.irisnet.be"
										xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
										xmlns:dc ="http://purl.org/dc/elements/1.1/"
										xmlns:dct="http://purl.org/dc/terms/"
										xmlns:gmd="http://www.isotc211.org/2005/gmd"
										xmlns:ows="http://www.opengis.net/ows"
										xmlns:geonet="http://www.fao.org/geonetwork"
										xmlns:skos="http://www.w3.org/2004/02/skos/core#"
										exclude-result-prefixes="geobru">

	<xsl:param name="lang"/>
	<xsl:param name="displayInfo"/>
	<xsl:param name="thesauriDir"/>
	
	<xsl:include href="../../../iso19139/present/metadata-iso19139-utils.xsl"/>

	<xsl:variable name="inspire-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
	<xsl:variable name="inspireThemes" select="$inspire-thesaurus//skos:Concept"/>
	
	<!-- ============================================================================= -->
<!--
	<xsl:template match="gmd:MD_Metadata">
		<csw:IsoRecord>
			<xsl:apply-templates select="*"/>
		</csw:IsoRecord>
	</xsl:template>
-->
	<!-- ============================================================================= -->
	
	<!-- heikki: added conversion for geobru extension elements -->
	<xsl:template match="geobru:BXL_Address">
		<gmd:CI_Address>
				<xsl:apply-templates select="@*|node()"/>
		</gmd:CI_Address>
	</xsl:template>

	<!-- heikki: added conversion for geobru extension elements -->
	<xsl:template match="geobru:BXL_Lineage">
		<gmd:LI_Lineage>
				<xsl:apply-templates select="@*|node()"/>
		</gmd:LI_Lineage>
	</xsl:template>	
	
	<!-- heikki: added conversion for geobru extension elements -->
	<xsl:template match="geobru:BXL_Distribution">
		<gmd:MD_Distribution>
				<xsl:apply-templates select="@*|node()"/>
		</gmd:MD_Distribution>
	</xsl:template>		
	
	<!-- heikki: added conversion for geobru extension elements -->
	<xsl:template match="geobru:*">
	</xsl:template>	
	

	

	<xsl:template match="@*|node()[name(.)!='geonet:info']">
		<xsl:variable name="info" select="geonet:info"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()[name(.)!='geonet:info']"/>
			<!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
			<xsl:if test="$displayInfo = 'true'">
				<xsl:copy-of select="$info"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template match="gmd:keyword[gco:CharacterString]" priority="1000">
		<gmd:keyword>
			<xsl:message select="concat('Language is ',$lang)"/>
			<xsl:variable name="localisedCharacterString" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',upper-case($lang))]"/>
			<xsl:variable name="englishCharacterString" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#ENG']"/>
			<xsl:variable name="edition" select="../gmd:thesaurusName/gmd:CI_Citation/gmd:edition/gco:CharacterString"/>
			<xsl:message select="concat('Edition :',$edition)"/>
			<xsl:if test="$edition='http://geonetwork-opensource.org/inspire-theme' and $englishCharacterString!=''">
				<xsl:variable name="anchor">
					<xsl:call-template name="getAnchorByEnglishInspireTheme">
						<xsl:with-param name="keyword" select="$englishCharacterString"/>
						<xsl:with-param name="inspireThemes" select="$inspireThemes"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:message select="concat('Used Anchor with id ',$anchor)"/>
			</xsl:if>
			<xsl:if test="$localisedCharacterString!=''">
				<xsl:message select="concat('Used translated value ',$localisedCharacterString)"/>
				<gco:CharacterString><xsl:value-of select="$localisedCharacterString"/></gco:CharacterString>
			</xsl:if>
			<xsl:if test="$localisedCharacterString=''">
				<xsl:message select="concat('Used untranslated value ',gco:CharacterString)"/>
				<gco:CharacterString><xsl:value-of select="gco:CharacterString"/></gco:CharacterString>
			</xsl:if>
		</gmd:keyword>
	</xsl:template>
</xsl:stylesheet>
