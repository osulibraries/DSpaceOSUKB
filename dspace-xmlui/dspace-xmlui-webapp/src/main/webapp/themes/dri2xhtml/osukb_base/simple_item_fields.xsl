<?xml version="1.0" encoding="UTF-8"?>

<!--

    simple_item_fields.xsl

    customizations included in this file:
    this sheet copies and expands upon the field structures found in
    DIM-Handler.xsl template name="itemSummaryView-DIM-fields"
    This allows for simple item view definitions in individual themes
    without redundant code.

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
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc rdf cc">

    <xsl:output indent="yes"/>


    <!-- Contents:

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
        itemFieldDisplay.dc.identifier.tgn
        itemFieldDisplay.dc.identifier.uri
        itemFieldDisplay.dc.publisher
        itemFieldDisplay.dc.relation.hasversion
        itemFieldDisplay.dc.relation.ispartofseries
        itemFieldDisplay.dc.relation.relateditem
        itemFieldDisplay.dc.rights.ALL  (.*)
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
                                    <xsl:value-of select="node()"/>
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
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='identifier'][@qualifier='doi']">

                            <a>
                                <xsl:attribute name="href">http://dx.doi.org/<xsl:copy-of select="./node()"/>
                                </xsl:attribute>
                                <xsl:copy-of select="./node()"/>
                            </a>

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








    <xsl:template name="itemFieldDisplay.dc.rights.ALL"> <!-- .ALL = .* -->
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>

            <xsl:when test="dim:field[@element='rights']">
                <tr class="ds-table-row {$phase}">
                    <td class="field-label"><span class="bold"><i18n:text>metadata.dc.rights.ALL</i18n:text>:</span></td>
                    <td class="field-data">
                        <xsl:for-each select="dim:field[@element='rights']">
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
                <!-- bds: not sure what this z3988 (OpenURL?) and COinS stuff is about -->
                <!--        but I left it out of dc.title.alternative, hopefully not a problem -->
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
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
                </span>
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





    <!-- bds:stuff below this line is mostly workspace and should eventually be gone -->













<!--

        <xsl:template name="">
                <xsl:param name="clause" />
                <xsl:param name="phase" />
                <xsl:param name="otherPhase" />
                <xsl:choose>
                        <xsl:when test="">


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

-->











<!--


    <xsl:template name="dc.creator">
        <xsl:param name="clause" />
        <xsl:param name="phase" />
        <xsl:param name="otherPhase" />
        <xsl:choose>
            <xsl:when test="dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor']">
                <tr class="ds-table-row {$phase}">
                    <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:</span></td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <br />
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <br />
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <br />
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
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









    <xsl:when test="$clause = 3 and (dim:field[@element='publisher' and not(@qualifier)])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold">Publisher:</span></td>
            <td>
                <xsl:if test="count(dim:field[@element='publisher' and not(@qualifier)]) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
                <xsl:for-each select="dim:field[@element='publisher' and not(@qualifier)]">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='publisher' and not(@qualifier)]) != 0">
                        <hr class="metadata-seperator"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='publisher' and not(@qualifier)]) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>


    <xsl:when test="$clause = 4 and (dim:field[@element='date' and @qualifier='issued'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span></td>
            <td>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>

    <xsl:when test="$clause = 5 and (dim:field[@element='description' and @qualifier='abstract'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</span></td>
            <td>
                <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
                <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                        <hr class="metadata-seperator"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>

    <xsl:when test="$clause = 6 and (dim:field[@element='description' and not(@qualifier)])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</span></td>
            <td>
                <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
                    <hr class="metadata-seperator"/>
                </xsl:if>
                <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                        <hr class="metadata-seperator"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>



    <xsl:when test="$clause = 7 and (dim:field[@element='relation' and @qualifier='ispartofseries'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold">dc.relation.ispartofseries:</span></td>
            <td>
                <xsl:if test="count(dim:field[@element='relation' and @qualifier='ispartofseries']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartofseries']) != 0">
                        <hr class="metadata-seperator"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='relation' and @qualifier='ispartofseries']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>




    <xsl:when test="$clause = 8 and (dim:field[@element='relation' and @qualifier='relateditem'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold">dc.relation.relateditem:</span></td>
            <td>
                <xsl:if test="count(dim:field[@element='relation' and @qualifier='relateditem']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='relateditem']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='relateditem']) != 0">
                        <hr class="metadata-seperator"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='relation' and @qualifier='relateditem']) &gt; 1">
                    <hr class="metadata-seperator"/>
                </xsl:if>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>



    <xsl:when test="$clause = 19 and (dim:field[@element='identifier' and @qualifier='doi'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold">DOI:</span></td>
            <td>
                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
                    <a>
                        <xsl:attribute name="href">http://dx.doi.org/<xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                        <xsl:copy-of select="./node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>



    <xsl:when test="$clause = 10 and (dim:field[@element='identifier' and @qualifier='uri'])">
        <tr class="ds-table-row {$phase}">
            <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span></td>
            <td>
                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                        <xsl:copy-of select="./node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
        <xsl:call-template name="itemSummaryView-DIM-fields">
            <xsl:with-param name="clause" select="($clause + 1)"/>
            <xsl:with-param name="phase" select="$otherPhase"/>
        </xsl:call-template>
    </xsl:when>




-->






</xsl:stylesheet>    