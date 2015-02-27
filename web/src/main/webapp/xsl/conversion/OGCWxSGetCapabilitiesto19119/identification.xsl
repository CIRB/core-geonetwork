<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns    ="http://www.isotc211.org/2005/gmd"
										xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:gts="http://www.isotc211.org/2005/gts"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
										xmlns:srv="http://www.isotc211.org/2005/srv"
										xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
										xmlns:xlink="http://www.w3.org/1999/xlink"
										xmlns:wfs="http://www.opengis.net/wfs"
										xmlns:ows="http://www.opengis.net/ows"
										xmlns:owsg="http://www.opengeospatial.net/ows"
										xmlns:ows11="http://www.opengis.net/ows/1.1"
										xmlns:wcs="http://www.opengis.net/wcs"
										xmlns:wms="http://www.opengis.net/wms"
                                        xmlns:wps="http://www.opengeospatial.net/wps"
                                        xmlns:wps1="http://www.opengis.net/wps/1.0.0"
                                        xmlns:gml="http://www.opengis.net/gml"
										xmlns:math="http://exslt.org/math"
										xmlns:exslt="http://exslt.org/common"
										extension-element-prefixes="math exslt wcs ows wps wps1 ows11 wfs gml"
										exclude-result-prefixes="#all">

	<!-- ============================================================================= -->

	<xsl:template match="*" mode="SrvDataIdentification">
		<xsl:param name="topic"/>
		<xsl:param name="ogctype"/>
		<xsl:param name="ows"/>
		<xsl:param name="wfs"/>
		<xsl:param name="lang"/>
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
		<xsl:variable name="s" select="Service|wfs:Service|wms:Service|ows:ServiceIdentification|ows11:ServiceIdentification|wcs:Service"/>
		
		<citation>
			<CI_Citation>
				<title xsi:type="gmd:PT_FreeText_PropertyType">
					<xsl:variable name="title">
						<xsl:call-template name="get-title">
							<xsl:with-param name="ows">
								<xsl:value-of select="$ows" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<gco:CharacterString><xsl:value-of select="normalize-space($title)"/></gco:CharacterString>
					<PT_FreeText>
						<xsl:if test="$lang!='dut'">
							<textGroup>
								<LocalisedCharacterString locale="#DUT"><xsl:if test="normalize-space($titleDUT)!=''"><xsl:value-of select="$titleDUT"/></xsl:if><xsl:if test="normalize-space($titleDUT)=''"><xsl:value-of select="normalize-space($title)"/></xsl:if></LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='eng'">
							<textGroup>
								<LocalisedCharacterString locale="#ENG"><xsl:if test="normalize-space($titleENG)!=''"><xsl:value-of select="$titleENG"/></xsl:if><xsl:if test="normalize-space($titleENG)=''"><xsl:value-of select="normalize-space($title)"/></xsl:if></LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='fre'">
							<textGroup>
								<LocalisedCharacterString locale="#FRE"><xsl:if test="normalize-space($titleFRE)!=''"><xsl:value-of select="$titleFRE"/></xsl:if><xsl:if test="normalize-space($titleFRE)=''"><xsl:value-of select="normalize-space($title)"/></xsl:if></LocalisedCharacterString>
							</textGroup>
						</xsl:if>
					</PT_FreeText>
				</title>
				<date>
					<CI_Date>
<!-- 						<xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>-->
						<xsl:variable name="df">[Y0001]-[M01]-[D01]</xsl:variable>
						<date>
<!--							<gco:DateTime><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:DateTime>-->
							<gco:Date><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:Date>
						</date>
						<dateType>
							<CI_DateTypeCode codeList="./resources/codeList.xml#CI_DateTypeCode" codeListValue="revision"/>
						</dateType>
					</CI_Date>
				</date>
			</CI_Citation>
		</citation>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<abstract xsi:type="gmd:PT_FreeText_PropertyType">
			<xsl:variable name="abstract">
				<xsl:call-template name="get-abstract">
					<xsl:with-param name="ows">
						<xsl:value-of select="$ows" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<gco:CharacterString><xsl:value-of select="normalize-space($abstract)"/></gco:CharacterString>
			<PT_FreeText>
				<xsl:if test="$lang!='dut'">
					<textGroup>
						<LocalisedCharacterString locale="#DUT"><xsl:if test="normalize-space($abstractDUT)!=''"><xsl:value-of select="$abstractDUT"/></xsl:if><xsl:if test="normalize-space($abstractDUT)=''"><xsl:value-of select="normalize-space($abstract)"/></xsl:if></LocalisedCharacterString>
					</textGroup>
				</xsl:if>
				<xsl:if test="$lang!='eng'">
					<textGroup>
						<LocalisedCharacterString locale="#ENG"><xsl:if test="normalize-space($abstractENG)!=''"><xsl:value-of select="$abstractENG"/></xsl:if><xsl:if test="normalize-space($abstractENG)=''"><xsl:value-of select="normalize-space($abstract)"/></xsl:if></LocalisedCharacterString>
					</textGroup>
				</xsl:if>
				<xsl:if test="$lang!='fre'">
					<textGroup>
						<LocalisedCharacterString locale="#FRE"><xsl:if test="normalize-space($abstractFRE)!=''"><xsl:value-of select="$abstractFRE"/></xsl:if><xsl:if test="normalize-space($abstractFRE)=''"><xsl:value-of select="normalize-space($abstract)"/></xsl:if></LocalisedCharacterString>
					</textGroup>
				</xsl:if>
			</PT_FreeText>
		</abstract>

		<!--idPurp-->
<!--
		<status>
			<MD_ProgressCode codeList="./resources/codeList.xml#MD_ProgressCode" codeListValue="completed" />
		</status>
-->
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:choose>
			<xsl:when test="$s/wms:ContactInformation|
				$s/wfs:ContactInformation|
				$s/wms:ContactInformation|
                   ows:ServiceProvider|
				owsg:ServiceProvider|
				ows11:ServiceProvider|
				Service/ContactInformation">
				<xsl:for-each select="$s/wms:ContactInformation|
					$s/wfs:ContactInformation|
					$s/wms:ContactInformation|
                       ows:ServiceProvider|
					owsg:ServiceProvider|
					ows11:ServiceProvider|
					Service/ContactInformation">
					<pointOfContact>
						<CI_ResponsibleParty>
							<xsl:apply-templates select="." mode="RespParty"/>
						</CI_ResponsibleParty>
					</pointOfContact>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<contact gco:nilReason="missing"/>
			</xsl:otherwise>
		</xsl:choose>
<!--
		<xsl:for-each select="Service/ContactInformation|Service/wcs:responsibleParty|Service/wms:responsibleParty">
			<pointOfContact>
				<CI_ResponsibleParty>
					<xsl:apply-templates select="." mode="RespParty"/>
				</CI_ResponsibleParty>
			</pointOfContact>
		</xsl:for-each>
		<xsl:for-each select="Service/ows:ServiceProvider|Service/ows11:ServiceProvider">
			<pointOfContact>
				<CI_ResponsibleParty>
					<xsl:apply-templates select="." mode="RespParty"/>
				</CI_ResponsibleParty>
			</pointOfContact>
		</xsl:for-each>
-->
		<descriptiveKeywords>
			<MD_Keywords>
				<keyword xsi:type="gmd:PT_FreeText_PropertyType">
					<xsl:variable name="keyword">
						<xsl:choose>
							<xsl:when test="$wfs=true()">infoFeatureAccessService</xsl:when>
							<xsl:otherwise>infoMapAccessService</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<gco:CharacterString><xsl:value-of select="$keyword"/></gco:CharacterString>
					<PT_FreeText>
						<textGroup>
							<LocalisedCharacterString locale="#DUT"><xsl:value-of select="$keyword"/></LocalisedCharacterString>
						</textGroup>
						<textGroup>
							<LocalisedCharacterString locale="#FRE"><xsl:value-of select="$keyword"/></LocalisedCharacterString>
						</textGroup>
						<textGroup>
							<LocalisedCharacterString locale="#ENG"><xsl:value-of select="$keyword"/></LocalisedCharacterString>
						</textGroup>
					</PT_FreeText>
				</keyword>
				<type>
					<MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
				</type>
				<thesaurusName>
					<CI_Citation>
						<title>
							<gco:CharacterString>INSPIRE Service taxonomy</gco:CharacterString>
						</title>
						<date gco:nilReason="missing"/>
						<edition>
							<gco:CharacterString>http://geonetwork-opensource.org/inspire-theme</gco:CharacterString>
						</edition>
						<editionDate>
							<gco:Date>2010-04-22</gco:Date>
						</editionDate>
						<identifier>
							<MD_Identifier>
								<code>
									<gco:CharacterString>geonetwork.thesaurus.external.theme.inspire-service-taxonomy</gco:CharacterString>
								</code>
							</MD_Identifier>
						</identifier>
					</CI_Citation>
				</thesaurusName>
			</MD_Keywords>
		</descriptiveKeywords>

		<descriptiveKeywords>
			<MD_Keywords>
				<keyword xsi:type="gmd:PT_FreeText_PropertyType">
					<gco:CharacterString>Reporting Inspire</gco:CharacterString>
					<PT_FreeText>
						<textGroup>
							<LocalisedCharacterString locale="#ENG">Reporting Inspire</LocalisedCharacterString>
						</textGroup>
						<textGroup>
							<LocalisedCharacterString locale="#FRE">Reporting Inspire</LocalisedCharacterString>
						</textGroup>
						<textGroup>
							<LocalisedCharacterString locale="#DUT">Reporting Inspire</LocalisedCharacterString>
						</textGroup>
					</PT_FreeText>
				</keyword>
				<type>
					<MD_KeywordTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
				</type>
				<thesaurusName>
					<CI_Citation>
						<title>
							<gco:CharacterString>GeoBru brussels keywords</gco:CharacterString>
						</title>
						<date gco:nilReason="missing"/>
						<edition>
							<gco:CharacterString>http://geobru.irisnet.be/brusselskeywords</gco:CharacterString>
						</edition>
						<editionDate>
							<gco:Date>2013-06-12</gco:Date>
						</editionDate>
						<identifier>
							<MD_Identifier>
								<code>
									<gco:CharacterString>geonetwork.thesaurus.external.theme.geobru-keywords</gco:CharacterString>
								</code>
							</MD_Identifier>
						</identifier>
					</CI_Citation>
				</thesaurusName>
			</MD_Keywords>
		</descriptiveKeywords>

		<!-- resMaint -->
		<!-- graphOver -->
		<!-- dsFormat-->
		<xsl:for-each select="$s/KeywordList|$s/wms:KeywordList|$s/wfs:keywords|$s/wcs:keywords|$s/ows:Keywords|$s/ows11:Keywords">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		
		<resourceConstraints>
			<MD_Constraints>
				<useLimitation xsi:type="gmd:PT_FreeText_PropertyType">
					<xsl:variable name="accessConstraintFRE" select="normalize-space($accessConstraintFRE1)" />
					<xsl:variable name="accessConstraintDUT"><xsl:if test="$accessConstraintFRE!=''"><xsl:value-of select="normalize-space($accessConstraintDUT1)" /></xsl:if></xsl:variable>
					<xsl:variable name="accessConstraintENG"><xsl:if test="$accessConstraintFRE!=''"><xsl:value-of select="normalize-space($accessConstraintENG1)" /></xsl:if></xsl:variable>
					<gco:CharacterString>
						<xsl:call-template name="get-accessConstraint-translation">
							<xsl:with-param name="type" select="1"/>
							<xsl:with-param name="accessConstraintLang" select="$lang"/>
							<xsl:with-param name="accessConstraint" select="$accessConstraintFRE"/>
						</xsl:call-template>
					</gco:CharacterString>
					<PT_FreeText>
						<xsl:if test="$lang!='dut'">
							<textGroup>
								<LocalisedCharacterString locale="#DUT">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="1"/>
										<xsl:with-param name="accessConstraintLang" select="'dut'"/>
										<xsl:with-param name="accessConstraint"><xsl:if test="$accessConstraintDUT!=''"><xsl:value-of select="$accessConstraintDUT"/></xsl:if><xsl:if test="$accessConstraintDUT=''"><xsl:value-of select="$accessConstraintFRE"/></xsl:if></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='eng'">
							<textGroup>
								<LocalisedCharacterString locale="#ENG">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="1"/>
										<xsl:with-param name="accessConstraintLang" select="'eng'"/>
										<xsl:with-param name="accessConstraint"><xsl:if test="$accessConstraintENG!=''"><xsl:value-of select="$accessConstraintENG"/></xsl:if><xsl:if test="$accessConstraintENG=''"><xsl:value-of select="$accessConstraintFRE"/></xsl:if></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='fre'">
							<textGroup>
								<LocalisedCharacterString locale="#FRE">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="1"/>
										<xsl:with-param name="accessConstraintLang" select="'fre'"/>
										<xsl:with-param name="accessConstraint"><xsl:value-of select="$accessConstraintFRE"/></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
					</PT_FreeText>
				</useLimitation>
			</MD_Constraints>
		</resourceConstraints>
		<resourceConstraints>
			<MD_LegalConstraints>
				<accessConstraints>
					<MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions">otherRestrictions</MD_RestrictionCode>
				</accessConstraints>
				<otherConstraints xsi:type="gmd:PT_FreeText_PropertyType">
					<xsl:variable name="accessConstraintFRE" select="normalize-space($accessConstraintFRE2)" />
					<xsl:variable name="accessConstraintDUT"><xsl:if test="$accessConstraintFRE!=''"><xsl:value-of select="normalize-space($accessConstraintDUT2)" /></xsl:if></xsl:variable>
					<xsl:variable name="accessConstraintENG"><xsl:if test="$accessConstraintFRE!=''"><xsl:value-of select="normalize-space($accessConstraintENG2)" /></xsl:if></xsl:variable>
					<gco:CharacterString>
						<xsl:call-template name="get-accessConstraint-translation">
							<xsl:with-param name="type" select="2"/>
							<xsl:with-param name="accessConstraintLang" select="$lang"/>
							<xsl:with-param name="accessConstraint" select="$accessConstraintFRE"/>
						</xsl:call-template>
					</gco:CharacterString>
					<PT_FreeText>
						<xsl:if test="$lang!='dut'">
							<textGroup>
								<LocalisedCharacterString locale="#DUT">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="2"/>
										<xsl:with-param name="accessConstraintLang" select="'dut'"/>
										<xsl:with-param name="accessConstraint"><xsl:if test="$accessConstraintDUT!=''"><xsl:value-of select="$accessConstraintDUT"/></xsl:if><xsl:if test="$accessConstraintDUT=''"><xsl:value-of select="$accessConstraintFRE"/></xsl:if></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='eng'">
							<textGroup>
								<LocalisedCharacterString locale="#ENG">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="2"/>
										<xsl:with-param name="accessConstraintLang" select="'eng'"/>
										<xsl:with-param name="accessConstraint"><xsl:if test="$accessConstraintENG!=''"><xsl:value-of select="$accessConstraintENG"/></xsl:if><xsl:if test="$accessConstraintENG=''"><xsl:value-of select="$accessConstraintFRE"/></xsl:if></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
						<xsl:if test="$lang!='fre'">
							<textGroup>
								<LocalisedCharacterString locale="#FRE">
									<xsl:call-template name="get-accessConstraint-translation">
										<xsl:with-param name="type" select="2"/>
										<xsl:with-param name="accessConstraintLang" select="'fre'"/>
										<xsl:with-param name="accessConstraint"><xsl:value-of select="$accessConstraintFRE"/></xsl:with-param>
									</xsl:call-template>
								</LocalisedCharacterString>
							</textGroup>
						</xsl:if>
					</PT_FreeText>
				</otherConstraints>
			</MD_LegalConstraints>
		</resourceConstraints>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
		
		<srv:serviceType>
			<xsl:variable name="serviceType">
				<xsl:choose>
					<xsl:when test="$wfs=true()">download</xsl:when>
					<xsl:otherwise>view</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<gco:LocalName><xsl:value-of select='$serviceType'/></gco:LocalName>
		</srv:serviceType>
		<srv:serviceTypeVersion>
			<gco:CharacterString><xsl:value-of select='@version'/></gco:CharacterString>
		</srv:serviceTypeVersion>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<srv:accessProperties>
			<MD_StandardOrderProcess>
				<fees xsi:type="gmd:PT_FreeText_PropertyType">
					<xsl:variable name="fees"><xsl:value-of select="normalize-space($s/Fees|$s/wms:Fees|$s/wfs:Fees|$s/ows:Fees|$s/ows11:Fees|$s/wcs:fees)"/></xsl:variable>
					<xsl:variable name="feesExists" select="not($fees='' or upper-case($fees)='NONE')"/>
					<xsl:if test="$feesExists">
						<gco:CharacterString><xsl:value-of select="$fees"/></gco:CharacterString>
					</xsl:if>
					<xsl:if test="not($feesExists)">
						<gco:CharacterString><xsl:call-template name="get-fees-translation"><xsl:with-param name="feesLang" select="$lang"/></xsl:call-template></gco:CharacterString>
					</xsl:if>
					<xsl:if test="not($feesExists)">
						<PT_FreeText>
							<xsl:if test="$lang!='dut'">
								<textGroup>
									<LocalisedCharacterString locale="#DUT"><xsl:call-template name="get-fees-translation"><xsl:with-param name="feesLang" select="'dut'"/></xsl:call-template></LocalisedCharacterString>
								</textGroup>
							</xsl:if>
							<xsl:if test="$lang!='eng'">
								<textGroup>
									<LocalisedCharacterString locale="#ENG"><xsl:call-template name="get-fees-translation"><xsl:with-param name="feesLang" select="'eng'"/></xsl:call-template></LocalisedCharacterString>
								</textGroup>
							</xsl:if>
							<xsl:if test="$lang!='fre'">
								<textGroup>
									<LocalisedCharacterString locale="#FRE"><xsl:call-template name="get-fees-translation"><xsl:with-param name="feesLang" select="'fre'"/></xsl:call-template></LocalisedCharacterString>
								</textGroup>
							</xsl:if>
						</PT_FreeText>
					</xsl:if>
				</fees>
			</MD_StandardOrderProcess>
		</srv:accessProperties>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Extent in OGC spec are somehow differents !
		
		WCS 1.0.0
		<lonLatEnvelope srsName="WGS84(DD)">
				<gml:pos>-130.85168 20.7052</gml:pos>
				<gml:pos>-62.0054 54.1141</gml:pos>
		</lonLatEnvelope>
		
		WFS 1.1.0
		<ows:WGS84BoundingBox>
				<ows:LowerCorner>-124.731422 24.955967</ows:LowerCorner>
				<ows:UpperCorner>-66.969849 49.371735</ows:UpperCorner>
		</ows:WGS84BoundingBox>
		
		WMS 1.1.1
		<LatLonBoundingBox minx="-74.047185" miny="40.679648" maxx="-73.907005" maxy="40.882078"/>
        
        WMS 1.3.0
        <EX_GeographicBoundingBox>
	        <westBoundLongitude>-178.9988054730254</westBoundLongitude>
	        <eastBoundLongitude>179.0724773329789</eastBoundLongitude>
	        <southBoundLatitude>-0.5014529001680404</southBoundLatitude>
	        <northBoundLatitude>88.9987992292308</northBoundLatitude>
        </EX_GeographicBoundingBox>
        <BoundingBox CRS="EPSG:4326" minx="27.116136375774644" miny="-17.934116876940887" maxx="44.39484823803499" maxy="6.052081516030762"/>
        
        WPS 0.4.0 : none
        
        WPS 1.0.0 : none
		 -->
        <xsl:if test="name(.)!='wps:Capabilities'">
		    <srv:extent>
				<EX_Extent>
					<geographicElement>
						<EX_GeographicBoundingBox>
							<xsl:choose>
								<xsl:when test="$ows='true' or name(.)='WCS_Capabilities'">
					
									<xsl:variable name="boxes">
										<xsl:choose>
											<xsl:when test="$ows='true'">
												<xsl:for-each select="//ows:WGS84BoundingBox/ows:LowerCorner">
													<xmin><xsl:value-of	select="substring-before(., ' ')"/></xmin>
													<ymin><xsl:value-of	select="substring-after(., ' ')"/></ymin>
												</xsl:for-each>
												<xsl:for-each select="//ows:WGS84BoundingBox/ows:UpperCorner">
													<xmax><xsl:value-of	select="substring-before(., ' ')"/></xmax>
													<ymax><xsl:value-of	select="substring-after(., ' ')"/></ymax>
												</xsl:for-each>
											</xsl:when>
											<xsl:when test="name(.)='WCS_Capabilities'">
												<xsl:for-each select="//wcs:lonLatEnvelope/gml:pos[1]">
													<xmin><xsl:value-of	select="substring-before(., ' ')"/></xmin>
													<ymin><xsl:value-of	select="substring-after(., ' ')"/></ymin>
												</xsl:for-each>
												<xsl:for-each select="//wcs:lonLatEnvelope/gml:pos[2]">
													<xmax><xsl:value-of	select="substring-before(., ' ')"/></xmax>
													<ymax><xsl:value-of	select="substring-after(., ' ')"/></ymax>
												</xsl:for-each>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>
											
									<westBoundLongitude>
										<gco:Decimal><xsl:copy-of select="math:min(exslt:node-set($boxes)/*[name(.)='xmin'])"/></gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="math:max(exslt:node-set($boxes)/*[name(.)='xmax'])"/></gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal><xsl:value-of select="math:min(exslt:node-set($boxes)/*[name(.)='ymin'])"/></gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal><xsl:value-of select="math:max(exslt:node-set($boxes)/*[name(.)='ymax'])"/></gco:Decimal>
									</northBoundLatitude> 
								</xsl:when>
								<xsl:otherwise>
									<westBoundLongitude>
										<gco:Decimal><xsl:value-of select="math:min(//wms:EX_GeographicBoundingBox/wms:westBoundLongitude|//LatLonBoundingBox/@minx|//wfs:LatLongBoundingBox/@minx)"/></gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="math:max(//wms:EX_GeographicBoundingBox/wms:eastBoundLongitude|//LatLonBoundingBox/@maxx|//wfs:LatLongBoundingBox/@maxx)"/></gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal><xsl:value-of select="math:min(//wms:EX_GeographicBoundingBox/wms:southBoundLatitude|//LatLonBoundingBox/@miny|//wfs:LatLongBoundingBox/@miny)"/></gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal><xsl:value-of select="math:max(//wms:EX_GeographicBoundingBox/wms:northBoundLatitude|//LatLonBoundingBox/@maxy|//wfs:LatLongBoundingBox/@maxy)"/></gco:Decimal>
									</northBoundLatitude>
								</xsl:otherwise>
							</xsl:choose>
						</EX_GeographicBoundingBox>
					</geographicElement>
				</EX_Extent>
		    </srv:extent>
        </xsl:if>
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			
		<srv:couplingType>
			<srv:SV_CouplingType codeList="./resources/codeList.xml#SV_CouplingType" codeListValue="tight">
				<xsl:choose>
					<xsl:when test="name(.)='wps:Capabilities' or name(.)='wps1:Capabilities'">loosely</xsl:when>
					<xsl:otherwise>tight</xsl:otherwise>
				</xsl:choose>
			</srv:SV_CouplingType>
		</srv:couplingType>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            Operation could be OGC standard operation described in specification
            OR a specific process in a WPS. In that case, each process are described
            as one operation.
        -->
		
		<xsl:for-each select="Capability/Request/*|
								wfs:Capability/wfs:Request/*|
								wms:Capability/wms:Request/*|
                                wcs:Capability/wcs:Request/*|
                                ows:OperationsMetadata/ows:Operation|
                                ows11:OperationsMetadata/ows:Operation|
                                wps:ProcessOfferings/*|
                                wps1:ProcessOfferings/*">
			<!-- Some services provide information about ows:ExtendedCapabilities TODO ? -->
			<xsl:variable name="operationName">
					<xsl:choose>
						<xsl:when test="name(.)='wps:Process'">WPS Process: <xsl:value-of select="ows:Title|ows11:Title"/></xsl:when>
                              <xsl:when test="$ows='true'"><xsl:value-of select="@name"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="name(.)"/></xsl:otherwise>
					</xsl:choose>
			</xsl:variable>
			<xsl:variable name="isSupportedOperation"><xsl:call-template name="is-supported-operation"><xsl:with-param name="ows" select="$ows"/><xsl:with-param name="operationName" select="$operationName"/></xsl:call-template></xsl:variable>
			<xsl:if test="$isSupportedOperation='true'">
				<xsl:message select="concat('Operation ', $operationName, ' is supported.')"/>
				<srv:containsOperations>
					<srv:SV_OperationMetadata>
						<srv:operationName>
							<gco:CharacterString><xsl:value-of select="$operationName"/></gco:CharacterString>
						</srv:operationName>
						<!--  CHECKME : DCPType/SOAP ? -->
<!--
						<xsl:for-each select="DCPType/HTTP/*|wfs:DCPType/wfs:HTTP/*|wms:DCPType/wms:HTTP/*|
								wcs:DCPType/wcs:HTTP/*|ows:DCP/ows:HTTP/*|ows11:DCP/ows11:HTTP/*">
							<srv:DCP>
								<srv:DCPList codeList="./resources/codeList.xml#DCPList">
									<xsl:variable name="dcp">
										<xsl:choose>
											<xsl:when test="name(.)='Get' or name(.)='wfs:Get' or name(.)='wms:Get' or name(.)='wcs:Get' or name(.)='ows:Get' or name(.)='ows11:Get'">HTTP-GET</xsl:when>
											<xsl:when test="name(.)='Post' or name(.)='wfs:Post' or name(.)='wms:Post' or name(.)='wcs:Post' or name(.)='ows:Post' or name(.)='ows11:Post'">HTTP-POST</xsl:when>
											<xsl:otherwise>WebServices</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:attribute name="codeListValue">
										<xsl:value-of select="$dcp"/>
									</xsl:attribute>
								</srv:DCPList>
							</srv:DCP>
						</xsl:for-each>
-->          
						<srv:DCP gco:nilReason="missing">
							<srv:DCPList codeList="http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#DCPList" codeListValue=""/>
						</srv:DCP>
	                    <xsl:if test="name(.)='wps:Process' or name(.)='wps11:ProcessOfferings'">
	                      <srv:operationDescription>
	                          <gco:CharacterString><xsl:value-of select="ows:Abstract|ows11:Title"/></gco:CharacterString> 
	                      </srv:operationDescription> 
	                      <srv:invocationName>
	                          <gco:CharacterString><xsl:value-of select="ows:Identifier|ows11:Identifier"/></gco:CharacterString> 
	                      </srv:invocationName> 
	                    </xsl:if>
	                    <xsl:variable name="formats">
	                    	<xsl:choose>
	                    		<xsl:when test="$operationName='GetGmlObject'"><xsl:value-of select="../ows:Operation[@name='GetFeature']/ows:Parameter[@name='AcceptFormats' or @name='outputFormat']/ows:Value[contains(upper-case(.),'GML')]"/></xsl:when>
	                    		<xsl:otherwise><xsl:value-of select="Format|wms:Format|ows:Parameter[@name='AcceptFormats' or @name='outputFormat']/ows:Value"/></xsl:otherwise>
	                   		</xsl:choose> 
	                    </xsl:variable>
	                    <xsl:if test="count($formats)>0">
							<srv:connectPoint>
								<CI_OnlineResource>
									<linkage>
											<xsl:variable name="urls">
												<xsl:choose>
													<xsl:when test="$ows='true'"><xsl:value-of select=".//ows:Get[1]/@xlink:href"/></xsl:when>
													<xsl:otherwise><xsl:value-of select=".//Get/OnlineResource[1]/@xlink:href|.//wms:Get/wms:OnlineResource[1]/@xlink:href"/></xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											<xsl:if test="normalize-space($urls[1])=''">
												<xsl:attribute name="gco:nilReason" select="'missing'"/>
											</xsl:if>
											<URL>
												<xsl:value-of select="$urls[1]"/><xsl:if test="not(contains($urls[1],'?'))">?</xsl:if>
											</URL>
									</linkage>
									<protocol>
										<gco:CharacterString>
											<xsl:choose>
												<xsl:when test="$operationName='GetCapabilities' or $operationName='GetMap' or $operationName='GetFeatureInfo'">
													<xsl:call-template name="get-protocol-by-operation">
														<xsl:with-param name="operationName" select="$operationName"/>
														<xsl:with-param name="ogctype" select="$ogctype"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:when test="$ows='true'">
													<xsl:choose>
														<xsl:when test="$operationName='GetCapabilities' or $operationName='DescribeFeatureType' or $operationName='GetFeature' or $operationName='GetGmlObject'">
															<xsl:call-template name="get-protocol-by-operation">
																<xsl:with-param name="operationName" select="$operationName"/>
																<xsl:with-param name="ogctype" select="$ogctype"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise><xsl:value-of select="$formats[1]"/></xsl:otherwise>
													</xsl:choose>												
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$formats[1]"/>
												</xsl:otherwise>
											</xsl:choose>
										</gco:CharacterString>
									</protocol>
									<name>
	                                    <gco:CharacterString/>
	                                </name>
									<description>
	                                    <gco:CharacterString>Formats : <xsl:value-of select="string-join($formats,', ')"/>
	                                    </gco:CharacterString>
	                                </description>
<!-- 
									<function>
										<CI_OnLineFunctionCode codeList="./resources/codeList.xml#CI_OnLineFunctionCode" codeListValue="information"/>
									</function>
-->
								</CI_OnlineResource>
							</srv:connectPoint>
						</xsl:if>
								
						<!-- Some Operations in WFS 1.0.0 have no ResultFormat no CI_OnlineResource created 
								WCS has no output format
						-->
	                    <xsl:variable name="wfsformats" select="wfs:ResultFormat/*"/>
	                    <xsl:if test="count($wfsformats)>0">
							<srv:connectPoint>
								<CI_OnlineResource>
									<linkage>
										<xsl:variable name="urls" select="..//wfs:Get[1]/@onlineResource"/>
										<xsl:if test="normalize-space($urls[1])=''">
											<xsl:attribute name="gco:nilReason" select="'missing'"/>
										</xsl:if>
										<URL>
											<xsl:value-of select="$urls[1]"/><xsl:if test="not(contains($urls[1],'?'))">?</xsl:if>
										</URL>
									</linkage>
									<protocol>
										<gco:CharacterString><xsl:value-of select="name($wfsformats[1])"/></gco:CharacterString>
									</protocol>
									<name>
	                                    <gco:CharacterString/>
	                                </name>
									<description>
	                                    <gco:CharacterString>Format(s) : <xsl:value-of select="string-join($wfsformats,', ')"/>
	                                    </gco:CharacterString>
	                                </description>
<!--
									<function>
										<CI_OnLineFunctionCode codeList="./resources/codeList.xml#CI_OnLineFunctionCode" codeListValue="information"/>
									</function>
-->								
								</CI_OnlineResource>
							</srv:connectPoint>
						</xsl:if>
					</srv:SV_OperationMetadata>
				</srv:containsOperations>
			</xsl:if>
			<xsl:if test="$isSupportedOperation!='true'">
				<xsl:message select="concat('Operation ', $operationName, ' is not taken into account for the service metadata.')"/>
			</xsl:if>
		</xsl:for-each>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
		Done by harvester after data metadata creation
		<xsl:for-each select="//Layer[count(./*[name(.)='Layer'])=0] | FeatureType[count(./*[name(.)='FeatureType'])=0] | CoverageOfferingBrief[count(./*[name(.)='CoverageOfferingBrief'])=0]">
				<srv:operatesOn>
						<MD_DataIdentification uuidref="">
						<xsl:value-of select="Name"/>
						</MD_DataIdentification>
				</srv:operatesOn>
		</xsl:for-each>
		-->
		
	</xsl:template>


	<!-- ============================================================================= -->
	<!-- === LayerDataIdentification === -->
	<!-- ============================================================================= -->

	<xsl:template match="*" mode="LayerDataIdentification">
		<xsl:param name="Name"/>
		<xsl:param name="topic"/>		
		<xsl:param name="ows"/>
		<citation>
			<CI_Citation>
				<title>
					<gco:CharacterString>
						<xsl:choose>
							<xsl:when test="name(.)='WFS_Capabilities' or name(.)='wfs:WFS_Capabilities' or $ows='true'">
								<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Title"/>
							</xsl:when>
							<xsl:when test="name(.)='WMS_Capabilities'">
								<xsl:value-of select="//wms:Layer[wms:Name=$Name]/wms:Title"/>
							</xsl:when>
							<xsl:when test="name(.)='WMT_MS_Capabilities'">
								<xsl:value-of select="//Layer[Name=$Name]/Title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:label"/>
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</title>
				<date>
					<CI_Date>
						<xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>
						<date>
							<gco:DateTime><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:DateTime>
						</date>
						<dateType>
							<CI_DateTypeCode codeList="./resources/codeList.xml#CI_DateTypeCode" codeListValue="revision"/>
						</dateType>
					</CI_Date>
				</date>
			</CI_Citation>
		</citation>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<abstract>
			<gco:CharacterString>
				<xsl:choose>
					<xsl:when test="name(.)='WFS_Capabilities' or $ows='true'">
						<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Abstract"/>
					</xsl:when>
					<xsl:when test="name(.)='WMS_Capabilities'">
						<xsl:value-of select="//wms:Layer[wms:Name=$Name]/wms:Abstract"/>
					</xsl:when>
					<xsl:when test="name(.)='WMT_MS_Capabilities'">
						<xsl:value-of select="//Layer[Name=$Name]/Abstract"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:description"/>
					</xsl:otherwise>
				</xsl:choose>
			</gco:CharacterString>
		</abstract>

		<!--idPurp-->

		<status>
			<MD_ProgressCode codeList="./resources/codeList.xml#MD_ProgressCode" codeListValue="completed" />
		</status>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="Service/ContactInformation|wms:Service/wms:ContactInformation">
			<pointOfContact>
				<CI_ResponsibleParty>
					<xsl:apply-templates select="." mode="RespParty"/>
				</CI_ResponsibleParty>
			</pointOfContact>
		</xsl:for-each>

		<!-- resMaint -->
		<!-- graphOver -->
		<!-- dsFormat-->
		<xsl:for-each select="//Layer[Name=$Name]/KeywordList|keywords">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		<xsl:for-each select="//wms:Layer[wms:Name=$Name]/wms:KeywordList|wms:KeywordList">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		<xsl:for-each select="//wfs:FeatureType[wfs:Name=$Name]">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		<xsl:for-each select="//wfs:FeatureType[wfs:Name=$Name]/ows:Keywords">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		<xsl:for-each select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:keywords">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:apply-templates select="." mode="Keywords"/>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:for-each>
		
		
		<xsl:choose>
		 	<xsl:when test="//wfs:FeatureType|FeatureType">
				<spatialRepresentationType>
					<MD_SpatialRepresentationTypeCode codeList="./resources/codeList.xml#MD_SpatialRepresentationTypeCode" codeListValue="vector" />
				</spatialRepresentationType>
			</xsl:when>
			<xsl:when test="//wcs:CoverageOfferingBrief">
				<spatialRepresentationType>
					<MD_SpatialRepresentationTypeCode codeList="./resources/codeList.xml#MD_SpatialRepresentationTypeCode" codeListValue="grid" />
				</spatialRepresentationType>
			</xsl:when>
		</xsl:choose>
		
		<!-- TODO WCS -->
		<xsl:variable name="minScale" select="//Layer[Name=$Name]/MinScaleDenominator
		  |//wms:Layer[wms:Name=$Name]/wms:MinScaleDenominator"/>
	  <xsl:variable name="minScaleHint" select="//Layer[Name=$Name]/ScaleHint/@min"/>
		<xsl:if test="$minScale or $minScaleHint">
			<spatialResolution>
				<MD_Resolution>
					<equivalentScale>
						<MD_RepresentativeFraction>
							<denominator>
							  <gco:Integer><xsl:value-of select="if ($minScale) then $minScale else format-number(round($minScaleHint div math:sqrt(2) * 72 div 2.54 * 100), '0')"/></gco:Integer>
							</denominator>
						</MD_RepresentativeFraction>
					</equivalentScale>
				</MD_Resolution>
			</spatialResolution>
		</xsl:if>
		<xsl:variable name="maxScale" select="//Layer[Name=$Name]/MaxScaleDenominator
		  |//wms:Layer[wms:Name=$Name]/wms:MaxScaleDenominator"/>
	  <xsl:variable name="maxScaleHint" select="//Layer[Name=$Name]/ScaleHint/@max"/>
		<xsl:if test="$maxScale or $maxScaleHint">
			<spatialResolution>
				<MD_Resolution>
					<equivalentScale>
						<MD_RepresentativeFraction>
							<denominator>
							  <gco:Integer><xsl:value-of select="if ($maxScale) then $maxScale else format-number(round($maxScaleHint div math:sqrt(2) * 72 div 2.54 * 100), '0')"/></gco:Integer>
							</denominator>
						</MD_RepresentativeFraction>
					</equivalentScale>
				</MD_Resolution>
			</spatialResolution>
		</xsl:if>
		
		<language gco:nilReason="missing">
			<gco:CharacterString/>
		</language>
		
		<characterSet>
			<MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_CharacterSetCode" codeListValue=""/>
		</characterSet>
		
		<topicCategory>
			<MD_TopicCategoryCode><xsl:value-of select="$topic"/></MD_TopicCategoryCode>
		</topicCategory>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<extent>
				<EX_Extent>
					<geographicElement>
						<EX_GeographicBoundingBox>
							<xsl:choose>
								<xsl:when test="$ows='true' or name(.)='WCS_Capabilities'">
									<xsl:variable name="boxes">
										<xsl:choose>
											<xsl:when test="$ows='true'">
												<xsl:for-each select="//wfs:FeatureType[wfs:Name=$Name]/ows:WGS84BoundingBox/ows:LowerCorner">
													<xmin><xsl:value-of	select="substring-before(., ' ')"/></xmin>
													<ymin><xsl:value-of	select="substring-after(., ' ')"/></ymin>
												</xsl:for-each>
												<xsl:for-each select="//wfs:FeatureType[wfs:Name=$Name]/ows:WGS84BoundingBox/ows:UpperCorner">
													<xmax><xsl:value-of	select="substring-before(., ' ')"/></xmax>
													<ymax><xsl:value-of	select="substring-after(., ' ')"/></ymax>
												</xsl:for-each>
											</xsl:when>
											<xsl:when test="name(.)='WCS_Capabilities'">
												<xsl:for-each select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:lonLatEnvelope/gml:pos[1]">
													<xmin><xsl:value-of	select="substring-before(., ' ')"/></xmin>
													<ymin><xsl:value-of	select="substring-after(., ' ')"/></ymin>
												</xsl:for-each>
												<xsl:for-each select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:lonLatEnvelope/gml:pos[2]">
													<xmax><xsl:value-of	select="substring-before(., ' ')"/></xmax>
													<ymax><xsl:value-of	select="substring-after(., ' ')"/></ymax>
												</xsl:for-each>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>
											
									<westBoundLongitude>
										<gco:Decimal><xsl:copy-of select="exslt:node-set($boxes)/*[name(.)='xmin']"/></gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="exslt:node-set($boxes)/*[name(.)='xmax']"/></gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal><xsl:value-of select="exslt:node-set($boxes)/*[name(.)='ymin']"/></gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal><xsl:value-of select="exslt:node-set($boxes)/*[name(.)='ymax']"/></gco:Decimal>
									</northBoundLatitude> 
								</xsl:when>
								<xsl:when test="name(.)='WFS_Capabilities'">
									<westBoundLongitude>
										<gco:Decimal><xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:LatLongBoundingBox/@minx"/></gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:LatLongBoundingBox/@maxx"/></gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal><xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:LatLongBoundingBox/@miny"/></gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal><xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:LatLongBoundingBox/@maxy"/></gco:Decimal>
									</northBoundLatitude>
								</xsl:when>
								<xsl:otherwise>
									<westBoundLongitude>
										<gco:Decimal><xsl:value-of select="//Layer[Name=$Name]/LatLonBoundingBox/@minx|
											//wms:Layer[wms:Name=$Name]/wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/></gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="//Layer[Name=$Name]/LatLonBoundingBox/@maxx|
											//wms:Layer[wms:Name=$Name]/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/></gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal><xsl:value-of select="//Layer[Name=$Name]/LatLonBoundingBox/@miny|
											//wms:Layer[wms:Name=$Name]/wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/></gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal><xsl:value-of select="//Layer[Name=$Name]/LatLonBoundingBox/@maxy|
											//wms:Layer[wms:Name=$Name]/wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/></gco:Decimal>
									</northBoundLatitude>
								</xsl:otherwise>
							</xsl:choose>
						</EX_GeographicBoundingBox>
					</geographicElement>
				</EX_Extent>
		</extent>
			
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			TODO : could be added to the GUI ?  
		<xsl:for-each select="tpCat">
			<topicCategory>
				<MD_TopicCategoryCode codeList="./resources/codeList.xml#MD_TopicCategoryCode" codeListValue="{TopicCatCd/@value}" />
			</topicCategory>
		</xsl:for-each>

		  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		  
	</xsl:template>

	<!-- ============================================================================= -->
	<!-- === Keywords === -->
	<!-- ============================================================================= -->

	<xsl:template match="*" mode="Keywords">
		<!-- TODO : tokenize WFS 100 keywords list -->
		<xsl:for-each select="Keyword|wms:Keyword|ows:Keyword|ows11:Keyword|wfs:Keywords|wcs:keyword">
			<xsl:variable name="keywordValue" select="normalize-space(.)" />
			<xsl:if test="$keywordValue!='infoMapAccessService' and $keywordValue!='infoFeatureAccessService'">
				<keyword>
					<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
				</keyword>
			</xsl:if>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- 
		<type>
			<MD_KeywordTypeCode codeList="./resources/codeList.xml#MD_KeywordTypeCode" codeListValue="theme" />
		</type>
 -->
	</xsl:template>

	<xsl:template name="get-protocol-by-operation">
		<xsl:param name="operationName"/>
		<xsl:param name="ogctype"/>
		<xsl:choose>
			<xsl:when test="$operationName='GetCapabilities'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WMTS1.0.0'">OGC:WMTS-1.0.0-http-get-capabilities</xsl:when>
               		<xsl:when test="$ogctype='WMS1.1.1'">OGC:WMS-1.1.1-http-get-capabilities</xsl:when>
               		<xsl:when test="$ogctype='WMS1.3.0'">OGC:WMS-1.3.0-http-get-capabilities</xsl:when>
               		<xsl:when test="$ogctype='WFS1.0.0'">OGC:WFS-1.1.0-http-get-capabilities</xsl:when>
               		<xsl:when test="$ogctype='WFS1.1.0'">OGC:WFS-1.1.0-http-get-capabilities</xsl:when>
               		<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
            </xsl:when>
			<xsl:when test="$operationName='GetMap'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WMS1.1.1'">OGC:WMS-1.1.1-http-get-map</xsl:when>
               		<xsl:when test="$ogctype='WMS1.3.0'">OGC:WMS-1.3.0-http-get-map</xsl:when>
					<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
			</xsl:when>
			<xsl:when test="$operationName='GetFeatureInfo'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WMS1.1.1'">OGC:WMS-1.1.1-http-get-featureinfo</xsl:when>
               		<xsl:when test="$ogctype='WMS1.3.0'">OGC:WMS-1.3.0-http-get-featureinfo</xsl:when>
					<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
			</xsl:when>
			<xsl:when test="$operationName='GetFeature'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WFS1.0.0'">OGC:WFS-1.0.0-http-get-feature</xsl:when>
               		<xsl:when test="$ogctype='WFS1.1.0'">OGC:WFS-1.1.0-http-get-feature</xsl:when>
					<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
			</xsl:when>
			<xsl:when test="$operationName='DescribeFeatureType'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WFS1.0.0'">OGC:WFS-1.0.0-http-describefeaturetype</xsl:when>
               		<xsl:when test="$ogctype='WFS1.1.0'">OGC:WFS-1.1.0-http-describefeaturetype</xsl:when>
					<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
			</xsl:when>
			<xsl:when test="$operationName='GetGmlObject'">
               	<xsl:choose>
               		<xsl:when test="$ogctype='WFS1.1.0'">OGC:WFS-1.1.0-http-getgmlobject</xsl:when>
					<xsl:otherwise>WWW:LINK-1.0-http--link</xsl:otherwise>
               	</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-fees-translation">
		<xsl:param name="feesLang"/>
		<xsl:choose>
			<xsl:when test="$feesLang='dut'">Geen kosten</xsl:when>
			<xsl:when test="$feesLang='eng'">No Fees</xsl:when>
			<xsl:otherwise>Pas de frais</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-accessConstraint-translation">
		<xsl:param name="type"/>
		<xsl:param name="accessConstraintLang"/>
		<xsl:param name="accessConstraint"/>
		<xsl:choose>
			<xsl:when test="not($accessConstraint='')"><xsl:value-of select="$accessConstraint"/></xsl:when>
			<xsl:otherwise>
				<xsl:if test="$type=1">
					<xsl:choose>
						<xsl:when test="$accessConstraintLang='dut'">Geen voorwaarde van toepassing. Vrij gebruik onder voorbehoud van vermelding van de bron en de datum van de laatste wijziging.</xsl:when>
						<xsl:when test="$accessConstraintLang='eng'">No condition applies.  Free use under the condition that the source and the latest revision date are mentioned.</xsl:when> 
						<xsl:otherwise>Aucune condition ne s’applique. Utilisation libre sous réserve de mentionner la source et la date de la dernière mise à jour.</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$type=2">
					<xsl:choose>
						<xsl:when test="$accessConstraintLang='dut'">Geen publieke toegangsrestricties volgens INSPIRE.</xsl:when>
						<xsl:when test="$accessConstraintLang='eng'">No public access constraints by INSPIRE.</xsl:when>
						<xsl:otherwise>Pas de restriction d’accès public selon INSPIRE.</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-abstract">
		<xsl:param name="ows"/>
		<xsl:choose>
			<xsl:when test="$ows='true'">
				<xsl:value-of select="ows:ServiceIdentification/ows:Abstract|
									ows11:ServiceIdentification/ows11:Abstract"/>
			</xsl:when>
			<xsl:when test="name(.)='WFS_Capabilities'">
				<xsl:value-of select="wfs:Service/wfs:Abstract|Service/Abstract"/>
			</xsl:when>
			<xsl:when test="name(.)='WMS_Capabilities' or name(.)='WMT_MS_Capabilities'">
				<xsl:value-of select="wms:Service/wms:Abstract|Service/Abstract"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="wcs:Service/wcs:description"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-title">
		<xsl:param name="ows"/>
		<xsl:choose>
			<xsl:when test="$ows='true'">
				<xsl:value-of select="ows:ServiceIdentification/ows:Title|
									ows11:ServiceIdentification/ows11:Title"/>
			</xsl:when>
			<xsl:when test="name(.)='WFS_Capabilities'">
				<xsl:value-of select="wfs:Service/wfs:Title|Service/Title"/>
			</xsl:when>
			<xsl:when test="name(.)='WMS_Capabilities' or name(.)='WMT_MS_Capabilities'">
				<xsl:value-of select="wms:Service/wms:Title|Service/Title"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="wcs:Service/wcs:label"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-name">
		<xsl:param name="ows"/>
		<xsl:choose>
			<xsl:when test="$ows='true'">
				<xsl:value-of select="ows:ServiceIdentification/ows:Name|
									ows11:ServiceIdentification/ows11:Name"/>
			</xsl:when>
			<xsl:when test="name(.)='WFS_Capabilities'">
				<xsl:value-of select="wfs:Service/wfs:Name|Service/Name"/>
			</xsl:when>
			<xsl:when test="name(.)='WMS_Capabilities' or name(.)='WMT_MS_Capabilities'">
				<xsl:value-of select="wms:Service/wms:Name|Service/Name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="wcs:Service/wcs:label"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="is-supported-operation">
		<xsl:param name="ows"/>
		<xsl:param name="operationName" />
		<xsl:choose>
			<xsl:when test="$operationName='GetCapabilities' or $operationName='GetMap' or $operationName='GetFeatureInfo' or $operationName='DescribeFeatureType' or $operationName='GetFeature' or $operationName='GetGmlObject'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
