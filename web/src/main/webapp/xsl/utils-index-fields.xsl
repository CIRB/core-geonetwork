<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:gmd="http://www.isotc211.org/2005/gmd"
										xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:gml="http://www.opengis.net/gml"
										xmlns:srv="http://www.isotc211.org/2005/srv"
										xmlns:geonet="http://www.fao.org/geonetwork"
										xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
										xmlns:gmx="http://www.isotc211.org/2005/gmx"
										xmlns:java="java:org.fao.geonet.util.XslUtil"
                                        xmlns:skos="http://www.w3.org/2004/02/skos/core#">

	<!-- inspireThemes is a nodeset consisting of skos:Concept elements -->
	<!-- each containing a skos:definition and skos:prefLabel for each language -->
	<!-- This template finds the provided keyword in the skos:prefLabel elements and returns the English one from the same skos:Concept -->
  
	<xsl:template name="translateInspireThemeToEnglish">
		<xsl:param name="keyword"/>
		<xsl:param name="inspireThemes"/>
		<xsl:variable name="prefLabel" select="$inspireThemes[skos:prefLabel/text()=$keyword]/skos:prefLabel[@xml:lang='en']/text()"/>
		<xsl:if test="$prefLabel">
			<xsl:value-of select="$prefLabel"/>
		</xsl:if>
<!-- 
		<xsl:for-each select="$inspireThemes/skos:prefLabel">
			<xsl:if test="text() = $keyword">
				<xsl:value-of select="../skos:prefLabel[@xml:lang='en']/text()"/>
			</xsl:if>
		</xsl:for-each>
-->		
	</xsl:template>	

	<xsl:template name="determineInspireAnnex">
		<xsl:param name="keyword"/>
		<xsl:param name="thesauriDir"/>
		<xsl:variable name="inspire-thesaurus" select="document(concat('file:///', $thesauriDir, '/external/thesauri/theme/inspire-theme.rdf'))"/>
		<xsl:variable name="inspireThemes" select="$inspire-thesaurus//skos:Concept"/>
		<xsl:variable name="englishKeywordMixedCase">
			<xsl:call-template name="translateInspireThemeToEnglish">
				<xsl:with-param name="keyword" select="$keyword"/>
				<xsl:with-param name="inspireThemes" select="$inspireThemes"/>
			</xsl:call-template>
		</xsl:variable>
	  <xsl:variable name="englishKeyword" select="lower-case($englishKeywordMixedCase)"/>			
	  <!-- Another option could be to add the annex info in the SKOS thesaurus using something
		like a related concept. -->
		<xsl:choose>
			<!-- annex i -->
			<xsl:when test="$englishKeyword='coordinate reference systems' or $englishKeyword='geographical grid systems' 
			            or $englishKeyword='geographical names' or $englishKeyword='administrative units' 
			            or $englishKeyword='addresses' or $englishKeyword='cadastral parcels' 
			            or $englishKeyword='transport networks' or $englishKeyword='hydrography' 
			            or $englishKeyword='protected sites'">
			    <xsl:text>i</xsl:text>
			</xsl:when>
			<!-- annex ii -->
			<xsl:when test="$englishKeyword='elevation' or $englishKeyword='land cover' 
			            or $englishKeyword='orthoimagery' or $englishKeyword='geology'">
				 <xsl:text>ii</xsl:text>
			</xsl:when>
			<!-- annex iii -->
			<xsl:when test="$englishKeyword='statistical units' or $englishKeyword='buildings' 
			            or $englishKeyword='soil' or $englishKeyword='land use' 
			            or $englishKeyword='human health and safety' or $englishKeyword='utility and government services' 
			            or $englishKeyword='environmental monitoring facilities' or $englishKeyword='production and industrial facilities' 
			            or $englishKeyword='agricultural and aquaculture facilities' or $englishKeyword='population distribution - demography' 
			            or $englishKeyword='area management/restriction/regulation zones and reporting units' 
			            or $englishKeyword='natural risk zones' or $englishKeyword='atmospheric conditions' 
			            or $englishKeyword='meteorological geographical features' or $englishKeyword='oceanographic geographical features' 
			            or $englishKeyword='sea regions' or $englishKeyword='bio-geographical regions' 
			            or $englishKeyword='habitats and biotopes' or $englishKeyword='species distribution' 
			            or $englishKeyword='energy resources' or $englishKeyword='mineral resources'">
				 <xsl:text>iii</xsl:text>
			</xsl:when>
			<!-- inspire annex cannot be established: leave empty -->
		</xsl:choose>
	</xsl:template>

	<!-- ========================================================================================= -->

	<!--allText -->
	<xsl:template match="*" mode="allText">
<!-- 
		<xsl:for-each select="@*">
			<xsl:if test="name(.) != 'codeList' ">
				<xsl:value-of select="concat(string(.),' ')"/>
			</xsl:if>
		</xsl:for-each>
 -->
 		<xsl:variable name="stringValue"><xsl:value-of select="normalize-space(gco:CharacterString)"/></xsl:variable>
		<xsl:if test="$stringValue">
			<xsl:value-of select="string($stringValue)"/>
		</xsl:if>
	</xsl:template>

	<!-- ========================================================================================= -->
	<!--allTextByLanguage -->
	<xsl:template match="*" mode="allTextByLanguage">
		<xsl:param name="isoLangId"/>
        <xsl:variable name="pound2LangId" select="concat('#',upper-case(java:twoCharLangCode($isoLangId)))" />
        <xsl:variable name="pound3LangId" select="concat('#',upper-case($isoLangId))" />
<!-- 
		<xsl:for-each select="@*">
			<xsl:if test="name(.) != 'codeList' ">
				<xsl:value-of select="concat(string(.),' ')"/>
			</xsl:if>
		</xsl:for-each>
 -->
 		<xsl:variable name="stringValue"><xsl:value-of select="normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$pound2LangId or @locale=$pound3LangId])"/></xsl:variable>
 		<xsl:choose>
			<xsl:when test="$stringValue">
				<xsl:value-of select="string($stringValue)"/>
			</xsl:when>
			<xsl:otherwise>
<!--
				<xsl:apply-templates select="*" mode="allTextByLanguage">
					<xsl:with-param name="isoLangId" select="$isoLangId"/>
				</xsl:apply-templates>
-->					
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ========================================================================================= -->
	<!-- codelist element, indexed, not stored nor tokenized -->
	<xsl:template match="*[./*/@codeListValue]" mode="codeList">
		<xsl:param name="name" select="name(.)"/>
		<Field name="{$name}" string="{*/@codeListValue}" store="false" index="true"/>
	</xsl:template>
	<!-- ========================================================================================= -->
	<xsl:template match="*" mode="codeList">
		<xsl:apply-templates select="*" mode="codeList"/>
	</xsl:template>
</xsl:stylesheet>
