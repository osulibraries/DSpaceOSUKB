<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

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
    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <!-- bds: moving file info above metadata -->
        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            <xsl:otherwise> <!-- bds: when would this otherwise occur? -->
                <!-- <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2> -->
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

        <br />

        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>

    </xsl:template>

    <!--Snazy New Layout-->
    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:call-template name="mimeviews">
            <xsl:with-param name="context" select="$context" />
            <xsl:with-param name="primaryBitstream" select="$primaryBitstream" />
        </xsl:call-template>
    </xsl:template>

    <!-- Default Table format -->

    <xsl:template name="mimeviews">
        <xsl:param name="context" />
        <xsl:param name="primaryBitstream" />
        <xsl:apply-templates select="mets:file">
            <xsl:with-param name="context" select="$context"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:variable name="googleplayer" select="'audio/mpeg,audio/basic,audio/x-wav'" />
        <xsl:variable name="html5video" select="'video/webm'" />
        <xsl:variable name="flashvideo" select="'video/mp4'" />
        <xsl:variable name="googledocsviewer" select="'application/jsjsjsj'" />
        <xsl:variable name="embedwithfallback" select="'application/x-pdf,application/pdf'" />
        <div>
            <xsl:text>File:</xsl:text>
            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            <xsl:choose>
                <xsl:when test="contains($googleplayer, @MIMETYPE)">
                    <embed type="application/x-shockwave-flash" wmode="transparent" height="27" width="320">
                        <xsl:attribute name="src">
                            <xsl:text>http://www.google.com/reader/ui/3523697345-audio-player.swf?audioUrl=</xsl:text>
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:attribute name="mime">
                            <xsl:value-of select="@MIMETYPE" />
                        </xsl:attribute>
                    </embed>
                </xsl:when>
                <xsl:when test="contains($html5video, @MIMETYPE)">
                    <video controls="controls" width="200">
                        <xsl:attribute name="src">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                        </xsl:attribute>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                        </a>
                    </video>
                </xsl:when>
                <xsl:when test="contains($flashvideo, @MIMETYPE)">
                    <object width="200" height="166" type="application/x-shockwave-flash" data="https://library.osu.edu/assets/inc/player.swf">
                        <param value="player" name="name" />
                        <param value="true" name="allowfullscreen" />
                        <param value="always" name="allowscriptaccess" />
                        <param name="flashvars">
                            <xsl:attribute name="value">
                                <xsl:text>file=</xsl:text>
                                <xsl:value-of select="$baseurl"/>
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </param>
                        <param value="https://library.osu.edu/assets/inc/player.swf" name="src" />
                    </object>
                </xsl:when>
                <xsl:when test="contains($googledocsviewer, @MIMETYPE)">
                    <iframe width="400" height="500" style="border: none;">
                        <xsl:attribute name="src">
                            <xsl:text>http://docs.google.com/viewer?url=</xsl:text>
                            <!--<xsl:text>http://labs.google.com/papers/bigtable-osdi06.pdf</xsl:text>-->
                            <xsl:value-of select="$baseurl" />
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:text>&#38;embedded=true</xsl:text>
                        </xsl:attribute>
                    </iframe>
                </xsl:when>
                <xsl:when test="contains($embedwithfallback, @MIMETYPE)">
                    <object width="300" height="200">
                        <xsl:attribute name="data">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:attribute name="type">
                            <xsl:value-of select="@MIMETYPE" />
                        </xsl:attribute>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                        </a>
                    </object>
                </xsl:when>
                <xsl:otherwise>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
</xsl:stylesheet>
