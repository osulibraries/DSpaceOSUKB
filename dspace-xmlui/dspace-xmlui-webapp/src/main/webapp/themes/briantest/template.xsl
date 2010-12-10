<?xml version="1.0" encoding="UTF-8"?>

<!-- Brian's testing template -->

<!-- first section is the header, where utility links are added -->
<!-- working area is located toward the end of this file -->
<!-- find "begin working area" -->

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

    <xsl:import href="../dri2xhtml.xsl"/>
    <xsl:output indent="yes"/>


    <!-- buildHeader is copied here for the convenience of adding utility links  -->

    <!-- bds: text header -->
    <xsl:template name="buildHeader">
        <div id="ds-header">

            <h1 class="pagetitle">Brian's testing theme</h1>

            <h3>This is currently being used to:</h3>
            <p>
                Aid in visual design. Currently set as the default theme in xmlui.xconf.
            </p>
            <h3>Variables, etc.:</h3>
            <p>
                <xsl:text>$context-path:</xsl:text>
                <xsl:value-of select="$context-path" />
            </p>

            <!-- bds: qString = ?queryString& if length > 0 or = ? if length = 0 -->
            <xsl:variable name="qString">
                <xsl:choose>
                    <xsl:when test="string-length(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='queryString']) != 0"><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@qualifier='queryString']"/>&amp;</xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>

            <ul id="ds-trail">
                <xsl:choose>
                    <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) = 0">
                        <li class="ds-trail-link first-link"> - </li>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                    </xsl:otherwise>
                </xsl:choose>
            </ul>


            <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                    <div id="ds-user-box">
                        <p>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                                  dri:metadata[@element='identifier' and @qualifier='url']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.profile</i18n:text>
                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                              dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                              dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                            </a>
                            <xsl:text> | </xsl:text>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                                  dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                            </a>
                            <!-- bds: adding utility links here -->
                            <!-- bds: Item METS link, if exists -->
                            <xsl:if test="/dri:document/dri:body/dri:div/dri:referenceSet/dri:reference[@type='DSpace Item']">
                                <xsl:text> | </xsl:text>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat($context-path,/dri:document/dri:body/dri:div/dri:referenceSet/dri:reference/@url)"/>
                                    </xsl:attribute>
                                    <i18n:text>Item METS</i18n:text>
                                </a>
                            </xsl:if>
                            <!-- bds: DRI link -->
                            <xsl:text> | </xsl:text>
                            <a>
                                <xsl:attribute name="href">?<xsl:value-of select="$qString"/>XML</xsl:attribute>
                                <xsl:text>DRI</xsl:text>
                            </a>
                        </p>
                        <!-- bds: themepaths -->
                        <p>
                            <ul>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=brian/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>brian</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=Kubrick/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>Kubrick</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=Nubrick/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>Nubrick</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=Classic/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>Classic</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=Reference/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>Reference</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=defaultXMLUI/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>defaultXMLUI</xsl:text>
                                </a></li>
                                <li><a>
                                        <xsl:attribute name="href">?themepath=template/&amp;<xsl:value-of select="$qString"/></xsl:attribute>
                                        <xsl:text>template</xsl:text>
                                </a></li>
                            </ul>
                        </p>

                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div id="ds-user-box">
                        <p>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                                  dri:metadata[@element='identifier' and @qualifier='loginURL']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                            </a>
                        </p>
                    </div>
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>


<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->
<!-- begin working area -->






</xsl:stylesheet>
