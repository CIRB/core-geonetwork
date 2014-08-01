<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gfc="http://www.isotc211.org/2005/gfc"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
  	xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<!-- =================================================================-->
	
	<xsl:template match="/root">
		<xsl:apply-templates select="gfc:FC_FeatureCatalogue|gfc:FC_FeatureType"/>
	</xsl:template>

	<!-- =================================================================-->
	
	<xsl:template match="gfc:FC_FeatureCatalogue|gfc:FC_FeatureType[not(parent::node())]">
		 <xsl:copy>
		 	<xsl:attribute name="uuid"><xsl:value-of select="/root/env/uuid"/></xsl:attribute>
		 	<xsl:apply-templates select="@*[name(.) != 'uuid']|node()"/>
		 </xsl:copy>
	</xsl:template>
	
	<!-- ================================================================= -->
	<!-- Emptying title if created from template -->
	<!-- ================================================================= -->
	<xsl:template match="gmx:name">
		<xsl:if test="/root/env/createdFromTemplate='y'">
			<gmx:name gco:nilReason="missing">
				<gco:CharacterString/>
			</gmx:name>
		</xsl:if>
		<xsl:if test="/root/env/createdFromTemplate='n'">
			<xsl:call-template name="updateElementWithCharacterStringChild"/>
		</xsl:if>
	</xsl:template>

	<!-- =================================================================-->

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

	<!-- =================================================================-->
	
	<xsl:template match="gfc:versionDate|gmx:versionDate">
        <xsl:choose>
            <xsl:when test="/root/env/changeDate">
                <xsl:copy>
                    <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

	<!-- =================================================================-->
	
	<xsl:template match="gfc:characterSet">
	    <xsl:copy>
            <gmd:MD_CharacterSetCode codeListValue="utf8" codeList="MD_CharacterSetCode" />
        </xsl:copy>
	</xsl:template>

	<!-- =================================================================-->
	
	<xsl:template match="@*|node()">
		 <xsl:copy>
			  <xsl:apply-templates select="@*|node()"/>
		 </xsl:copy>
	</xsl:template>

	<!-- =================================================================-->
	
	<!-- Handle xsi:nil attribute for max cardinality -->
	<xsl:template match="gco:UnlimitedInteger" priority="2">
		<xsl:variable name="isNil">
			<xsl:choose>
				<xsl:when test="@isInfinite = 'true' or string(.) = ''">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="not(@isInfinite)">
				<xsl:attribute name="isInfinite">
					<xsl:choose>
						<xsl:when test="string(.) = ''">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="nil" namespace="http://www.w3.org/2001/XMLSchema-instance">
				<xsl:value-of select="$isNil"/>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmx:FileName">
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
						<xsl:value-of select="@src"/> <!-- whatever is in there already -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>

