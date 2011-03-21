<?xml version="1.0" encoding="UTF-8"?>
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
        <xsl:call-template name="itemFieldDisplay.dc.creator">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 3">
        <xsl:call-template name="itemFieldDisplay.dc.contributor.advisor">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 4">
        <xsl:call-template name="itemFieldDisplay.dc.subject">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 5">
        <xsl:call-template name="itemFieldDisplay.dc.date.issued">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 6">
        <xsl:call-template name="itemFieldDisplay.dc.publisher">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 7">
        <xsl:call-template name="itemFieldDisplay.dc.identifier.citation">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 8">
        <xsl:call-template name="itemFieldDisplay.dc.relation.ispartofseries">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 9">
        <xsl:call-template name="itemFieldDisplay.dc.description.abstract">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 10">
        <xsl:call-template name="itemFieldDisplay.dc.description">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 11">
        <xsl:call-template name="itemFieldDisplay.dc.description.sponsorship">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 12">
        <xsl:call-template name="itemFieldDisplay.dc.description.embargo">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 13">
        <xsl:call-template name="itemFieldDisplay.dc.identifier.uri">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause = 14">
        <xsl:call-template name="itemFieldDisplay.dc.rights">
            <xsl:with-param name="clause" select="$clause" />
            <xsl:with-param name="phase" select="$phase" />
            <xsl:with-param name="otherPhase" select="$otherPhase" />
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="$clause &lt; 15">
        <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$phase"/>
        </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
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
                    
</xsl:stylesheet>
                