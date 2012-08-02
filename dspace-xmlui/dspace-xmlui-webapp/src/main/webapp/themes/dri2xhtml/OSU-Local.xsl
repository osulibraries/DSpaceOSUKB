<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : OSU-local.xsl
    Created on : July 6, 2010, 2:56 PM
    Author     : stamper.10
    Description:
        Contains templates that only exist in our local customization, as
        opposed to overrides that are found within the other xsl in this folder.
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


    <xsl:template name="buildHeadOSU">
        <!-- Grab Google CDN jQuery. fall back to local if necessary. Also use same http / https as site -->
        <script type="text/javascript">
            var JsHost = (("https:" == document.location.protocol) ? "https://" : "http://");
            document.write(unescape("%3Cscript src='" + JsHost + "ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js' type='text/javascript'%3E%3C/script%3E"));

            if(!window.jQuery) {
                document.write(unescape("%3Cscript src='<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>/static/js/jquery-1.7.2.min.js' type='text/javascript'%3E%3C/script%3E"));
            }
        </script>

        <!-- bds: text-field-prompt.js for global search box, uses jQuery -->
        <!-- see http://kyleschaeffer.com/best-practices/input-prompt-text/ -->
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/js/text-field-prompt.js</xsl:text>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </script>
        <link rel="shortcut icon " type="image/x-icon">
            <xsl:attribute name="href">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/osu-navbar-media/img/favicon.ico</xsl:text>
            </xsl:attribute>
        </link>
        <!-- bds: jQuery breadcrumb trail shrinker, uses easing plugin -->
        <!-- http://www.comparenetworks.com/developers/jqueryplugins/jbreadcrumb.html -->
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/js/jquery.easing.1.3.js</xsl:text>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </script>
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/js/jquery.jBreadCrumb.1.1.js</xsl:text>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </script>
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/js/ba-linkify.min.js</xsl:text>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </script>
        <script type="text/javascript">
            $(document).ready(function() {
                $("#breadCrumb0").jBreadCrumb();

                /* Linkify All Item Metadata content */
                $('#aspect_artifactbrowser_ItemViewer_div_item-view table.ds-includeSet-table tr.ds-table-row td span').each(function(){
                    var that = $(this),
                    text = that.html(),
                    options = {callback: function( text, href ) {return href ? '<a href="' + href + '" title="' + text + '">' + text + '</a>' : text;}};
                    that.html(linkify(text, options ));
                });
            });
        </script>
    </xsl:template>

    <!-- 2012-07-31 DE Redid the OSU Navbar -->
    <xsl:template name="buildBodyOSU">
        <div id="osu-nav-bar" class="clearfix">
            <h2 class="visuallyhidden">OSU Navigation Bar</h2>
            <a href="#main-content" id="skip" class="osu-semantic">Skip to main content</a>
            <p id="osu-site-title">
                <a href="http://www.osu.edu/" title="The Ohio State University homepage">The Ohio State University</a>
                <a href="http://library.osu.edu/" title="University Libraries at The Ohio State University">University Libraries</a>
                <a href="http://kb.osu.edu/" title="Knowledge Bank of University Libraries at The Ohio State University">Knowledge Bank</a>
            </p>
            <div id="osu-nav-primary">
                <h3 class="visuallyhidden">Links:</h3>
                <ul>
                    <li><a href="http://www.osu.edu/help.php" title="OSU Help">Help</a></li>
                    <li><a href="http://buckeyelink.osu.edu/" title="Buckeye Link">Buckeye Link</a></li>
                    <li><a href="http://www.osu.edu/map/" title="Campus map">Map</a></li>
                    <li><a href="http://www.osu.edu/findpeople.php" title="Find people at OSU">Find People</a></li>
                    <li><a href="https://webmail.osu.edu/" title="OSU Webmail">Webmail</a></li>
                    <li><a href="http://www.osu.edu/search.php" title="Search Ohio State">Search Ohio State</a></li>
                </ul>
            </div>
        </div>
    </xsl:template>
    <!-- This is a named template to be an easy way to override to add something to the buildHead -->
    <xsl:template name="extraHead-top"></xsl:template>
    <xsl:template name="extraHead-bottom"></xsl:template>
    <xsl:template name="extraBody-end"></xsl:template>


    <!-- Peter's RSS code for options box -->
    <xsl:template name="addRSSLinks">
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <li><a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>

                    <xsl:choose>
                        <xsl:when test="contains(., 'rss_1.0')"><img src="/dspace/static/icons/feed.png" alt="Icon for RSS 1.0 feed" />RSS 1.0</xsl:when>
                        <xsl:when test="contains(., 'rss_2.0')"><img src="/dspace/static/icons/feed.png" alt="Icon for RSS 2.0 feed" />RSS 2.0</xsl:when>
                        <xsl:when test="contains(., 'atom_1.0')"><img src="/dspace/static/icons/feed.png" alt="Icon for Atom feed" />Atom</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@qualifier"/>
                        </xsl:otherwise>
                    </xsl:choose>
            </a></li>
        </xsl:for-each>
    </xsl:template>


    <!-- bds: this adds "Please use this URL to cite.." to "Show full item" link section
    copied from structural.xsl, with a more specific match pattern added -->
    <xsl:template match="dri:p[@rend='item-view-toggle item-view-toggle-top']">
        <div class="notice">
            <p>
                Please use this identifier to cite or link to this item:
                <!-- bds: first get the METS URL where we can find the item metadata -->
                <xsl:variable name="metsURL">
                    <xsl:text>cocoon:/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:body/dri:div/dri:referenceSet/dri:reference[@type='DSpace Item']/@url"/>
                    <xsl:text>?sections=dmdSec</xsl:text>
                </xsl:variable>
                <!-- bds: now grab the specific piece of metadata from that METS document -->
                <xsl:variable name="handleURI" select="document($metsURL)/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='identifier'][@qualifier='uri']"/>
                <a href="{$handleURI}">
                    <xsl:value-of select="$handleURI"/>
                </a>
            </p>
        </div>
        <p>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-paragraph</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </p>
    </xsl:template>




<!-- bds: needed this replace-string to do some character escaping -->
<!-- from http://www.dpawson.co.uk/xsl/sect2/replace.html#d8763e61 -->
  <xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<!-- bds: remove search box from community/collection pages -->
<xsl:template match="dri:div[@id='aspect.artifactbrowser.CollectionSearch.div.collection-search'] | dri:div[@id='aspect.artifactbrowser.CommunitySearch.div.community-search']">
</xsl:template>

<!-- bds: recent submissions box -->
<!-- adding the 'View all' link -->
<xsl:template match="dri:div[@n='collection-recent-submission'] | dri:div[@n='community-recent-submission']">
    <xsl:apply-templates select="./dri:head"/>
    <ul class="ds-artifact-list">
        <xsl:apply-templates select="./dri:referenceSet" mode="summaryList"/>
    </ul>
    <div id="more-link">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="/dri:document/dri:body/dri:div/dri:div/dri:div/dri:list/dri:item[3]/dri:xref/@target"/>
            </xsl:attribute>
            <xsl:text>View all submissions ></xsl:text>
        </a>
    </div>
</xsl:template>

    <!-- Overrides GeneralHandler
        bds: this template completely replaces original to display CC-license info, logo, with links, and to NOT display other licenses -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
        <div class="license-info">
            <xsl:if test="@USE='CC-LICENSE'">
                <!-- bds: get ccLink from METS dmdSec -->
                <!-- note that this depends on a mod to dspace-xmlui/dspace-xmlui-api/src/main/java/org/dspace/app/xmlui/objectmanager/ItemAdapter.java
                see https://libdws1.it.ohio-state.edu/git/kb/kb-source/commit/f2450cf33a4180b9852bdc48e04d14de39ec9148
                -->
                <xsl:variable name="CC_license_URL" select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@mdschema='ccLink']" />

                <p>This item is licensed under a <a href="{$CC_license_URL}">Creative Commons License</a></p>
                <p><a href="{$CC_license_URL}"><img src="{$context-path}/static/images/cc-somerights.gif" border="0" alt="Creative Commons" /></a></p>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- Overrides General-Handler
    bds: make thumbnails point to bitstreams instead of item records
this template completely replaces the original, found below-->
    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <!-- first, see if any thumbnails exist -->
        <xsl:if test="mets:fileGrp[@USE='THUMBNAIL']">

            <!-- bds:
        Getting GROUPID by prefixing 'group_' to the primary FILEID. This works because
        if no primary exists, variable would just contain 'group_', which wont match any
        thumbnail, so would default to the 'otherwise' condition below.

        This is based on the assumption that this is indeed how the GROUPID variable is formed.
        The other possibility would be to:
            - get the primary FILEID from the structMap section
            - match that FILEID in the fileGrp/CONTENT bundle to a GROUPID
            - then see if that GROUPID has a thumbnail in fileGrp/THUMBNAIL bundle
        But so far it looks like just prefixing 'group_' works.

        If primary bitstream has no thumbnail, or if there is no primary bitstream set,
        then the first available thumbnail would be chosen.
            -->
            <xsl:variable name="primary_FILEID">group_<xsl:value-of select="/mets:METS/mets:structMap/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID" /></xsl:variable>
            <xsl:variable name="GROUPID">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=$primary_FILEID]">
                        <xsl:value-of select="$primary_FILEID" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <div class="artifact-preview">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=$GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                    </xsl:attribute>
                    <img>
                        <xsl:attribute name="alt">
                            <xsl:text>Thumbnail of </xsl:text>
                            <xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='title']"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=$GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                        </xsl:attribute>
                    </img>
                </a>
            </div>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
