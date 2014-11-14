<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:exslt="http://exslt.org/common" xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:saxon="http://saxon.sf.net/"
  extension-element-prefixes="saxon"
  exclude-result-prefixes="exslt xlink gco gmd geonet svrl saxon date">

  <!-- ================================================================================ -->
  <!-- 
    returns the help url 
    -->
  <xsl:template name="getHelpLink">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>

    <xsl:choose>
      <xsl:when test="contains($name,'_ELEMENT')">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>

        <xsl:variable name="fullContext">
          <xsl:call-template name="getXPath"/>
        </xsl:variable>

        <xsl:value-of
          select="concat($schema,'|', $name ,'|', name(parent::node()) ,'|', $fullContext ,'|', ../@gco:isoType)"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="getXPath">
	<xsl:param name="node" select="."/>
<!--
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:if test="not(position() = 1)">
        <xsl:value-of select="name()"/>
      </xsl:if>
      <xsl:if test="not(position() = 1) and not(position() = last())">
        <xsl:text>/</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="count(. | ../@*) = count(../@*)">/@<xsl:value-of select="name()"/></xsl:if>
-->
	    <xsl:for-each select="$node/ancestor-or-self::*">
	      <xsl:if test="not(position() = 1)">
	        <xsl:value-of select="name()"/>
	      </xsl:if>
	      <xsl:if test="not(position() = 1) and not(position() = last())">
	        <xsl:text>/</xsl:text>
	      </xsl:if>
	    </xsl:for-each>
	    <xsl:if test="count($node | $node/../@*) = count($node/../@*)">/@<xsl:value-of select="$node/name()"/></xsl:if>
  </xsl:template>

  <xsl:template name="getTitleColor">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>

    <xsl:variable name="fullContext">
      <xsl:call-template name="getXPath"/>
    </xsl:variable>

    <xsl:variable name="context" select="name(parent::node())"/>
    <xsl:variable name="contextIsoType" select="parent::node()/@gco:isoType"/>

    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="starts-with($schema,'iso19139')">

          <!-- Name with context in current schema -->
          <xsl:variable name="colorTitleWithContext"
            select="string(/root/gui/schemas/*[name(.)=$schema]/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label_color)"/>

          <!-- Name with context in base schema -->
          <xsl:variable name="colorTitleWithContextIso"
            select="string(/root/gui/schemas/iso19139/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label_color)"/>

          <!-- Name in current schema -->
          <xsl:variable name="colorTitle"
            select="string(/root/gui/schemas/*[name(.)=$schema]/element[@name=$name and not(@context)]/label_color)"/>

          <xsl:choose>

            <xsl:when
              test="normalize-space($colorTitle)='' and
              normalize-space($colorTitleWithContext)='' and
              normalize-space($colorTitleWithContextIso)=''">
              <xsl:value-of
                select="string(/root/gui/schemas/iso19139/element[@name=$name]/label_color)"/>
            </xsl:when>
            <xsl:when
              test="normalize-space($colorTitleWithContext)='' and
              normalize-space($colorTitleWithContextIso)=''">
              <xsl:value-of select="$colorTitle"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$colorTitleWithContext"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- otherwise just get the title out of the approriate schema help file -->

        <xsl:otherwise>
          <xsl:value-of
            select="string(/root/gui/schemas/*[name(.)=$schema]/element[@name=$name]/label_color)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="$color"/>
  </xsl:template>

  <!--
    Returns the title of an element. If the schema is an ISO profil then search:
    * the ISO profil help first
    * with context (ie. context is the class where the element is defined)
    * with no context
    and if not found search the iso19139 main help.
    
    If not iso based, search in corresponding schema.
    
    If not found return the element name.
  -->
  <xsl:template name="getTitle">
    <xsl:param name="name"/>
    <xsl:param name="schema"/>
    <xsl:param name="node" select="."/>
    
    <xsl:variable name="fullContext">
        <xsl:call-template name="getXPath">
			<xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
    </xsl:variable>

	<xsl:variable name="possibleConditions" select="'mandatory|obligatoire|verplicht'"/>
    <xsl:variable name="context" select="name($node/parent::node())"/>
    <xsl:variable name="contextIsoType" select="$node/parent::node()/@gco:isoType"/>
    
		<xsl:variable name="condition" />
		<xsl:variable name="title">
	      <xsl:choose>
	        <xsl:when test="starts-with($schema,'iso19139')">
          <!-- Name with context in current schema -->
          <xsl:variable name="schematitleWithContext"
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label)"/>

          <!-- Name with context in base schema -->
          <xsl:variable name="schematitleWithContextIso"
            select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/label)"/>

          <!-- Name in current schema -->
          <xsl:variable name="schematitle"
            select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/label/text()"/>
          
          <xsl:choose>
            <xsl:when test="normalize-space($schematitleWithContext)!=''">
				  <xsl:variable name="condition" select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/condition)"/>
			      <xsl:if test="$condition and contains($possibleConditions,lower-case($condition))">
			      	<xsl:value-of select="concat($schematitleWithContext,' (*)')"/>
			      </xsl:if>
			      <xsl:if test="not($condition and contains($possibleConditions,lower-case($condition)))">
			      	<xsl:value-of select="$schematitleWithContext"/>
			      </xsl:if>
            </xsl:when>
            <xsl:when test="normalize-space($schematitleWithContextIso)!=''">
				  <xsl:variable name="condition" select="string(/root/gui/schemas/iso19139/labels/element[@name=$name and (@context=$fullContext or @context=$context or @context=$contextIsoType)]/condition)"/>
			      <xsl:if test="$condition and contains($possibleConditions,lower-case($condition))">
			      	<xsl:value-of select="concat($schematitleWithContextIso,' (*)')"/>
			      </xsl:if>
			      <xsl:if test="not($condition and contains($possibleConditions,lower-case($condition)))">
			      	<xsl:value-of select="$schematitleWithContextIso"/>
			      </xsl:if>
            </xsl:when>
            <xsl:when test="normalize-space($schematitle)!=''">
				  <xsl:variable name="condition" select="/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/condition/text()"/>
			      <xsl:if test="$condition and contains($possibleConditions,lower-case($condition))">
			      	<xsl:value-of select="concat($schematitle,' (*)')"/>
			      </xsl:if>
			      <xsl:if test="not($condition and contains($possibleConditions,lower-case($condition)))">
			      	<xsl:value-of select="$schematitle"/>
			      </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="/root/gui/schemas/iso19139/labels/element[@name=$name and not(@context)]/label/string()"/>
            </xsl:otherwise>
          </xsl:choose>
	        </xsl:when>
	
        <!-- otherwise just get the title out of the approriate schema help file -->

        <xsl:otherwise>
          <xsl:value-of
            select="string(/root/gui/schemas/*[name(.)=$schema]/labels/element[@name=$name and not(@context)]/label)"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="normalize-space($title)!=''">
        <xsl:value-of select="$title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>





  <!-- build attribute name (in place of standard attribute name) as a 
    work-around to deal with qualified attribute names like gml:id
    which if not modified will cause JDOM errors on update because of the
    way in which changes to ref'd elements are parsed as XML -->
  <xsl:template name="getAttributeName">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="contains($name,':')">
        <xsl:value-of
          select="concat(substring-before($name,':'),'COLON',substring-after($name,':'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
