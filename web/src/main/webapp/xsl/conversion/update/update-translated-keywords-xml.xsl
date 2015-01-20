<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" exclude-result-prefixes="#all">

	<!-- ================================================================= -->

	<xsl:variable name="metadataLanguage" select="upper-case(gmd:MD_Metadata/gmd:language/gmd:LanguageCode/@codeListValue/.)"/>
	<xsl:template match="gmd:MD_Metadata">
		<xsl:message select="$metadataLanguage"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:keyword[gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString/@locale=concat('#',$metadataLanguage)]" priority="10">
		<xsl:message>Updating</xsl:message>
		<gmd:keyword xsi:type="gmd:PT_FreeText_PropertyType">
			<xsl:variable name="value" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$metadataLanguage)]"/>
			<xsl:variable name="valueFRE" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#FRE']"/>
			<xsl:variable name="valueENG" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#ENG']"/>
			<xsl:variable name="valueDUT" select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale='#DUT']"/>
			<gco:CharacterString><xsl:value-of select="$value"/></gco:CharacterString>
			<gmd:PT_FreeText>
				<gmd:textGroup>
					<gmd:LocalisedCharacterString locale="#FRE"><xsl:value-of select="if ($valueFRE!='') then $valueFRE else $value"/></gmd:LocalisedCharacterString>
				</gmd:textGroup>
				<gmd:textGroup>
					<gmd:LocalisedCharacterString locale="#ENG"><xsl:value-of select="if ($valueENG!='') then $valueENG else $value"/></gmd:LocalisedCharacterString>
				</gmd:textGroup>
				<gmd:textGroup>
					<gmd:LocalisedCharacterString locale="#DUT"><xsl:value-of select="if ($valueDUT!='') then $valueDUT else $value"/></gmd:LocalisedCharacterString>
				</gmd:textGroup>
			</gmd:PT_FreeText>
		</gmd:keyword>
	</xsl:template>
</xsl:stylesheet>
