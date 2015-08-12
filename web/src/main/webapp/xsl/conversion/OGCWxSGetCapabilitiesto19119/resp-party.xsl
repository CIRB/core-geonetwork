<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns    ="http://www.isotc211.org/2005/gmd"
										xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
										xmlns:xlink="http://www.w3.org/1999/xlink"
										xmlns:wfs="http://www.opengis.net/wfs"
										xmlns:ows="http://www.opengis.net/ows"
                                        xmlns:owsg="http://www.opengeospatial.net/ows"
                                        xmlns:ows11="http://www.opengis.net/ows/1.1"
                                        xmlns:wms="http://www.opengis.net/wms"
										xmlns:wcs="http://www.opengis.net/wcs"
										xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
										xmlns:geobru="http://geobru.irisnet.be"
										extension-element-prefixes="wcs ows wfs owsg ows11"
										exclude-result-prefixes="#all">

	<!-- ============================================================================= -->

	<xsl:param name="outputSchema"></xsl:param>
	<xsl:template match="*" mode="RespParty">
		<xsl:for-each select="ContactPersonPrimary/ContactPerson|wms:ContactPersonPrimary/wms:ContactPerson|wcs:individualName|ows:ServiceContact/ows:IndividualName|ows11:ServiceContact/ows11:IndividualName">
			<individualName>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</individualName>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="ContactPersonPrimary/ContactOrganization|wms:ContactPersonPrimary/wms:ContactOrganization|wcs:organisationName|ows:ProviderName|ows11:ProviderName">
			<organisationName>				
				<gco:CharacterString><xsl:call-template name="getOrganisationName"/></gco:CharacterString>
			</organisationName>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="ContactPosition|wms:ContactPosition|wcs:positionName|ows:ServiceContact/ows:PositionName|ows11:ServiceContact/ows11:PositionName">
			<positionName>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</positionName>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<contactInfo>
			<CI_Contact>
				<xsl:apply-templates select="." mode="Contact"/>
			</CI_Contact>
		</contactInfo>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<role>
			<CI_RoleCode codeList="./resources/codeList.xml#CI_RoleCode" codeListValue="pointOfContact" />
		</role>

	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template match="*" mode="Contact">

		<phone>
			<CI_Telephone>
				<xsl:for-each select="ContactVoiceTelephone|wms:ContactVoiceTelephone|
						ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice|
						ows11:ServiceContact/ows11:ContactInfo/ows11:Phone/ows11:Voice">
					<voice>
						<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
					</voice>
				</xsl:for-each>
	
				<xsl:for-each select="ContactFacsimileTelephone|wms:ContactFacsimileTelephone|
						ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Facsimile|
						ows11:ServiceContact/ows11:ContactInfo/ows11:Phone/ows11:Facsimile">
					<facsimile>
						<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
					</facsimile>
				</xsl:for-each>
			</CI_Telephone>
		</phone>
	
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="ContactAddress|wms:ContactAddress|
							wcs:contactInfo|
							ows:ServiceContact/ows:ContactInfo/ows:Address|
							ows11:ServiceContact/ows11:ContactInfo/ows11:Address">
			<address>
				<xsl:choose>
					<xsl:when test="$outputSchema='iso19139.geobru'">
						<geobru:BXL_Address gco:isoType="CI_Address_Type">
							<xsl:apply-templates select="." mode="Address"/>
							<xsl:for-each select="../ContactElectronicMailAddress|../wms:ContactElectronicMailAddress|../wcs:address/wcs:electronicMailAddress|ows:ElectronicMailAddress|ows11:ElectronicMailAddress">
								<electronicMailAddress>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</electronicMailAddress>
								<geobru:individualElectronicMailAddress>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</geobru:individualElectronicMailAddress>
							</xsl:for-each>
						</geobru:BXL_Address>
					</xsl:when>
					<xsl:otherwise>
						<CI_Address>
							<xsl:apply-templates select="." mode="Address"/>
							<xsl:for-each select="../ContactElectronicMailAddress|../wms:ContactElectronicMailAddress|../wcs:address/wcs:electronicMailAddress|ows:ElectronicMailAddress|ows11:ElectronicMailAddress">
								<electronicMailAddress>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</electronicMailAddress>
							</xsl:for-each>
						</CI_Address>
					</xsl:otherwise>
				</xsl:choose>
			</address>
		</xsl:for-each>

		<!--cntOnLineRes-->
		<!--cntHours -->
		<!--cntInstr -->
		<onlineResource>
			<CI_OnlineResource>
				<linkage>
					<xsl:variable name="urls" select="//Service/OnlineResource/@xlink:href|ows:ProviderSite/@xlink:href|ows11:ProviderSite/@xlink:href"/>
					<xsl:if test="normalize-space($urls[1])=''">
						<xsl:attribute name="gco:nilReason" select="'missing'"/>
					</xsl:if>
					<URL>
						<xsl:value-of select="$urls[1]"/>
					</URL>
				</linkage>
			</CI_OnlineResource>
		</onlineResource>
	</xsl:template>


	<!-- ============================================================================= -->

	<xsl:template match="*" mode="Address">

		<xsl:for-each select="Address|wms:Address|ows:DeliveryPoint|ows11:DeliveryPoint">
			<deliveryPoint>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</deliveryPoint>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="City|wms:City|wcs:address/wcs:city|ows:City|ows11:City">
			<city>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</city>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="StateOrProvince|wms:StateOrProvince|ows:AdministrativeArea|ows11:AdministrativeArea">
			<administrativeArea>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</administrativeArea>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="PostCode|wms:PostCode|ows:PostalCode|ows11:PostalCode">
			<postalCode>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</postalCode>
		</xsl:for-each>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<xsl:for-each select="Country|wms:Country|wcs:address/wcs:country|ows:Country|ows11:Country">
			<country>
				<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
			</country>
		</xsl:for-each>

	</xsl:template>

	<!-- ============================================================================= -->

	<xsl:template name="getOrganisationName">
		<xsl:variable name="organisationName" select="."/>
		<xsl:choose>
			<xsl:when test="$organisationName='Bruxelles Mobilite - Brussel Mobiliteit'">Bruxelles Mobilité / Mobiel Brussel</xsl:when>
			<xsl:when test="$organisationName='CIRB'">CIRB / CIBG</xsl:when>
			<xsl:when test="$organisationName='Bruxelles Environnement-IBGE' or $organisationName='Brussels Hoofdstedelijk Gewest-BIM'">Bruxelles Environnement / Leefmilieu Brussel</xsl:when>
			<xsl:when test="$organisationName='STIB/MIVB' or $organisationName='STIB' or $organisationName='MIVB'">STIB / MIVB</xsl:when>
			<xsl:when test="$organisationName='DGSEI - RN, Monitoring des quartiers - IBSA' or $organisationName='ADSEI - Rijksregister, Wijkmonitoring - BISA'">IBSA / BISA</xsl:when>
			<xsl:when test="$organisationName='BruGIS team - DAF - BDU'">Bruxelles Développement urbain / Brussel Stedelijke Ontwikkeling</xsl:when>
			<xsl:otherwise><xsl:value-of select="$organisationName"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
</xsl:stylesheet>
