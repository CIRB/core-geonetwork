<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
				xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:srv="http://www.isotc211.org/2005/srv">
    <xsl:template match="gmd:MD_Metadata">
        <fileIdentifiers>
            <xsl:for-each  select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn[@xlink:href!='' and @uuidref!='']">
				<xsl:variable name="mduuidValue" select="@uuidref"/>
				<xsl:variable name="idParamValue" select="substring-after(@xlink:href,';id=')"/>
				<xsl:variable name="fileIdentifier">
					<xsl:call-template name="getUuidRelatedMetadata">
						<xsl:with-param name="mduuidValue" select="$mduuidValue"/>
						<xsl:with-param name="idParamValue" select="$idParamValue"/>
					</xsl:call-template>
           		</xsl:variable>
           		<fileIdentifier><xsl:value-of select="normalize-space($fileIdentifier)"/></fileIdentifier>                    	
			</xsl:for-each>
        </fileIdentifiers>
    </xsl:template>

    <xsl:template name="getUuidRelatedMetadata">
       	<xsl:param name="mduuidValue" />
		<xsl:param name="idParamValue" />
		<xsl:choose>
			<xsl:when test="contains($idParamValue,';')"><xsl:value-of select="substring(substring-before($idParamValue,';'),1,string-length(substring-before($idParamValue,';'))-4)"/></xsl:when>
			<xsl:when test="contains($idParamValue,'&amp;')"><xsl:value-of select="substring-before($idParamValue,'&amp;')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$idParamValue"/></xsl:otherwise>
		</xsl:choose>
    </xsl:template>
</xsl:stylesheet>