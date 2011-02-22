<?xml version="1.0" encoding="UTF-8"?>

<!-- bds:

    simple_item_fields.xsl

    customizations included in this file:
    this sheet copies and expands upon the field structures found in
    DIM-Handler.xsl template name="itemSummaryView-DIM-fields"
    This allows for simple item view definitions in individual themes
    without redundant code.
    The default fieldset is defined here, followed by the individual field definitions

    (This is to facilitate translation of existing webui styles from the JSPUI
    and to make future simple item record customizations easier to do.)

    added author browse linkifier
    added field-label and field-data class tags
    
    Brian Stamper

-->



<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:cc="http://creativecommons.org/ns#"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:encoder="xalan://java.net.URLEncoder"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc rdf cc xalan encoder">

    <xsl:output indent="yes"/>

<!-- bds: the default field set

<fieldset name="default">
	<field>dc.title</field>
	<field>dc.title.alternative</field>
	<field>dc.creator</field>
	<field>dc.contributor.ALL</field>
	<field>dc.subject</field>
	<field>dc.date.issued</field>
	<field>dc.publisher</field>
	<field>dc.identifier.citation</field>
	<field>dc.relation.ispartofseries</field>
	<field>dc.description.abstract</field>
	<field>dc.identifier.govdoc</field>
	<field>dc.identifier.uri</field>
	<field>dc.identifier.isbn</field>
	<field>dc.identifier.issn</field>
	<field>dc.identifier.ismn</field>
	<field>dc.identifier</field>
	<field>dc.identifier.other</field>
	<field>dc.rights</field>
</fieldset>
-->

    <xsl:template name="itemSummaryView-DIM-fields">
        <xsl:param name="clause" select="'1'"/>
        <xsl:param name="phase" select="'even'"/>
        <xsl:variable name="otherPhase">
            <xsl:choose>
                <xsl:when test="$phase = 'even'">
                    <xsl:text>odd</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>even</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>


            <xsl:when test="$clause = 1">
                <xsl:call-template name="itemFieldDisplay.dc.title">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 2">
                <xsl:call-template name="itemFieldDisplay.dc.title.alternative">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 3">
                <xsl:call-template name="itemFieldDisplay.dc.creator">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 4">
                <xsl:call-template name="itemFieldDisplay.dc.contributor.ALL">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 5">
                <xsl:call-template name="itemFieldDisplay.dc.subject">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 6">
                <xsl:call-template name="itemFieldDisplay.dc.date.issued">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 7">
                <xsl:call-template name="itemFieldDisplay.dc.publisher">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 8">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.citation">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 9">
                <xsl:call-template name="itemFieldDisplay.dc.relation.ispartofseries">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 10">
                <xsl:call-template name="itemFieldDisplay.dc.description.abstract">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 11">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.govdoc">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 12">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.uri">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 13">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.isbn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 14">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.issn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 15">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.ismn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 16">
                <xsl:call-template name="itemFieldDisplay.dc.identifier">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 17">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.other">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 18">
                <xsl:call-template name="itemFieldDisplay.dc.rights">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <!--<xsl:otherwise>

                <xsl:if test="$clause &lt; 17">
                    <xsl:call-template name="itemSummaryView-DIM-fields">
                        <xsl:with-param name="clause" select="($clause + 1)"/>
                        <xsl:with-param name="phase" select="$phase"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>-->
            
            <!-- bds: the following is used to catch missing values in the above set -->
            <xsl:when test="$clause &lt; 19">
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
 <!--bds: space to add more lines -->
                <xsl:choose>
                    <xsl:when test="dim:field[@element='identifier'][@qualifier='uri']">
                        <tr class="ds-table-row {$phase}">
                            <td class="field-label"></td>
                            <td class="addthis"><xsl:call-template name="addthis_button"/></td>
                        </tr>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="addthis_button">
<!-- bds:
    I've placed this template here in simple_item_fields.xsl because it is being called
    from another template here, where the needed values for title and URL are already
    in scope. In order to make this more generic, such that it can be placed elsewhere on
    the page, it will need to do a metadata fetch to get these values. See the
    "Please use this URL to cite.." section in OSU-local.xsl for an example on how.

    If we want to make this button available at levels higher than just "item",
    we would need to get the page type from the DRI and build the URL and title
    conditionally based upon that.

    Need to escape quote marks in title or button doesn't use handle.net URI
    -->
    <xsl:variable name="titleEscaped">
      <xsl:call-template name="replace-string"> <!-- template in OSU-Local.xsl -->
        <xsl:with-param name="text" select="dim:field[@element='title']"/>
        <xsl:with-param name="replace" select="'&quot;'"/>
        <xsl:with-param name="with" select="'\&quot;'"/>
      </xsl:call-template>
    </xsl:variable>
        <script>
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:text>
<!-- bds: see http://www.addthis.com/help/client-api -->
<!-- bds: using an unregistered username. Need to register for analytics, etc. -->
                var addthis_config = {
                    username: "xa-4c2b76c622a745ed",
                    ui_delay: 200
                }

<!-- bds: force url and title to dc.identifier.uri and dc.title, respectively -->

                var addthis_share = {
                     url: "</xsl:text><xsl:value-of select="dim:field[@element='identifier'][@qualifier='uri']"/><xsl:text>",
                     title: "</xsl:text><xsl:value-of select="$titleEscaped"/><xsl:text>"
                }
            </xsl:text>
        </script>
            <span>
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>https://www.addthis.com/bookmark.php</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>addthis_button</xsl:text>
                    </xsl:attribute>
                    <img>
                        <xsl:attribute name="src">
                            <xsl:text>https://s7.addthis.com/static/btn/v2/lg-share-en.gif</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="width">
                            <xsl:text>125</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="height">
                            <xsl:text>16</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="alt">
                            <xsl:text>Bookmark and Share</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>border:0</xsl:text>
                        </xsl:attribute>
                    </img>
                </a>
            </span>
        <script>
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:attribute name="src">https://s7.addthis.com/js/250/addthis_widget.js</xsl:attribute>
            <xsl:text> </xsl:text>
        </script>

    </xsl:template>





<!-- bds: individual field definitions

        itemFieldDisplay.dc.contributor.ALL  (.*)
        itemFieldDisplay.dc.contributor.advisor
        itemFieldDisplay.dc.contributor.author
        itemFieldDisplay.dc.contributor.editor
        itemFieldDisplay.dc.coverage.spatial
        itemFieldDisplay.dc.creator
        itemFieldDisplay.dc.date.issued
        itemFieldDisplay.dc.description
        itemFieldDisplay.dc.description.abstract
        itemFieldDisplay.dc.description.embargo
        itemFieldDisplay.dc.description.sponsorship
        itemFieldDisplay.dc.description.tableofcontents
        itemFieldDisplay.dc.identifier
        itemFieldDisplay.dc.identifier.citation
        itemFieldDisplay.dc.identifier.doi
        itemFieldDisplay.dc.identifier.govdoc
        itemFieldDisplay.dc.identifier.isbn
        itemFieldDisplay.dc.identifier.ismn
        itemFieldDisplay.dc.identifier.issn
        itemFieldDisplay.dc.identifier.other
        itemFieldDisplay.dc.identifier.tgn
        itemFieldDisplay.dc.identifier.uri
        itemFieldDisplay.dc.publisher
        itemFieldDisplay.dc.relation
        itemFieldDisplay.dc.relation.hasversion
        itemFieldDisplay.dc.relation.ispartofseries
        itemFieldDisplay.dc.relation.issupplementedby
        itemFieldDisplay.dc.rights
        itemFieldDisplay.dc.source.uri
        itemFieldDisplay.dc.subject
        itemFieldDisplay.dc.subject.lcsh
        itemFieldDisplay.dc.title
        itemFieldDisplay.dc.title.alternative

-->
    <xsl:template name="itemFieldDisplay.dc.contributor.ALL"> <!-- .ALL = .* -->
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>

            <xsl:when test="dim:field[@element='contributor']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.contributor.ALL</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.contributor.advisor">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='contributor'][@qualifier='advisor']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.contributor.advisor</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='advisor']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='advisor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.contributor.author">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.contributor.author</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.contributor.editor">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='contributor'][@qualifier='editor']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.contributor.editor</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='editor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.coverage.spatial">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='coverage'][@qualifier='spatial']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.coverage.spatial</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='coverage'][@qualifier='spatial']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='coverage'][@qualifier='spatial']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



<!-- bds: adding linkage to author browse here -->
    <xsl:template name="itemFieldDisplay.dc.creator">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='creator' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.creator</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='creator' and not(@qualifier)]">
                            <!-- bds: link to author browse magic -->
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$context-path"/>
                                    <xsl:text>/browse?value=</xsl:text>
                                    <xsl:value-of select="encoder:encode(string(.))"/>
                                    <xsl:text>&amp;type=author</xsl:text>
                                </xsl:attribute>
                                <xsl:copy-of select="node()"/>
                            </a>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator' and not(@qualifier)]) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    


    <xsl:template name="itemFieldDisplay.dc.date.issued">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='date'][@qualifier='issued']">


                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.date.issued</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='date'][@qualifier='issued']">
                            <span>
                            <xsl:copy-of select="substring(./node(),1,10)"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='date'][@qualifier='issued']) != 0">
                                <br/>
                            </xsl:if>
                            </span>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.description">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='description' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.description.abstract">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='description'][@qualifier='abstract']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description.abstract</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='description'][@qualifier='abstract']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='description'][@qualifier='abstract']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.description.embargo">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='description'][@qualifier='embargo']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description.embargo</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='description'][@qualifier='embargo']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='description'][@qualifier='embargo']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.description.sponsorship">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='description'][@qualifier='sponsorship']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description.sponsorship</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='description'][@qualifier='sponsorship']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='description'][@qualifier='sponsorship']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.description.tableofcontents">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='description'][@qualifier='tableofcontents']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description.tableofcontents</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='description'][@qualifier='tableofcontents']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='description'][@qualifier='tableofcontents']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier' and not(@qualifier)]) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.citation">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='citation']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.citation</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='citation']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='citation']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.doi">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='doi']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.doi</i18n:text>:</span></td>
                    <td class="field-data doi">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='doi']">
                            <xsl:text>http://dx.doi.org/</xsl:text><xsl:copy-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='doi']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.govdoc">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='govdoc']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.govdoc</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='govdoc']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='govdoc']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.isbn">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='isbn']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.isbn</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='isbn']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='isbn']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.ismn">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='ismn']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.ismn</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='ismn']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='ismn']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.issn">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='issn']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.issn</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='issn']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='issn']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="itemFieldDisplay.dc.identifier.other">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier' and @qualifier = 'other']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.other</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier' and @qualifier = 'other']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier = 'other']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.tgn">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='tgn']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.tgn</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='tgn']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='tgn']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.identifier.uri">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier'][@qualifier='uri']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.identifier.uri</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='uri']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier'][@qualifier='uri']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.publisher">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='publisher' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.publisher</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='publisher' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='publisher' and not(@qualifier)]) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="itemFieldDisplay.dc.relation">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='relation' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.relation</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='relation' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='relation' and not(@qualifier)]) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="itemFieldDisplay.dc.relation.hasversion">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='relation'][@qualifier='hasversion']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.relation.hasversion</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='relation'][@qualifier='hasversion']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='relation'][@qualifier='hasversion']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.relation.ispartofseries">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='relation'][@qualifier='ispartofseries']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.relation.ispartofseries</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='relation'][@qualifier='ispartofseries']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='relation'][@qualifier='ispartofseries']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="itemFieldDisplay.dc.relation.issupplementedby">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='relation'][@qualifier='issupplementedby']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.relation.issupplementedby</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='relation'][@qualifier='issupplementedby']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='relation'][@qualifier='issupplementedby']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>








    <xsl:template name="itemFieldDisplay.dc.rights">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>

            <xsl:when test="dim:field[@element='rights']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.rights</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='rights' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='rights']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.source.uri">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='source'][@qualifier='uri']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.source.uri</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='source'][@qualifier='uri']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='source'][@qualifier='uri']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.subject">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='subject' and not(@qualifier)]">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.subject</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='subject' and not(@qualifier)]">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='subject' and not(@qualifier)]) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.subject.lcsh">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='subject'][@qualifier='lcsh']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.subject.lcsh</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='subject'][@qualifier='lcsh']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='lcsh']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.title">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <!-- bds: title is mandatory, so no choose needed -->
                <!-- this is copied from DIM-handler.xsl -->
        <tr class="ds-table-row {$phase}">
            <td class="field-label"><span class="bold"><i18n:text>metadata.dc.title</i18n:text>: </span></td>
            <td class="field-data">
                <!-- bds: removing COinS for now -->
<!--                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>-->
                    <xsl:choose>
                        <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                            <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text><br/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                            <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
<!--                </span>-->
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:template>




    <xsl:template name="itemFieldDisplay.dc.title.alternative">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='title'][@qualifier='alternative']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.title.alternative</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='title'][@qualifier='alternative']">
                            <span>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='title'][@qualifier='alternative']) != 0">
                                <br />
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$phase"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>    