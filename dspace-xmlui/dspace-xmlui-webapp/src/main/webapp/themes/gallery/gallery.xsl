<?xml version="1.0" encoding="UTF-8"?>

<!--
    Gallery.xsl

    Implements an image gallery view for Manakin.
-->


<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="../dri2xhtml.xsl"/>
	<xsl:output indent="yes"/>


	<!--  THEME VARIABLES -->
    <!-- bds: todo: check usage and redundancy of these variables -->

	<!-- the URL of this theme, used to make building paths to referenced files easier -->
	<xsl:variable name="themePath">
		<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
		<xsl:text>/themes/gallery/</xsl:text>
	</xsl:variable>

	<!-- serverUrl: path to the  server, up through the port -->
	<xsl:variable name="serverUrl">
		<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
		<xsl:text>://</xsl:text>
		<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
	</xsl:variable>

	<!-- apgeUrl: path to the  server, up through the port -->
	<xsl:variable name="pageUrl">
		<xsl:value-of select="$serverUrl"/>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"
		/>
	</xsl:variable>
    
    <!-- imageTitle: provide a title for the alt tag on the large image for accessability -->
    <xsl:variable name="imageTitle">
        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']"/>
    </xsl:variable>
    
	<xsl:variable name="counter">
		<xsl:value-of select="1"/>
	</xsl:variable>

    <xsl:template name="extraHead-top">
        <!-- pass through some config values to Javascript -->
        <script type="text/javascript">
            var THEME_PATH = "<xsl:value-of select='$themePath' />";
            var IMAGE_TITLE = "<xsl:value-of select="translate($imageTitle,'&#34;','')"/>";
        </script>

    </xsl:template>

	<!--
        From: General-Handler.xsl
        Blanking out default action.
        -->
	<xsl:template match="mets:fileSec" mode="artifact-preview"></xsl:template>

	<!--
        From DIM-Handler.xsl
        Changes:
                1. rewrote/reordered to use the Fancybox JQuery library
                2. Removed FancyBox for browselist.

        Generate the info about the item from the metadata section
    -->
	<xsl:template match="dim:dim" mode="itemSummaryList-DIM">
		<xsl:variable name="itemWithdrawn" select="@withdrawn"/>
        <!--
            A -> ItemPage
                DIV#artifact-preview
                    IMG.thumbnail title=TITLE, alt=Thumbnail of TITLE src=THUMBNAIL
        -->
        <a>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$itemWithdrawn">
                        <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <div class="artifact-preview">
                <img class="thumbnail">
                    <!-- bds: title attribute gives mouse-over -->
                    <xsl:attribute name="title">
                        <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                    </xsl:attribute>
                    <xsl:attribute name="alt">
                        <xsl:text>Thumbnail of </xsl:text>
                        <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="//mets:fileGrp[@USE='THUMBNAIL']">
                            <xsl:attribute name="src">
                                <xsl:value-of select="//mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="src">
                                <xsl:value-of select="$themePath"/>
                                <xsl:text>lib/nothumbnail.png</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </img>
            </div>
        </a>


        <!-- item title -->
        <!--
            A.fancy-box-link title=TITLE   ->ITEM
                text(TITLE)
            SPAN.publisher-date
                (
                SPAN.date    text(DATE)
                )
        -->
        <a>
            <xsl:variable name="artifactTitle">
                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
            </xsl:variable>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$itemWithdrawn">
                        <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>fancy-box-link</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="dim:field[@element='title']">
                    <xsl:choose>
                        <xsl:when test="string-length($artifactTitle) >= 40">
                            <xsl:value-of select="substring($artifactTitle,1,40)"/>... </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$artifactTitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
        </a>

        <!-- bds: add issue date or submit date depending on the type of browse that is happening -->
        <span class="metadata-date">
            <xsl:choose>
                <xsl:when test="$browseMode = '3'">
                    <xsl:text>(accessioned </xsl:text>
                    <span class="dateAccepted">
                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='accessioned']/node(),1,10)"/>
                    </span>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
                        <xsl:text>(</xsl:text>
                        <span class="issued">
                            <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                        </span>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </span>
	</xsl:template>





	<!--
        From: DIM-Handler.xsl

        Changes:
            1. add in -line image viewing
            2. reordered elements

        An item rendered in the summaryView pattern. This is the default way to view a DSpace item in Manakin. -->

	<xsl:template name="itemSummaryView-DIM">
        <xsl:if test="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']">
            <script type="text/javascript">
                <xsl:for-each select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']">
                    var o = new Object();
                    o.url = "<xsl:value-of select="mets:FLocat/@xlink:href"/>";
                    o.size = <xsl:value-of select="./@SIZE"/>;
                    <!-- Replace double quotes and single quotes with corresponding entities, otherwise Javascript breaks.-->
                    <xsl:variable name="encodedTitle"><!-- 'title' is what METS calls the bitstream file name -->
                        <xsl:call-template name="encode-quotes">
                            <xsl:with-param name="stringToFix" select="mets:FLocat/@xlink:title"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="encodedCaption"><!-- dc.description.abstract -->
                        <xsl:call-template name="encode-quotes">
                            <xsl:with-param name="stringToFix" select="//dim:field[@element='description'][@qualifier='abstract']"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="encodedItemTitle"><!-- dc.title -->
                        <xsl:call-template name="encode-quotes">
                            <xsl:with-param name="stringToFix" select="//dim:field[@element='title']"/>
                        </xsl:call-template>
                    </xsl:variable>

                    o.title = "<xsl:value-of select="$encodedTitle"/>";
                    o.caption = "<xsl:value-of select="$encodedCaption"/>";
                    o.itemTitle = "<xsl:value-of select="$encodedItemTitle"/>";

                    imageJpegArray.push(o);
                </xsl:for-each>
            </script>

            <!-- Photos Div. JavaScript is required to load the images. -->
            <div id="photos">&#160;</div>
        </xsl:if>


		<!-- Generate the info about the item from the metadata section -->
		<xsl:apply-templates
			select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
			mode="itemSummaryView-DIM"/>

		<!-- Generate the bitstream information from the file section -->
		<xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']">
			<xsl:with-param name="context" select="."/>
			<xsl:with-param name="primaryBitream"
				select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"
			/>
		</xsl:apply-templates>

		<!-- Generate the license information from the file section -->
		<xsl:apply-templates
			select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']"/>
	</xsl:template>
  
      <xsl:template name="encode-quotes">
        <xsl:param name="stringToFix"/>
        <xsl:variable name="singleQuotesFixed">
            <xsl:call-template name="replace-string"><!-- is in OSU-local.xsl -->
                <xsl:with-param name="text" select="$stringToFix"/>
                <xsl:with-param name="replace" select="&quot;&apos;&quot;"/>
                <xsl:with-param name="with" select="'&amp;apos;'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="replace-string">
            <xsl:with-param name="text" select="$singleQuotesFixed"/>
            <xsl:with-param name="replace" select="'&quot;'"/>
            <xsl:with-param name="with" select="'&amp;quot;'"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>
