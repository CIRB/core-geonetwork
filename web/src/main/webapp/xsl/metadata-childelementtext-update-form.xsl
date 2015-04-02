<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="java:org.fao.geonet.util.XslUtil">

	<xsl:include href="main.xsl"/>
    
	<xsl:variable name="profile"  select="/root/gui/session/profile"/>
	<!-- ================================================================================ -->
	<!-- page content	-->
	<!-- ================================================================================ -->

	<xsl:template mode="script" match="/">
		<script type="text/javascript" language="JavaScript">
			var userProfile = "<xsl:value-of select="$profile"/>";
			function init() {
				onFilterChanged();
			}
			function updateFields(combo) {
				var value = combo.options[combo.selectedIndex].value; 
				switch(value) {
					case "1":
					case "2":
						if (value=="1") {
							document.getElementById("xpathExpression").value = "gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition";
						} else if (value=="2") {
							document.getElementById("xpathExpression").value = "gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition";
						}
						document.getElementById("childTextValue").value = "<xsl:value-of select="java:getCurrentDateTime('yyyy-MM-dd','HH:mm:ss')"/>";
						document.getElementById("tooltip").innerHTML = "(yyyy-MM-ddTHH:mm:ss <xsl:value-of select="/root/gui/strings/tootlipOr"/> yyyy-MM-dd)";
						break;
					default:
						document.getElementById("xpathExpression").value = "";
						document.getElementById("childTextValue").value = "";
						document.getElementById("tooltip").innerHTML = "";
						break;
				}
			}
			function onFilterChanged() {
				var value = getRadioButtonValue(document.getElementsByName("filterChoice"));
				if (value=="1") {
					document.getElementById("uuids").disabled = false;
				} 
				if (value=="2") {
					document.getElementById("groups").disabled = false;
				}
				if (value!="1") {
					document.getElementById("uuids").value = "";
					document.getElementById("uuids").disabled = true; 
				}
				if (value!="2" &amp;&amp; userProfile=="Administrator") {
					var groupsElem = document.getElementById("groups") 
					groupsElem.value = "";
					groupsElem.selectedIndex = -1;
					groupsElem.disabled = true; 
				}
			}
			function submitForm() {
				var value = getRadioButtonValue(document.getElementsByName("filterChoice"));
				var uuids = document.getElementById("uuids").value;
				var groups = document.getElementById("groups").value;
				var xpathExpression = document.getElementById("xpathExpression").value;
				var childTextValue = document.getElementById("childTextValue").value;
				var message = "";
				var bProceed = true;
				switch(value) {
					case "1":
						if (uuids==null || uuids.trim()=="") {
							message = "<xsl:value-of select="/root/gui/strings/uuids"/>";
						}
						break;
					case "2":
						if (groups==null || groups.trim()=="") {
							message = "<xsl:value-of select="/root/gui/strings/usergroups"/>";
						}
						break;
					default:
						break;
				}
				if (userProfile!="Administrator") {
					if (groups==null || groups.trim()=="") {
						message = "<xsl:value-of select="/root/gui/strings/usergroups"/>";
					}
				}
				if (xpathExpression==null || xpathExpression.trim()=="") {
					message += (message.length > 0 ? "\n" : "") + "<xsl:value-of select="/root/gui/strings/xpathExpression"/>";
				}
				if (childTextValue==null || childTextValue.trim()=="") {
					message += (message.length > 0 ? "\n" : "") + "<xsl:value-of select="/root/gui/strings/updateValue"/>";
				}
				if (message.length > 0) {
					alert("<xsl:value-of select="/root/gui/strings/isMandatory"/>" + "\n\n" + message);
				}
				if (value==3) {
					var r = confirm(userProfile=="Administrator" ? "<xsl:value-of select="/root/gui/strings/updateAllMetadata"/>" : "<xsl:value-of select="/root/gui/strings/updateAllMetadataOfGroups"/>");
					if (r == false) {
					    bProceed = false;
					}
				}
				if (bProceed &amp;&amp; message.length==0) {
 					return goSubmit("xmlUpdate");
 				} else {
 					return false;
 				}
			}
			
			function getRadioButtonValue(radioButton)
			{
				var i = 0;
				value = "";
				if (radioButton.length!=null)
				{
					for (i=0;i &lt; radioButton.length;i++)
					{
						if (radioButton[i].checked)
						{
							value = radioButton[i].value;
							break;
						}
					}
				}
				else
				{
					if (radioButton.checked)
						value = radioButton.value;
				}
				return value;
			}

			
		</script>
	</xsl:template>

	<xsl:template name="content">
		<xsl:call-template name="formLayout">
			<xsl:with-param name="title" select="/root/gui/strings/xmlUpdate"/>
			<xsl:with-param name="content">
				<form name="xmlUpdate" accept-charset="UTF-8" method="post" action="{/root/gui/locService}/metadata.xmlchildelementtextupdate"
				      enctype="application/x-www-form-urlencoded" encoding="application/x-www-form-urlencoded" target="_self">
					<input type="submit" style="display: none;" />
			        <xsl:variable name="lang" select="/root/gui/language"/>
					<table id="gn.UpdateTable" class="text-aligned-left">
				        <!-- stylesheet -->
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/xpathExpressionHelper"/>
				            </th>
				            <td class="padded">
				                <select class="content" name="xpathExpressionHelper" onchange="updateFields(this);">
				                	<option value="0"></option>
				                	<option value="1">Dataset-metadata - temporal extent - endposition</option>
				                	<option value="2">Service-metadata - temporal extent - endposition</option>
			                	</select>
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/xpathExpression"/> (*)
				            </th>
				            <td class="padded">
				                <input class="content" type="text" style="width:400px" id="xpathExpression" name="xpathExpression" />
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <td class="padded" colspan="2">
				            	<xsl:for-each select="/root/gui/strings/filterChoice">
				            		<xsl:choose>
										<xsl:when test="$profile = 'Administrator'">
							                <input class="content" type="radio" name="filterChoice" onchange="onFilterChanged()">
								                <xsl:attribute name="value"><xsl:value-of select="./@value" /></xsl:attribute>
												<xsl:if test="./@value='1'">
													<xsl:attribute name="checked"/>
												</xsl:if>
								                <xsl:value-of select="." />
							                </input>
						                </xsl:when>
										<xsl:otherwise>
											<xsl:if test="./@value!='2'">
								                <input class="content" type="radio" name="filterChoice" onchange="onFilterChanged()">
									                <xsl:attribute name="value"><xsl:value-of select="./@value" /></xsl:attribute>
													<xsl:if test="./@value='1'">
														<xsl:attribute name="checked"/>
													</xsl:if>
									                <xsl:value-of select="." />
								                </input>
							                </xsl:if>
						                </xsl:otherwise>
				            		</xsl:choose>
				            	</xsl:for-each>
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/uuids"/>
				            </th>
				            <td class="padded">
								<textarea class="content" id="uuids" name="uuids" cols="60" rows="6" wrap="soft"></textarea>
				            </td>
				        </tr>
				        <tr id="gn.stylesheet">
							<th class="padded"><xsl:value-of select="/root/gui/strings/usergroups"/></th>
							<td class="padded">
								<select class="content" size="7" name="groups" multiple="" id="groups">
									<xsl:choose>
										<xsl:when test="$profile = 'Administrator'">
											<xsl:attribute name="disabled">disabled</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
										</xsl:otherwise>
									</xsl:choose>
 									<xsl:for-each select="/root/gui/groups/record">
										<xsl:sort select="name"/>
										<xsl:choose>
											<xsl:when test="$profile = 'Administrator'">
												<option value="{id}">
													<xsl:value-of select="label/child::*[name() = $lang]"/>
												</option>
											</xsl:when>
											<xsl:otherwise>
												<option value="{id}">
													<xsl:attribute name="selected">selected</xsl:attribute>
													<xsl:value-of select="label/child::*[name() = $lang]"/>
												</option>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</select>
							</td>
				        </tr>
				        <tr id="gn.stylesheet">
				            <th class="padded">
				                <xsl:value-of select="/root/gui/strings/updateValue"/> (*)
				            </th>
				            <td class="padded">
				                <input class="content" type="text" id="childTextValue" name="childTextValue" />
				                <span id="tooltip"></span>
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
				<button class="content" onclick="return submitForm()"  id="btUpdate"><xsl:value-of select="/root/gui/strings/existingUpdate"/></button>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ================================================================================ -->

</xsl:stylesheet>
