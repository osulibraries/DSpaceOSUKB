<?xml version="1.0" encoding="UTF-8"?>

<!-- bds: this is meant to be a theme that has a defined
    fieldset for simple item view -->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:import href="../dri2xhtml.xsl"/>
    <xsl:output indent="yes"/>


    <xsl:variable name="fieldset">
        <fields>
            <field>dc.title</field>
            <field>dc.title.alternative</field>
            <field>dc.creator</field>
            <field>dc.contributor.ALL</field>
            <field>dc.date.issued</field>
            <field>dc.description.abstract</field>
            <field>dc.description.tableofcontents</field>
            <field>dc.description</field>
            <field>dc.publisher</field>
            <field>dc.subject</field>
            <field>dc.relation.ispartofseries</field>
            <field>dc.identifier</field>
            <field>dc.identifier.govdoc</field>
            <field>dc.identifier.uri</field>
        </fields>
    </xsl:variable>

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
            <xsl:when test="$clause &lt; count($fieldset/fields/field)">
                <xsl:call-template name="concat('itemFieldDisplay.', $fieldset/fields/field[$clause])">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$clause &lt; count($fieldset/fields/field)">
                    <xsl:call-template name="itemSummaryView-DIM-fields">
                        <xsl:with-param name="clause" select="($clause + 1)"/>
                        <xsl:with-param name="phase" select="$phase"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
