<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gml="http://www.opengis.net/gml" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:java="java:org.fao.geonet.util.XslUtil"
	exclude-result-prefixes="#all">

	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Metadata">
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

	<xsl:template match="gmd:extent[name(..)='gmd:MD_DataIdentification']|srv:extent[name(..)='srv:SV_ServiceIdentification']" priority="10">
	    <xsl:variable name="extentName" select="name(.)" />
	    <xsl:variable name="previousExtentSiblingsCount" select="count(preceding-sibling::*[name(.) = $extentName])" />
       	<xsl:if test="$previousExtentSiblingsCount=0">
			<xsl:if test="count(../*:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent)=0">
				<xsl:copy>
					<gmd:EX_Extent>
						<gmd:temporalElement>
							<gmd:EX_TemporalExtent>
								<gmd:extent>
									<gml:TimePeriod gml:id="{generate-id(.)}">
										<gml:beginPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:beginPosition>
										<gml:endPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:endPosition>
									</gml:TimePeriod>
								</gmd:extent>
							</gmd:EX_TemporalExtent>
						</gmd:temporalElement>
					</gmd:EX_Extent>
				</xsl:copy>
			</xsl:if>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent" priority="10">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="count(./*)=0">
					<gml:TimePeriod gml:id="{generate-id(.)}">
						<gml:beginPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:beginPosition>
						<gml:endPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:endPosition>
					</gml:TimePeriod>
				</xsl:when>
				<xsl:when test="gml:TimePeriod">
					<gml:TimePeriod gml:id="{if (@gml:id) then @gml:id else generate-id(gml:TimePeriod)}">
						<xsl:variable name="beginPositionExists" select="normalize-space(gml:TimePeriod/gml:beginPosition)!=''"/>
						<xsl:choose>
							<xsl:when test="$beginPositionExists">
								<xsl:apply-templates select="gml:TimePeriod/gml:beginPosition"/>
							</xsl:when>
							<xsl:otherwise>
								<gml:beginPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:beginPosition>
							</xsl:otherwise>
						</xsl:choose>
						<gml:endPosition><xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')" /></gml:endPosition>
					</gml:TimePeriod>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
<!--
	<xsl:template match="@gml:id">
		<xsl:choose>
			<xsl:when test="normalize-space(.)='' or normalize-space(.)='generate-id()'">
				<xsl:attribute name="gml:id">
					<xsl:value-of select="generate-id(.)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
-->
</xsl:stylesheet>
