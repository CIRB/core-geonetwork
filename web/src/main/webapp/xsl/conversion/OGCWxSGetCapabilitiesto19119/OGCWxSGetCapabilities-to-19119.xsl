<?xml version="1.0" encoding="UTF-8"?>
<!-- Mapping between : - WMS 1.0.0 - WMS 1.1.1 - WMS 1.3.0 - WCS 1.0.0 - 
	WFS 1.0.0 - WFS 1.1.0 - WPS 0.4.0 - WPS 1.0.0 ... to ISO19119. -->
<xsl:stylesheet version="2.0"
	xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml"
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wfs="http://www.opengis.net/wfs" xmlns:wcs="http://www.opengis.net/wcs"
	xmlns:wms="http://www.opengis.net/wms" xmlns:ows="http://www.opengis.net/ows"
	xmlns:owsg="http://www.opengeospatial.net/ows" xmlns:ows11="http://www.opengis.net/ows/1.1"
	xmlns:wps="http://www.opengeospatial.net/wps" xmlns:wps1="http://www.opengis.net/wps/1.0.0"
	extension-element-prefixes="wcs ows wfs ows11 wps wps1 owsg">

	<!-- ============================================================================= -->

	<xsl:param name="uuid">uuid</xsl:param>
	<xsl:param name="lang">eng</xsl:param>
	<xsl:param name="topic"/>
	<xsl:param name="ogctype"/>
	<xsl:param name="titleDUT"/>
	<xsl:param name="titleENG"/>
	<xsl:param name="titleFRE"/>
	<xsl:param name="abstractDUT"/>
	<xsl:param name="abstractENG"/>
	<xsl:param name="abstractFRE"/>
	<xsl:param name="accessConstraintDUT1"/>
	<xsl:param name="accessConstraintENG1"/>
	<xsl:param name="accessConstraintFRE1"/>
	<xsl:param name="accessConstraintDUT2"/>
	<xsl:param name="accessConstraintENG2"/>
	<xsl:param name="accessConstraintFRE2"/>

	<!-- ============================================================================= -->

	<xsl:include href="resp-party.xsl" />
	<xsl:include href="ref-system.xsl" />
	<xsl:include href="identification.xsl" />

	<!-- ============================================================================= -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />

	<!-- ============================================================================= -->

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template
		match="WMT_MS_Capabilities|wfs:WFS_Capabilities|wcs:WCS_Capabilities|
	       wps:Capabilities|wps1:Capabilities|wms:WMS_Capabilities">

		<xsl:variable name="ows">
			<xsl:choose>
				<xsl:when
					test="(local-name(.)='WFS_Capabilities' and (namespace-uri(.)='http://www.opengis.net/wfs' or namespace-uri(.)='http://www.opengis.net/ows') and @version='1.1.0') 
					or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengeospatial.net/wps')
					or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wps/1.0.0')"><xsl:value-of select="true()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="wfs">
			<xsl:choose>
				<xsl:when
					test="local-name(.)='WFS_Capabilities' and (namespace-uri(.)='http://www.opengis.net/wfs' or namespace-uri(.)='http://www.opengis.net/ows') and @version='1.1.0'"><xsl:value-of select="true()"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			- -->

		<MD_Metadata>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->

			<fileIdentifier>
				<gco:CharacterString>
					<xsl:value-of select="$uuid" />
				</gco:CharacterString>
			</fileIdentifier>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->

			<language>
				<LanguageCode
					codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#LanguageCode"
					codeListValue="{$lang}">
					<xsl:value-of select="$lang" />
				</LanguageCode>
			</language>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->

			<characterSet>
				<MD_CharacterSetCode
					codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_CharacterSetCode"
					codeListValue="utf8" />
			</characterSet>

			<!-- parentIdentifier : service have no parent -->
			<!-- mdHrLv -->
			<hierarchyLevel>
				<MD_ScopeCode
					codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode"
					codeListValue="service" />
			</hierarchyLevel>

			<hierarchyLevelName>
				<gco:CharacterString>Service</gco:CharacterString>
			</hierarchyLevelName>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->
			<xsl:choose>
				<xsl:when
					test="Service/ContactInformation|
					wfs:Service/wfs:ContactInformation|
					wms:Service/wms:ContactInformation|
                    ows:ServiceProvider|
					owsg:ServiceProvider|
					ows11:ServiceProvider">
					<xsl:for-each
						select="Service/ContactInformation|
						wfs:Service/wfs:ContactInformation|
						wms:Service/wms:ContactInformation|
                        ows:ServiceProvider|
						owsg:ServiceProvider|
						ows11:ServiceProvider">
						<contact>
							<CI_ResponsibleParty>
								<xsl:apply-templates select="." mode="RespParty" />
							</CI_ResponsibleParty>
						</contact>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<contact gco:nilReason="missing" />
				</xsl:otherwise>
			</xsl:choose>
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->
			<xsl:variable name="df">
				[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]
			</xsl:variable>
			<dateStamp>
				<gco:DateTime>
					<xsl:value-of select="format-dateTime(current-dateTime(),$df)" />
				</gco:DateTime>
			</dateStamp>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->

			<metadataStandardName>
				<gco:CharacterString>ISO 19119</gco:CharacterString>
			</metadataStandardName>

			<metadataStandardVersion>
				<gco:CharacterString>2005/Amd 1:2008</gco:CharacterString>
			</metadataStandardVersion>
			<xsl:if test="$lang!='dut'">
				<locale>
					<PT_Locale id="DUT">
						<languageCode>
							<LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#gmd:LanguageCode" codeListValue="dut" />
						</languageCode>
						<characterEncoding />
					</PT_Locale>
				</locale>
			</xsl:if>
			<xsl:if test="$lang!='fre'">
				<locale>
					<PT_Locale id="FRE">
						<languageCode>
							<LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#gmd:LanguageCode" codeListValue="fre" />
						</languageCode>
						<characterEncoding />
					</PT_Locale>
				</locale>
			</xsl:if>
			<xsl:if test="$lang!='eng'">
				<locale>
					<PT_Locale id="ENG">
						<languageCode>
							<LanguageCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#gmd:LanguageCode" codeListValue="eng" />
						</languageCode>
						<characterEncoding />
					</PT_Locale>
				</locale>
			</xsl:if>
			<referenceSystemInfo>
				<MD_ReferenceSystem>
					<referenceSystemIdentifier>
						<RS_Identifier>
							<code>
								<gco:CharacterString>31370</gco:CharacterString>
							</code>
							<codeSpace>
								<gco:CharacterString>EPSG</gco:CharacterString>
							</codeSpace>
						</RS_Identifier>
					</referenceSystemIdentifier>
				</MD_ReferenceSystem>
			</referenceSystemInfo>
			<!--mdExtInfo -->
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
				- -->

			<identificationInfo>
				<srv:SV_ServiceIdentification>
					<xsl:apply-templates select="."
						mode="SrvDataIdentification">
						<xsl:with-param name="topic">
							<xsl:value-of select="$topic" />
						</xsl:with-param>
						<xsl:with-param name="ogctype">
							<xsl:value-of select="$ogctype" />
						</xsl:with-param>
						<xsl:with-param name="ows">
							<xsl:value-of select="$ows" />
						</xsl:with-param>
						<xsl:with-param name="wfs">
							<xsl:value-of select="$wfs" />
						</xsl:with-param>
						<xsl:with-param name="lang">
							<xsl:value-of select="$lang" />
						</xsl:with-param>
						<xsl:with-param name="titleDUT">
							<xsl:value-of select="$titleDUT" />
						</xsl:with-param>
						<xsl:with-param name="titleENG">
							<xsl:value-of select="$titleENG" />
						</xsl:with-param>
						<xsl:with-param name="titleFRE">
							<xsl:value-of select="$titleFRE" />
						</xsl:with-param>
						<xsl:with-param name="abstractDUT">
							<xsl:value-of select="$abstractDUT" />
						</xsl:with-param>
						<xsl:with-param name="abstractENG">
							<xsl:value-of select="$abstractENG" />
						</xsl:with-param>
						<xsl:with-param name="abstractFRE">
							<xsl:value-of select="$abstractFRE" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintDUT1">
							<xsl:value-of select="$accessConstraintDUT1" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintENG1">
							<xsl:value-of select="$accessConstraintENG1" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintFRE1">
							<xsl:value-of select="$accessConstraintFRE1" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintDUT2">
							<xsl:value-of select="$accessConstraintDUT2" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintENG2">
							<xsl:value-of select="$accessConstraintENG2" />
						</xsl:with-param>
						<xsl:with-param name="accessConstraintFRE2">
							<xsl:value-of select="$accessConstraintFRE2" />
						</xsl:with-param>
					</xsl:apply-templates>
				</srv:SV_ServiceIdentification>
			</identificationInfo>

			<!--contInfo -->
			<!--distInfo -->
			<distributionInfo>
				<MD_Distribution>
					<distributionFormat>
						<MD_Format>
							<name gco:nilReason="missing">
								<gco:CharacterString />
							</name>
							<version gco:nilReason="missing">
								<gco:CharacterString />
							</version>
						</MD_Format>
					</distributionFormat>
					<transferOptions>
						<MD_DigitalTransferOptions>
							<xsl:variable name="GetCapabilities" select="count(//ows:Operation[@name='GetCapabilities']) +
																			   count(//ows11:Operation[@name='GetCapabilities']) +
																			   count(//wms:GetCapabilities) +
																			   count(//wfs:GetCapabilities) +
																			   count(//GetCapabilities) +
																			   count(//wcs:GetCapabilities)" />
							<xsl:variable name="GetMap" select="count(//ows:Operation[@name='GetMap']) +
																			   count(//ows11:Operation[@name='GetMap']) +
																			   count(//wms:GetMap) +
																			   count(//GetMap)" />
							<xsl:variable name="GetFeatureInfo" select="count(//ows:Operation[@name='GetFeatureInfo']) +
																			   count(//ows11:Operation[@name='GetFeatureInfo']) +
																			   count(//wms:GetFeatureInfo) +
																			   count(//GetFeatureInfo)" />
							<xsl:variable name="DescribeFeatureType" select="count(//ows:Operation[@name='DescribeFeatureType']) +
																			   count(//ows11:Operation[@name='DescribeFeatureType']) +
																			   count(//wfs:DescribeFeatureType) +
																			   count(//DescribeFeatureType)" />
							<xsl:variable name="GetFeature" select="count(//ows:Operation[@name='GetFeature']) +
																			   count(//ows11:Operation[@name='GetFeature']) +
																			   count(//wfs:GetFeature) +
																			   count(//GetFeature)" />
							<xsl:variable name="GetGmlObject" select="count(//ows:Operation[@name='GetGmlObject']) +
																			   count(//ows11:Operation[@name='GetGmlObject']) +
																			   count(//wfs:GetGmlObject) +
																			   count(//GetGmlObject)" />
							<xsl:variable name="service">
								<xsl:choose>
									<xsl:when test="$ogctype='WMTS1.0.0'">WMTS</xsl:when>
									<xsl:when test="$ogctype='WMS1.1.1' or $ogctype='WMS1.3.0'">WMS</xsl:when>
									<xsl:when test="$ogctype='WFS1.0.0' or $ogctype='WFS1.1.0'">WFS</xsl:when>
									<xsl:otherwise>WCS</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="version">
								<xsl:choose>
<!--
									<xsl:when test="$ogctype='WMTS1.0.0' or $ogctype='WFS1.0.0'">1.0.0</xsl:when>
-->									
									<xsl:when test="$ogctype='WFS1.1.0'">1.1.0</xsl:when>
									<xsl:when test="$ogctype='WMS1.1.1'">1.1.1</xsl:when>
									<xsl:when test="$ogctype='WMS1.3.0'">1.3.0</xsl:when>
									<xsl:otherwise>1.0.0</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="$GetCapabilities>0">
								<xsl:variable name="getCapabilitiesUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">GetCapabilities</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$getCapabilitiesUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getCapabilitiesUrl"/>
										<xsl:with-param name="service" select="$service"/>
		                        	</xsl:call-template>
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getCapabilitiesUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'GetCapabilities'"/>
		                        	</xsl:call-template>
	                        	</xsl:if>
							</xsl:if>
							<xsl:if test="$GetMap>0">
								<xsl:variable name="getMapUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">GetMap</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$getMapUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getMapUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'GetMap'"/>
		                        	</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$GetFeatureInfo>0">
								<xsl:variable name="getFeatureInfoUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">GetFeatureInfo</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$getFeatureInfoUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getFeatureInfoUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'GetFeatureInfo'"/>
		                        	</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$DescribeFeatureType>0">
								<xsl:variable name="describeFeatureTypeUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">DescribeFeatureType</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$describeFeatureTypeUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$describeFeatureTypeUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'DescribeFeatureType'"/>
		                        	</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$GetFeature>0">
								<xsl:variable name="getFeatureUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">GetFeature</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$getFeatureUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getFeatureUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'GetFeature'"/>
		                        	</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$GetGmlObject>0">
								<xsl:variable name="getGmlObjectUrl"><xsl:call-template name="get-online-url-by-operation"><xsl:with-param name="operationName">GetGmlObject</xsl:with-param><xsl:with-param name="ows" select="$ows"/></xsl:call-template></xsl:variable>						   
								<xsl:if test="$getGmlObjectUrl!='?'">
		                        	<xsl:call-template name="get-onlines">
										<xsl:with-param name="ows" select="$ows"/>
										<xsl:with-param name="url" select="$getGmlObjectUrl"/>
										<xsl:with-param name="service" select="$service"/>
										<xsl:with-param name="version" select="$version"/>
										<xsl:with-param name="request" select="'GetGmlObject'"/>
		                        	</xsl:call-template>
								</xsl:if>
							</xsl:if>
						</MD_DigitalTransferOptions>
					</transferOptions>
				</MD_Distribution>
			</distributionInfo>
			<!--dqInfo -->
			<dataQualityInfo>
				<DQ_DataQuality>
					<scope>
						<DQ_Scope>
							<level>
								<MD_ScopeCode codeListValue="service"
									codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode" />
							</level>
							<levelDescription>
								<MD_ScopeDescription>
									<other>
										<gco:CharacterString>Service</gco:CharacterString>
									</other>
								</MD_ScopeDescription>
							</levelDescription>
						</DQ_Scope>
					</scope>
					<report>
						<DQ_DomainConsistency>
							<measureIdentification>
								<RS_Identifier>
									<code gco:nilReason="missing">
										<gco:CharacterString />
									</code>
									<codeSpace gco:nilReason="missing">
										<gco:CharacterString />
									</codeSpace>
								</RS_Identifier>
							</measureIdentification>
							<result>
								<DQ_ConformanceResult>
									<specification>
										<CI_Citation>
											<title>
<!--
												<xsl:choose>
													<xsl:when test="$lang='dut'">
														<gco:CharacterString>Verordening (EG) nr. 976/2009 van de Commissie van 19 oktober 2009 tot uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad wat betreft de netwerkdiensten</gco:CharacterString>
													</xsl:when>
													<xsl:when test="$lang='eng'">
														<gco:CharacterString>Commission Regulation (EC) No 1205/2008 of 3 December 2008 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards metadata</gco:CharacterString>
													</xsl:when>
													<xsl:otherwise>
														<gco:CharacterString>Règlement (CE) N o 976/2009 de la commission du 19 octobre 2009 portant modalités d’application de la directive 2007/2/CE du Parlement européen et du Conseil en ce qui concerne les services en réseau</gco:CharacterString>
													</xsl:otherwise>
												</xsl:choose>
-->
												<gco:CharacterString>Règlement (CE) N o 976/2009 de la commission du 19 octobre 2009 portant modalités d’application de la directive 2007/2/CE du Parlement européen et du Conseil en ce qui concerne les services en réseau</gco:CharacterString>
											</title>
											<alternateTitle gco:nilReason="missing">
												<gco:CharacterString />
											</alternateTitle>
											<date>
												<CI_Date>
													<date>
														<gco:Date>2009-10-19</gco:Date>
													</date>
													<dateType>
														<CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
													</dateType>
												</CI_Date>
											</date>
										</CI_Citation>
									</specification>
									<explanation>
<!--
										<xsl:choose>
											<xsl:when test="$lang='dut'">
												<gco:CharacterString>Zie de gerefereerde specificatie.</gco:CharacterString>
											</xsl:when>
											<xsl:when test="$lang='eng'">
												<gco:CharacterString>Voir la spécification référencée.</gco:CharacterString>
											</xsl:when>
											<xsl:otherwise>
												<gco:CharacterString>Voir la spécification référencée.</gco:CharacterString>
											</xsl:otherwise>
										</xsl:choose>
-->
										<gco:CharacterString>Voir la spécification référencée.</gco:CharacterString>
	
									</explanation>
									<pass>
										<gco:Boolean>true</gco:Boolean>
									</pass>
								</DQ_ConformanceResult>
							</result>
						</DQ_DomainConsistency>
					</report>
				</DQ_DataQuality>
			</dataQualityInfo>
			<!--mdConst -->
			<!--mdMaint -->

		</MD_Metadata>
	</xsl:template>

	<xsl:template name="get-online-url-by-operation">
		<xsl:param name="operationName">GetCapabilities</xsl:param>
		<xsl:param name="ows"/>
		<xsl:variable name="urls">
			<xsl:choose>
				<xsl:when test="$ows='true'">
					<xsl:value-of
						select="//ows:Operation[@name=$operationName]/ows:DCP/ows:HTTP/ows:Get/@xlink:href|//ows11:Operation[@name=$operationName]/ows11:DCP/ows11:HTTP/ows11:Get/@xlink:href" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$operationName='GetCapabilities'">
							<xsl:choose>
								<xsl:when test="name(.)='WMS_Capabilities'">
									<xsl:value-of
										select="//wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:when test="name(.)='WFS_Capabilities'">
									<xsl:value-of
										select="//wfs:GetCapabilities/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource" />
								</xsl:when>
								<xsl:when test="name(.)='WMT_MS_Capabilities'">
									<xsl:value-of
										select="//GetCapabilities/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="//wcs:GetCapabilities//wcs:OnlineResource[1]/@xlink:href" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$operationName='GetMap'">
							<xsl:choose>
								<xsl:when test="name(.)='WMS_Capabilities'">
									<xsl:value-of
										select="//wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:when test="name(.)='WMT_MS_Capabilities'">
									<xsl:value-of
										select="//GetMap/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$operationName='GetFeatureInfo'">
							<xsl:choose>
								<xsl:when test="name(.)='WMS_Capabilities'">
									<xsl:value-of
										select="//wms:GetFeatureInfo/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:when test="name(.)='WMT_MS_Capabilities'">
									<xsl:value-of
										select="//GetFeatureInfo/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$operationName='DescribeFeatureType'">
							<xsl:choose>
								<xsl:when test="name(.)='WFS_Capabilities'">
									<xsl:value-of
										select="//wfs:DescribeFeatureType/wfs:DCPType/wfs:HTTP/wfs:Get/wfs:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="//DescribeFeatureType/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$operationName='GetFeature'">
							<xsl:choose>
								<xsl:when test="name(.)='WFS_Capabilities'">
									<xsl:value-of
										select="//wfs:GetFeature/wfs:DCPType/wfs:HTTP/wfs:Get/wfs:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="//GetFeature/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$operationName='GetGmlObject'">
							<xsl:choose>
								<xsl:when test="name(.)='WFS_Capabilities'">
									<xsl:value-of
										select="//wfs:GetGmlObject/wfs:DCPType/wfs:HTTP/wfs:Get/wfs:OnlineResource/@xlink:href" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="//GetGmlObject/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="normalize-space($urls[1])" /><xsl:if test="not(contains($urls[1],'?'))">?</xsl:if>
	</xsl:template>
	
	<xsl:template name="get-onlines">
		<xsl:param name="ows"/>
		<xsl:param name="url"/>
		<xsl:param name="service"/>
		<xsl:param name="version"/>
		<xsl:param name="request"/>
		<xsl:variable name="linkage"><xsl:choose><xsl:when test="$request!=''"><xsl:value-of select="$url"/><xsl:if test="not(contains(lower-case($url),'service='))">service=<xsl:value-of select="$service"/>&amp;</xsl:if><xsl:if test="not(contains(lower-case($url),'version='))">version=<xsl:value-of select="$version"/>&amp;</xsl:if><xsl:if test="not(contains(lower-case($url),'request='))">request=<xsl:value-of select="$request"/></xsl:if></xsl:when><xsl:otherwise><xsl:value-of select="$url"/></xsl:otherwise></xsl:choose></xsl:variable>
		<onLine>
			<CI_OnlineResource>
				<linkage>
					<xsl:if test="$url=''">
						<xsl:attribute name="gco:nilReason" select="'missing'" />
					</xsl:if>
					<URL><xsl:value-of select="$linkage"/></URL>
				</linkage>
				<protocol>
					<gco:CharacterString>
						<xsl:choose>
							<xsl:when test="$request!=''">
									<xsl:call-template name="get-protocol-by-operation">
										<xsl:with-param name="operationName" select="$request"/>
										<xsl:with-param name="ogctype" select="$ogctype"/>
									</xsl:call-template>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="concat('OGC:',$service)"/></xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</protocol>
<!--
				<xsl:variable name="serviceName">
					<xsl:call-template name="get-name">
						<xsl:with-param name="ows">
							<xsl:value-of select="$ows" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
-->
				<xsl:variable name="serviceTitle">
					<xsl:call-template name="get-title">
						<xsl:with-param name="ows">
							<xsl:value-of select="$ows" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<name>
					<gco:CharacterString>
<!--
						<xsl:choose>
							<xsl:when test="not($serviceName='')">
								<xsl:value-of select="$serviceName" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="$serviceTitle" />
							</xsl:otherwise>
						</xsl:choose>
-->
						<xsl:value-of select="$serviceTitle"/>
					</gco:CharacterString>
				</name>
				<xsl:variable name="serviceAbstract">
					<xsl:call-template name="get-abstract">
						<xsl:with-param name="ows">
							<xsl:value-of select="$ows" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<description>
					<gco:CharacterString>
<!--
						<xsl:choose>
							<xsl:when test="not($serviceTitle='')">
								<xsl:value-of select="$serviceTitle" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$serviceAbstract" />
							</xsl:otherwise>
						</xsl:choose>
-->
						<xsl:choose>
							<xsl:when test="not($serviceAbstract='')">
								<xsl:value-of select="$serviceAbstract" />
							</xsl:when>
							<xsl:when test="not($serviceTitle='')">
								<xsl:value-of select="$serviceTitle" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$linkage" />
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</description>
			</CI_OnlineResource>    
		</onLine>
    </xsl:template>
	<!-- ============================================================================= -->

</xsl:stylesheet>
