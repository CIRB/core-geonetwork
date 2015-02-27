<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/"
                               xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
                               xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0">


            <!--URL of this document-->
            <xsl:choose>
                <xsl:when test="string(/root/response/fileId)">
                    <ShortName>INSPIRE Download</ShortName>
                    <LongName><xsl:value-of select="substring(/root/response/title,1,48)"/></LongName>
<!--                    <Description><xsl:value-of select="concat(/root/response/title,'; ',concat(/root/response/subtitle)"/></Description>-->
                    <Description><xsl:value-of select="/root/response/title"/>: <xsl:value-of select="/root/response/subtitle"/></Description>
                    <Url type="application/opensearchdescription+xml" rel="self" >
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/OpenSearchDescription.xml')"/>
                        </xsl:attribute>
                    </Url>

                    <!--Generic URL template for browser integration-->
<!--
                    <Url type="application/atom+xml" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/describe')"/>
                        </xsl:attribute>
                    </Url>
-->

                    <!--Generic URL template for browser integration-->
                    <Url type="text/html" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/htmlsearch?q={searchTerms?}')"/>
                        </xsl:attribute>
                    </Url>
                </xsl:when>
                <xsl:otherwise>
                    <ShortName>INSPIRE Download</ShortName>
                    <LongName><xsl:value-of select="substring(//site/organization,1,24)"/> | GeoNetwork opensource</LongName>
                    <Description><xsl:value-of select="/root/gui/strings/opensearch"/></Description>

                    <!--Generic URL template for browser integration-->
                    <Url type="application/xml" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/search?q={searchTerms?}')"/>
                        </xsl:attribute>
                    </Url>
                </xsl:otherwise>
            </xsl:choose>




            <!-- Repeat the following for each dataset Atom feed -->
            <xsl:for-each select="/root/response/datasets/dataset">

                <xsl:variable name="codeVal" select="code" />
                <xsl:variable name="namespaceVal" select="namespace" />

                <!--Describe Spatial Data Set Operation request URL template to be used
                    in order to retrieve the Description of Spatial Object Types in a Spatial
                    Dataset-->
                <Url type="application/atom+xml" rel="describedby">
                    <xsl:attribute name="template">
						<xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/describe?spatial_dataset_identifier_code={inspire_dls:spatial_dataset_identifier_code?}&amp;spatial_dataset_identifier_namespace={inspire_dls:spatial_dataset_identifier_namespace?}&amp;crs={inspire_dls:crs?}&amp;language={language?}&amp;q={searchTerms?}')"/>
                    </xsl:attribute>
                </Url>

				<xsl:variable name="url" select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/download?spatial_dataset_identifier_code={inspire_dls:spatial_dataset_identifier_code?}&amp;spatial_dataset_identifier_namespace={inspire_dls:spatial_dataset_identifier_namespace?}&amp;crs={inspire_dls:crs?}&amp;language={language?}&amp;q={searchTerms?}')"/>
                <Url type="application/x-shapefile" rel="results">
                    <xsl:attribute name="template"><xsl:value-of select="$url"/></xsl:attribute>
                </Url>
                <Url type="application/x-gmz" rel="results">
                    <xsl:attribute name="template"><xsl:value-of select="$url"/></xsl:attribute>
                </Url>
                <!-- Repeat for each below to download the file from a dataset -->
<!-- 
                <xsl:for-each select="file">
                    <Url rel="results">
                        <xsl:attribute name="type">
                            <xsl:value-of select="type" />
                        </xsl:attribute>
                        <xsl:attribute name="template">
                            <xsl:choose>
                                <xsl:when test="type = 'application/atom+xml'">
                                    <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/download?spatial_dataset_identifier_code=', $codeVal, '&amp;spatial_dataset_identifier_namespace=', $namespaceVal,'&amp;crs=', crs,'&amp;language=', /root/response/lang)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/download?spatial_dataset_identifier_code=', $codeVal, '&amp;spatial_dataset_identifier_namespace=', $namespaceVal,'&amp;crs=', crs,'&amp;language=', /root/response/lang)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </Url>
                </xsl:for-each>
 -->
 			</xsl:for-each>

            <!-- Repeat the following for each data set, for each CRS of a dataset query example (regardless of the number of file formats -->
            <xsl:for-each select="/root/response/datasets/dataset">
                <xsl:variable name="codeVal" select="code" />
                <xsl:variable name="namespaceVal" select="namespace" />

                <xsl:for-each select="file">
                    <Query role="example"
                           inspire_dls:spatial_dataset_identifier_namespace="{$namespaceVal}"
                           inspire_dls:spatial_dataset_identifier_code="{$codeVal}" inspire_dls:crs="{crs}" language="{lang}" title="{title}" count="{crsCount}"/>
                </xsl:for-each>

            </xsl:for-each>

            <xsl:choose>
                <xsl:when test="string(/root/response/fileId)">
                    <!-- For each Service Feed the contact -->
                    <Contact><xsl:value-of select="/root/response/authorEmail" /></Contact>
                    <Tags><xsl:value-of select="/root/response/keywords" /></Tags>
                    <!-- per Atom Service feed / Service metadata record combinatie: -->
                    <Developer><xsl:value-of select="/root/response/authorName" /></Developer>
                    <!--Languages supported by the service. The first language is the default language-->
                    <!-- And for each language of the Service Feed: -->
                    <Language><xsl:value-of select="/root/response/lang"/></Language>
                </xsl:when>
                <xsl:otherwise>
                    <Contact><xsl:value-of select="//feedback/email"/></Contact>
                    <Tags>GeoNetwork Metadata ISO19115 ISO19139 DC FGDC</Tags>
                    <Language><xsl:value-of select="/root/gui/language"/></Language>
                </xsl:otherwise>
            </xsl:choose>


        </OpenSearchDescription>
    </xsl:template>
</xsl:stylesheet>