<?xml version="1.0" encoding="UTF-8"?>

<!--
    Gallery.xsl

    Implements an image gallery view for Manakin. See the public "About this Theme"
    page for instructions on use and credits.

-->


<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="../dri2xhtml.xsl"/>
	<xsl:import href="config.xsl"/>
	<xsl:output indent="yes"/>

	<!-- THEME CONFIGURATION OPTIONS -->

	<!-- using these 2 options, you can restrict navigation to this collection,
    removing links to outside colelctions, communities, etc -->

	<!--  THEME VARIABLES -->
<!-- bds: todo: check usage and redundancy of these variables -->

	<!-- the URL of this theme, used to make building paths to referenced files easier -->
	<xsl:variable name="themePath">
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
		<xsl:text>/themes/</xsl:text>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
		<xsl:text>/</xsl:text>
	</xsl:variable>

	<!-- serverUrl: path to the  server, up through the port -->
	<xsl:variable name="serverUrl">
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
		<xsl:text>://</xsl:text>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"
		/>
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

	<xsl:variable name="counter">
		<xsl:value-of select="1"/>
	</xsl:variable>






        <xsl:template name="extraHead-top">
            <!-- pass through some config values to Javascript -->
            <script type="text/javascript">
                    var ZOOMABLE_IMG_WIDTH = <xsl:value-of select="$config-zoomPanelWidth" />;
                    var MAX_SERVICE_IMG_SIZE = <xsl:value-of select="$config-maxServiceImageSize" />;
                    var THEME_PATH = "<xsl:value-of select='$themePath' />";
            </script>

        </xsl:template>



	<!--
        From: General-Handler.xsl

        Changes:
         	1. moved thumbnail to another rule

        Generate the thunbnail, if present, from the file section -->
	<xsl:template match="mets:fileSec" mode="artifact-preview">
		<!--
			Thumbnail moved to another rule
		<xsl:if test="mets:fileGrp[@USE='THUMBNAIL']">
			<div class="artifact-preview">
				<xsl:variable name="thumbnailUrl"
					select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
				<a href="{ancestor::mets:METS/@OBJID}">
					<img alt="Thumbnail" class="thumbnail">
						<xsl:attribute name="src">
							<xsl:value-of
								select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"
							/>
						</xsl:attribute>
					</img>
				</a>
			</div>
		</xsl:if>
		-->
	</xsl:template>

	<!--
        From DIM-Handler.xsl
        Changes:
                1. rewrote/reordered to use the Fancybox JQuery library

        Generate the info about the item from the metadata section
    -->
	<xsl:template match="dim:dim" mode="itemSummaryList-DIM">
		<xsl:variable name="itemWithdrawn" select="@withdrawn"/>

		<!-- generate an id and use it for the JS popups -->
		<xsl:variable name="itemid" select="generate-id(node())"/>

		<script type="text/javascript"> itemids.push("<xsl:value-of select="$itemid"/>"); </script>

		<!-- FancyBox link on image: opens popup -->
                <a>
                    <xsl:attribute name="id">
                        <xsl:text>image</xsl:text>
                        <xsl:value-of select="$itemid"/>
                    </xsl:attribute>
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
                    <xsl:choose>
                        <xsl:when test="//mets:fileGrp[@USE='THUMBNAIL']">
                            <div class="artifact-preview">
                                <xsl:variable name="thumbnailUrl"
                                              select="//mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>

                                <img class="thumbnail">
                                    <!-- bds: title attribute gives mouse-over -->
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="src">
                                        <xsl:value-of
                                            select="//mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"
                                            />
                                    </xsl:attribute>
                                </img>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="artifact-preview">
                                <img class="thumbnail">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$themePath"/>
                                        <xsl:text>lib/nothumbnail.png</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </div>

                        </xsl:otherwise>
                    </xsl:choose>
                </a>


		<!-- item title -->
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
                            <!--<xsl:value-of select="dim:field[@element='title'][1]/node()"/>-->
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>

                <!-- bds: add issue date or submit date depending on the type of browse that is happening -->
                <xsl:choose>
                    <xsl:when test="$browseMode = 'xmlui.ArtifactBrowser.ConfigurableBrowse.title.item.dateaccessioned'">
                            <span class="publisher-date">
                                <xsl:text>(submitted </xsl:text>
                                <span class="date">
                                    <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='accessioned']/node(),1,10)"/>
                                </span>
                                <xsl:text>)</xsl:text>
                            </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
                                <span class="publisher-date">
                                    <xsl:text>(</xsl:text>
                                    <span class="date">
                                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                                    </span>
                                    <xsl:text>)</xsl:text>
                                </span>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
	</xsl:template>





	<!--
        From: DIM-Handler.xsl

        Changes:
            1. add in -line image viewing
            2. reordered elements

        An item rendered in the summaryView pattern. This is the default way to view a DSpace item in Manakin. -->

	<xsl:template name="itemSummaryView-DIM">

		<script type="text/javascript">
			var o;
		<xsl:for-each select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']">
			o = new Object();
			o.url = "<xsl:value-of select="mets:FLocat/@xlink:href"/>";
			o.size = <xsl:value-of select="./@SIZE"/>;
			o.title = "<xsl:value-of select="mets:FLocat/@xlink:title"/>";
                        o.caption = "<xsl:value-of select="//dim:field[@element='description'][@qualifier='abstract']" />";
                        o.itemTitle = "<xsl:value-of select="//dim:field[@element='title']" />";

			imageJpegArray.push(o);
		</xsl:for-each>
		</script>

		<!-- TJPZoom: the zoomable image  viewer -->
		<div id="photos">
			<!-- Moved this into Javascript: see gallery.js
				left this here just in case issues were found and needed to revert -->
			<!--
				<img alt="zoomable image" onmouseover="TJPzoom(this);" width="500">
				<xsl:attribute name="src">
				<xsl:value-of select="$serviceImageUrl"/>
				</xsl:attribute>
				</img>
			-->
			&#160;
		</div>

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





<!-- bds: creating new template akin to those in structural.xsl, removing Recent Submissions box
    <xsl:template match="dri:div[@n='community-recent-submission']|dri:div[@n='collection-recent-submission']" priority="3">
        <div>
            <h1>Success! No recent submissions box! (But now what to put here?)</h1>
        </div>
    </xsl:template>-->



</xsl:stylesheet>
