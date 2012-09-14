<?xml version="1.0" encoding="UTF-8"?>
<!--

  The contents of this file are subject to the license and copyright
  detailed in the LICENSE and NOTICE files at the root of the source
  tree and available online at

  http://www.dspace.org/license/

-->
<!--
  This XSL theme extends template and adds specific view options based on MIMETYPE

  Author: Ryan McGowan
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
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='DISPLAY']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='DISPLAY']">
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

    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <!-- First, throw any dc.source.uri elements into a file viewer, before showing all metadata-->
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='source'][@qualifier='uri']) &gt; 0">
                <ul id="external_file_list" class="snazy ds-file-list no-js">
                    <xsl:for-each select="dim:field[@element='source'][@qualifier='uri']">
                        <li>
                            <xsl:attribute name="class">
                                <xsl:text>file-entry </xsl:text>
                                <xsl:if test="(position() mod 2 = 0)"> even</xsl:if>
                                <xsl:if test="(position() mod 2 = 1)"> odd</xsl:if>
                            </xsl:attribute>

                            <div class="file-item file-link file-name">
                                <span class="label">Remote Media:</span>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="./node()"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="./node()"/>
                                </a>
                            </div>

                            <div class="file-view">
                                <div class="file-view-container">

                                    <xsl:choose>
                                        <xsl:when test="contains(./node(), '.mp3')">
                                            <!--HTML5 Embed Audio-->
                                            <audio id="html5audio" controls="controls">
                                                <source type="audio/mpeg">
                                                    <xsl:attribute name="src">
                                                        <xsl:value-of select="./node()"/>
                                                    </xsl:attribute>
                                                </source>
                                            </audio>
                                        </xsl:when>
                                        <xsl:when test="contains(./node(), '.m4v')">
                                            <!--HTML5 Embed Video -->
                                            <video id="html5video" width="480" height="360" controls="controls">
                                                <source type="video/x-m4v">
                                                    <xsl:attribute name="src">
                                                        <xsl:value-of select="./node()"/>
                                                    </xsl:attribute>
                                                </source>
                                            </video>
                                            <!--Fallback managed by JS-->
                                            
                                        </xsl:when>

                                        <xsl:otherwise>
                                            Honey Badger
                                        </xsl:otherwise>
                                    </xsl:choose>



                                </div>
                            </div>
                        </li>


                    </xsl:for-each>


                </ul>
            </xsl:when>
        </xsl:choose>


        <!--<ul id="file_list" class="snazy ds-file-list no-js">-->
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


    <!--Snazy New Layout-->
    <xsl:template match="mets:fileGrp[@USE='CONTENT' or @USE='DISPLAY']">
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
        <ul id="file_list" class="snazy ds-file-list no-js">
            <xsl:apply-templates select="mets:file">
                <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:variable name="googleplayer" select="'audio/mpeg audio/basic audio/x-wav'" />
        <xsl:variable name="html5video" select="'video/webm'" />
        <xsl:variable name="flashvideo" select="'video/mp4'" />
        <xsl:variable name="googledocsviewer" select="'application/jsjsjsj'" />
        <xsl:variable name="embedwithfallback" select="'application/x-pdf application/pdf'" />
        <xsl:variable name="mview">
            <xsl:choose>
                <xsl:when test="contains($googleplayer, @MIMETYPE)">
                    <xsl:text>googleplayer</xsl:text>
                </xsl:when>
                <xsl:when test="contains($html5video, @MIMETYPE)">
                    <xsl:text>html5video</xsl:text>
                </xsl:when>
                <xsl:when test="contains($flashvideo, @MIMETYPE)">
                    <xsl:text>flashvideo</xsl:text>
                </xsl:when>
                <xsl:when test="contains($googledocsviewer, @MIMETYPE)">
                    <xsl:text>googledocsviewer</xsl:text>
                </xsl:when>
                <xsl:when test="contains($embedwithfallback, @MIMETYPE)">
                    <xsl:text>embedwithfallback</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>default</xsl:text>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:variable>

        <!-- CSS class names based on MIME type -->
        <xsl:variable name="mimetypeForCSS" select="translate(@MIMETYPE, '/', '-')" />
        <xsl:variable name="mimetypeType" select="substring-before(@MIMETYPE, '/')" />
        <xsl:variable name="mimetypeFormat" select="substring-after(@MIMETYPE, '/')" />
        <li>
            <xsl:attribute name="class">
                <xsl:text>file-entry </xsl:text>
                <xsl:value-of select="$mview" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$mimetypeType" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$mimetypeFormat" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$mimetypeForCSS" />
                <xsl:if test="(position() mod 2 = 0)"> even</xsl:if>
                <xsl:if test="(position() mod 2 = 1)"> odd</xsl:if>
            </xsl:attribute>
            <!--<xsl:text>Filename: </xsl:text>-->
            <div class="file-item file-link file-name">
                <span class="label">File:</span>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                </a>
                <span class="file-size">
                    <xsl:choose>
                        <xsl:when test="@SIZE &lt; 1024">
                            <xsl:value-of select="@SIZE"/>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                        </xsl:when>
                        <xsl:when test="@SIZE &lt; 1024 * 1024">
                            <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                        </xsl:when>
                        <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                            <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </div>
            <div class="slide-arrow show">
              <div class="showhide">
                Show File
              </div>
            </div>
            <div class="file-item file-mimetype last">
                <span class="label">MIME type:</span>
                <span class="value">
                    <xsl:value-of select="@MIMETYPE" />
                </span>
            </div>
            <!-- Display file based on MIME type -->
            <div class="file-view">
              <div class="file-view-container">
                <xsl:choose>
                    <xsl:when test="$mview='googleplayer'">
                        <embed class="googleplayer" type="application/x-shockwave-flash" wmode="transparent" height="27" width="320">
                            <xsl:attribute name="src">
                                <xsl:text>http://www.google.com/reader/ui/3523697345-audio-player.swf?audioUrl=</xsl:text>
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <xsl:attribute name="mime">
                                <xsl:value-of select="@MIMETYPE" />
                            </xsl:attribute>
                        </embed>
                    </xsl:when>
                    <xsl:when test="$mview='html5video'">
                        <video class="html5video" preload="none" controls="controls">
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
                    <xsl:when test="$mview='flashvideo'">
                        <object class="flashvideo" type="application/x-shockwave-flash" data="https://library.osu.edu/assets/inc/player.swf">
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
                    <xsl:when test="$mview='googledocsviewer'">
                        <iframe class="googledocsviewer">
                            <xsl:attribute name="src">
                                <xsl:text>http://docs.google.com/viewer?url=</xsl:text>
                                <!--<xsl:text>http://labs.google.com/papers/bigtable-osdi06.pdf</xsl:text>-->
                                <xsl:value-of select="$baseurl" />
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                                <xsl:text>&#38;embedded=true</xsl:text>
                            </xsl:attribute>
                        </iframe>
                    </xsl:when>
                    <xsl:when test="$mview='embedwithfallback'">
                        <object class="embedwithfallback">
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
            </div>
        </li>
    </xsl:template>

    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">

        <xsl:choose>
            <xsl:when test="count(dim:field[@element='source'][@qualifier='uri']) &gt; 0">
                <h3>Embed Source.URI Media</h3>
                <xsl:for-each select="dim:field[@element='source'][@qualifier='uri']">
                    <xsl:variable name="sourceURI">
                        <xsl:value-of select="./node()"/>
                    </xsl:variable>

                    <embed class="googleplayer" type="application/x-shockwave-flash" wmode="transparent" height="27" width="320">
                        <xsl:attribute name="src">
                            <xsl:text>http://www.google.com/reader/ui/3523697345-audio-player.swf?audioUrl=</xsl:text>
                            <xsl:value-of select="$sourceURI" />
                        </xsl:attribute>
                    </embed>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$sourceURI" />
                        </xsl:attribute>
                        <xsl:text>View this in your browser.</xsl:text>
                    </a>
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
