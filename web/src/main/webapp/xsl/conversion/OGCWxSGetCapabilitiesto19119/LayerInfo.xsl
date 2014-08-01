<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.opengis.net/wms" xmlns:wms="http://www.opengis.net/wms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="xhtml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:template match="/">
		<html>
		<body>
			<xsl:apply-templates/>
		</body>
		</html>
	</xsl:template>

	<xsl:template match="WMT_MS_Capabilities|wms:WMS_Capabilities">
		<xsl:for-each select="//Layer[count(./*[name(.)='Layer'])=0] | //wms:Layer[count(./*[name(.)='Layer'])=0]">
			<br/><br/><h2><xsl:value-of select="Title|wms:Title"/></h2>
			<b>Name:<xsl:text> </xsl:text></b><xsl:value-of select="Name|wms:Name"/>
			<br/><b>GeoNetwork URL:<xsl:text> </xsl:text></b>
			<xsl:variable name="href" select="MetadataURL/OnlineResource/@xlink:href|wms:MetadataURL/wms:OnlineResource/@xlink:href"/>
			<xsl:if test="$href">
				<a target="_blank" type="text/xml">
					<xsl:attribute name="href" select="$href"/>
					<xsl:value-of select="$href"/>
				</a>
			</xsl:if>			 
			<br/><b>Metadata standard name:<xsl:text> </xsl:text></b><xsl:value-of select="MetadataURL/@type|wms:MetadataURL/@type"/>
			<br/><b>Metadata mime-types:<xsl:text> </xsl:text></b><xsl:value-of select="string-join(MetadataURL/Format|wms:MetadataURL/wms:Format,',')"/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
