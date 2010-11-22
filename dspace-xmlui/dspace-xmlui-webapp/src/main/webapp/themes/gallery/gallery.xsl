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





	<!-- 
        From: structural.xsl
        Changes:  
                1. Added $themePath variable in a number of places  to reduce number of lookups ovia XPath
                2. Added JS libraries : JQuery, AnythingZoomer, FancyBox
    -->
	<xsl:template name="buildHead">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
			
			<!-- pass through some config values to Javascript -->
			<script type="text/javascript">
				var ZOOMABLE_IMG_WIDTH = <xsl:value-of select="$config-zoomPanelWidth" />;
				var MAX_SERVICE_IMG_SIZE = <xsl:value-of select="$config-maxServiceImageSize" />;
			</script>
	
        <!--bds: Add OSU navbar header and stylesheets -->
        <!-- bds: see OSU-local.xsl for buildHeadOSU -->
            <xsl:call-template name="buildHeadOSU"/>
            <!-- Add global theme(s) -->
            <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href">
                    <xsl:value-of select="$context-path"/>
                    <xsl:text>/static/css/osukb_base.css</xsl:text>
                </xsl:attribute>
            </link>

                      
			<!-- Add stylsheets -->
			<xsl:for-each
				select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
				<link rel="stylesheet" type="text/css">
					<xsl:attribute name="media">
						<xsl:value-of select="@qualifier"/>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$themePath"/>
						<xsl:value-of select="."/>
					</xsl:attribute>
				</link>
			</xsl:for-each>

			<!-- Add syndication feeds -->
			<xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
				<link rel="alternate" type="application">
					<xsl:attribute name="type">
						<xsl:text>application/</xsl:text>
						<xsl:value-of select="@qualifier"/>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</link>
			</xsl:for-each>

			<!-- JQuery JS
                    bds: removing this because it may be conflicting with jQ 1.4.4
			<script type="text/javascript">
				<xsl:attribute name="src">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/jquery-1.3.2.min.js</xsl:text>
				</xsl:attribute> &#160; </script>
-->
			<!-- the following javascript removes the default text of empty text areas when they are focused on or submitted -->
			<script type="text/javascript"> function tFocus(element){if (element.value ==
				'<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}}
				function tSubmit(form){var defaultedElements =
				document.getElementsByTagName("textarea"); for (var i=0; i !=
				defaultedElements.length; i++){ if (defaultedElements[i].value ==
				'<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
				defaultedElements[i].value='';}}} </script>

			<!-- Add javascript  -->
			<xsl:for-each
				select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript']">
				<script type="text/javascript">
					<xsl:attribute name="src">
						<xsl:value-of select="$themePath"/>
						<xsl:value-of select="."/>
					</xsl:attribute>.</script>
			</xsl:for-each>
			<!-- Add the title in -->
			<xsl:variable name="page_title"
				select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']"/>

			<!-- Add  Gallery JS and CSS  -->
			<link rel="stylesheet" type="text/css">
				<xsl:attribute name="href">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/gallery.css</xsl:text>
				</xsl:attribute>
			</link>
			
			<script type="text/javascript">
				<xsl:attribute name="src">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/gallery.js</xsl:text>
				</xsl:attribute> &#160; </script>

			<!-- Add Fancy Box JS and CSS -->
                        <!-- bds: ditch the fancy-box 
			<link rel="stylesheet" type="text/css">
				<xsl:attribute name="href">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/fancybox/jquery.fancybox-1.2.5.css</xsl:text>
				</xsl:attribute>
			</link>

			<script type="text/javascript">
				<xsl:attribute name="src">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/fancybox/jquery.fancybox-1.2.5.js</xsl:text>
				</xsl:attribute> &#160; </script>
			-->

			<!--Add TJPzoom library   -->
			<script type="text/javascript">
				<xsl:attribute name="src">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/tjpzoom/tjpzoom.js</xsl:text>
				</xsl:attribute>&#160; </script>
			
			<script type="text/javascript">
				<xsl:attribute name="src">
					<xsl:value-of select="$themePath"/>
					<xsl:text>lib/tjpzoom/tjpzoom_config_default.js</xsl:text>
				</xsl:attribute>&#160; </script>
		
			<title>
				<xsl:choose>
					<xsl:when test="not($page_title)">
						<xsl:text>  </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$page_title/node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
		</head>
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
		<p class="ds-artifact-title">
			<xsl:variable name="artifactTitle">
				<xsl:value-of select="dim:field[@element='title'][1]/node()"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="dim:field[@element='title']">
					<xsl:choose>
                                            <!-- bds: lowered this to 26 because sometimes was wide enough at 30 to wrap the Show Details link below the thumbnail box -->
						<xsl:when test="string-length($artifactTitle) >= 26">
							<xsl:value-of select="substring($artifactTitle,1,26)"/>... </xsl:when>
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
		</p>
					

		<a>
                    <!-- bds: adding a class to the details link so it can be styled independtly -->
                        <xsl:attribute name="class">
                            <xsl:text>fancy-box-link</xsl:text>
                        </xsl:attribute>
			<xsl:attribute name="id">
				<xsl:text>anchor</xsl:text>
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>
<!--			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>-->
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
                        <xsl:attribute name="title">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:attribute>
			Show Details</a>


		<!-- FancyBox popup content-->
<!--		<div style="display:none">
			<xsl:attribute name="id">
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>

 bds: trying out using structures from simple_item_fields.xsl to insert fields to popup 

<xsl:element name="a">
    <xsl:attribute name="href">
        <xsl:choose>
            <xsl:when test="$itemWithdrawn">
                <xsl:value-of select="ancestor::mets:METS/@OBJEDIT"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ancestor::mets:METS/@OBJID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:attribute>

    <xsl:choose>
        <xsl:when test="//mets:fileGrp[@USE='THUMBNAIL']">
            <xsl:variable name="thumbnailUrl"
select="//mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            <img alt="Thumbnail"  class="detail" align="right">
                <xsl:attribute name="src">
                    <xsl:value-of
                        select="$thumbnailUrl"
                        />
                </xsl:attribute>
            </img>
        </xsl:when>
        <xsl:otherwise>
            <img alt="Thumbnail" class="detail" align="right">
                <xsl:attribute name="src">
                    <xsl:value-of select="$themePath"/>
                    <xsl:text>lib/nothumbnail.png</xsl:text>
                </xsl:attribute>
            </img>
        </xsl:otherwise>
    </xsl:choose>

</xsl:element>



<table>
    <tr class="ds-table-row">
        <td class="field-label"><span class="bold"><i18n:text>metadata.dc.title</i18n:text>: </span></td>
        <td class="field-data">
             bds: removing COinS for now 
                <span class="Z3988">
<xsl:attribute name="title">
<xsl:call-template name="renderCOinS"/>
</xsl:attribute>
            <xsl:choose>
                <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                    <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                        <xsl:value-of select="./node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                            <xsl:text>; </xsl:text><br/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
                            </span>
        </td>
    </tr>


    <xsl:if test="dim:field[@element='creator' and not(@qualifier)]">
        <tr class="ds-table-row">
            <td class="field-label"><span class="bold"><i18n:text>metadata.dc.creator</i18n:text>:</span></td>
            <td class="field-data">
                <xsl:for-each select="dim:field[@element='creator' and not(@qualifier)]">
                     bds: link to author browse magic 
                    <a>

                        <xsl:attribute name="href">
                            <xsl:value-of select="$context-path"/>
                            <xsl:text>/browse?value=</xsl:text>
                            <xsl:value-of select="node()"/>
                            <xsl:text>&amp;type=author</xsl:text>
                        </xsl:attribute>
                        <xsl:copy-of select="node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='creator' and not(@qualifier)]) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:if>


    <xsl:if test="dim:field[@element='description' and not(@qualifier)]">
        <tr class="ds-table-row">
            <td class="field-label"><span class="bold"><i18n:text>metadata.dc.description</i18n:text>:</span></td>
            <td class="field-data">
                <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                     bds: this if clause specifically for Ukrainian, to block TGN line from appearing 
                    <xsl:if test="not(contains(node(),'TGN'))">
                    <span>
<xsl:call-template name="parseurls">
	    <xsl:with-param name="text" select="node()"/>
	  </xsl:call-template>
                    </span>
                    <br />
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:if>
</table>




			<p class="detail-link"><a  href="{ancestor::mets:METS/@OBJID}">View full image and item record</a></p>

		</div>-->

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
			imageJpegArray.push(o);
		</xsl:for-each>
		</script>

		<!-- TJPZoom: the zoomable image  viewer -->
		<div id="image-zoom-panel">
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
