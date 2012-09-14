<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

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
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">
    
    <xsl:import href="../dri2xhtml.xsl"/>
    <xsl:output indent="yes"/>
    

<!-- for realplayer theme, we remove the file list from simple item view -->

    <!-- An item rendered in the summaryView pattern. This is the default way to view a DSpace item in Manakin. -->
    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>

    </xsl:template>


<!-- for realplayer theme, add the player. -->

    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">

        <xsl:choose>
            <xsl:when test="count(dim:field[@element='source'][@qualifier='uri']) &gt; 0">
                <xsl:for-each select="dim:field[@element='source'][@qualifier='uri']">
                    <xsl:variable name="sourceURI">
                        <xsl:value-of select="./node()"/>
                    </xsl:variable>

		    <embed console="RealPlayer" controls="All" height="100" width="375" type="audio/x-pn-realaudio-plugin" autostart="true">
                       	<xsl:attribute name="src">
	                    <xsl:value-of select="$sourceURI" />
        	        </xsl:attribute>
		    </embed>
		    <br />
                    <p>Requires RealPlayer to view. If the player does not automatically load, try clicking 
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$sourceURI" />
                            </xsl:attribute>
                            <xsl:text>here</xsl:text>
                        </a> instead.
                    </p>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <table class="ds-includeSet-table">
            <xsl:call-template name="itemSummaryView-DIM-fields">
            </xsl:call-template>
        </table>
        <xsl:if test="$config-use-COinS = 1">
            <!--  Generate COinS  -->
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
        </xsl:if>

        <!-- bds: this seemed as appropriate a place as any to throw in the blanket copyright notice -->
        <!--        see also match="dim:dim" mode="itemDetailView-DIM"  -->
        <p class="copyright-text">Items in Knowledge Bank are protected by copyright, with all rights reserved, unless otherwise indicated.</p>
    </xsl:template>
    
</xsl:stylesheet>
