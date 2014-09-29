<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="java:org.fao.geonet.util.XslUtil">

	<xsl:include href="main.xsl"/>
    
	<!-- ================================================================================ -->
	<!-- page content	-->
	<!-- ================================================================================ -->

	<xsl:template mode="script" match="/">
		<script type="text/javascript" language="JavaScript">
			function init() {
			}

		</script>
	</xsl:template>

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/strings/xmlUpdate"/>
			<xsl:with-param name="content">
				<form name="xmlUpdate" accept-charset="UTF-8" method="post" action="{/root/gui/locService}/metadata.xmlchildelementtextupdate"
				      enctype="application/x-www-form-urlencoded" encoding="application/x-www-form-urlencoded" target='_self'>
					<input type="submit" style="display: none;" />
			        <xsl:variable name="lang" select="/root/gui/language"/>
	                <input type="hidden" name="styleSheet" value="update-change-date.xsl"/>
	                <input type="hidden" name="childElementPath" value="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition"/>
					<table id="gn.UpdateTable" class="text-aligned-left">
				        <!-- stylesheet -->
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/uuids"/>
				            </th>
				            <td class="padded">
								<textarea class="content" name="uuids" cols="60" rows="6" wrap="soft"></textarea>
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/changeDate"/>
				            </th>
				            <td class="padded">
				                <input class="content" type="text" name="childTextValue" value="{java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')}" />(Format: yyyy-MM-dd'T'HH:mm:ss)
				            </td>
				        </tr>
 			        </table>
                    <table id="gn.result" style="display:none;">
	                    <tr>
	                        <th id="gn.resultTitle" class="padded-content">
	                            <h2><xsl:value-of select="/root/gui/strings/existingMdUpdate" /></h2>
	                        </th>
	                        <td id="gn.resultContent" class="padded-content" />
	                    </tr>
                    </table>
				</form>
			</xsl:with-param>
			<xsl:with-param name="buttons">
				<button class="content" onclick="goBack()" id="back"><xsl:value-of select="/root/gui/strings/back"/></button>
				&#160;
				<button class="content" onclick="return goSubmit('xmlUpdate');"  id="btUpdate"><xsl:value-of select="/root/gui/strings/existingUpdate"/></button>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ================================================================================ -->

</xsl:stylesheet>
