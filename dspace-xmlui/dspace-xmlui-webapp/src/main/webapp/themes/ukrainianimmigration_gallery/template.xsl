<?xml version="1.0" encoding="UTF-8"?>

<!--
  template.xsl

  Version: $Revision: 3705 $
 
  Date: $Date: 2009-04-11 13:02:24 -0400 (Sat, 11 Apr 2009) $
 
  Copyright (c) 2002-2005, Hewlett-Packard Company and Massachusetts
  Institute of Technology.  All rights reserved.
 
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:
 
  - Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
 
  - Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
 
  - Neither the name of the Hewlett-Packard Company nor the name of the
  Massachusetts Institute of Technology nor the names of their
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  DAMAGE.
-->

<!--
    TODO: Describe this XSL file    
    Author: Alexey Maslov
    
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

    <xsl:import href="../gallery/gallery.xsl"/>

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
            <xsl:call-template name="itemFieldDisplay.dc.subject">
                <xsl:with-param name="clause" select="$clause" />
                <xsl:with-param name="phase" select="$phase" />
                <xsl:with-param name="otherPhase" select="$otherPhase" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$clause = 4">
            <xsl:call-template name="itemFieldDisplay.dc.coverage.spatial">
                <xsl:with-param name="clause" select="$clause" />
                <xsl:with-param name="phase" select="$phase" />
                <xsl:with-param name="otherPhase" select="$otherPhase" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$clause = 5">
            <xsl:call-template name="itemFieldDisplay.dc.description">
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
            <xsl:call-template name="itemFieldDisplay.dc.identifier.uri">
                <xsl:with-param name="clause" select="$clause" />
                <xsl:with-param name="phase" select="$phase" />
                <xsl:with-param name="otherPhase" select="$otherPhase" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$clause = 9">
            <xsl:call-template name="itemFieldDisplay.dc.rights">
                <xsl:with-param name="clause" select="$clause" />
                <xsl:with-param name="phase" select="$phase" />
                <xsl:with-param name="otherPhase" select="$otherPhase" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$clause &lt; 10">
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
