<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fra="http://www.cnig.gouv.fr/2005/fra" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:date="http://exslt.org/dates-and-times"
	xmlns:exslt="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:geobru="http://geobru.irisnet.be"
	exclude-result-prefixes="xs" version="2.0">
<!--
	<xsl:template mode="iso19139" match="geobru:*[gco:CharacterString|gco:Date|gco:DateTime|gco:Integer|gco:Decimal|gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gco:Scale|gco:RecordType]">
		<xsl:message><xsl:value-of select="name(.)"/></xsl:message>
		<xsl:apply-templates mode="elementFop"
			select=".">
			<xsl:with-param name="schema">iso19139.geobru</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
-->
	<xsl:template name="Wmetadata-fop-iso19139.geobru">
		<xsl:param name="schema" />
		<xsl:param name="server" />
		<xsl:param name="metadata" />
		<xsl:call-template name="Wmetadata-fop-iso19139">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="server" select="$server"/>
			<xsl:with-param name="metadata" select="$metadata"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
