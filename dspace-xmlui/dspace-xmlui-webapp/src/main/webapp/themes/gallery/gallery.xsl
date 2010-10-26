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
    
    <!-- Things that need to be passed in to javascript from the config -->
    <xsl:template name="extraHead">
        <script type="text/javascript">
                var ZOOMABLE_IMG_WIDTH = <xsl:value-of select="$config-zoomPanelWidth" />;
                var MAX_SERVICE_IMG_SIZE = <xsl:value-of select="$config-maxServiceImageSize" />;
                var themepath = "<xsl:value-of select="$themePath" />";
        </script>
    </xsl:template>
	

	<!-- 
        From: DIM-Handler.xsl
        
        Changes:
                1. reversed position of thumbnail and metadata
       
       Original comments:       
            An item rendered in the summaryList pattern. Commonly encountered in various browse-by pages
            and search results. 
    -->
	<xsl:template name="itemSummaryList-DIM">

		<!-- Generate the thunbnail, if present, from the file section -->
		<xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"/>

		<!-- Generate the info about the item from the metadata section -->
		<xsl:apply-templates
			select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
			mode="itemSummaryList-DIM"/>
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
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="//mets:fileGrp[@USE='THUMBNAIL']">
				<div class="artifact-preview">
					<xsl:variable name="thumbnailUrl"
						select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
					
					<img alt="Thumbnail" class="thumbnail">
						<xsl:attribute name="src">
							<!-- TODO PMBMD - CHANGE BACK TO THUMBNAIL once larger 200px x 200px thumbnails are being generated -->
                                                        <xsl:value-of
								select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']/mets:FLocat[@LOCTYPE='URL']/@xlink:href"
							/>
						</xsl:attribute>
					</img>
				</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="artifact-preview">
						<img alt="Thumbnail" class="thumbnail">
							<xsl:attribute name="src">
								<xsl:value-of select="$themePath"/>
								<xsl:text>lib/nothumbnail.png</xsl:text>
							</xsl:attribute>
						</img>
					</div>
					
				</xsl:otherwise>
			</xsl:choose></a>
		
		
		<!-- item title -->
		<p class="ds-artifact-title">
			<xsl:variable name="artifactTitle">
				<xsl:value-of select="dim:field[@element='title'][1]/node()"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="dim:field[@element='title']">
					<xsl:choose>
						<xsl:when test="string-length($artifactTitle) >= 30">
							<xsl:value-of select="substring($artifactTitle,1,30)"/>... </xsl:when>
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
					
		
		<!-- Fancy box link on image -->
		<a>
			<xsl:attribute name="id">
				<xsl:text>anchor</xsl:text>
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>
			Show Details</a>

		<!-- FancyBox popup content-->
		<div style="display:none">
			<xsl:attribute name="id">
				<xsl:value-of select="$itemid"/>
			</xsl:attribute>

			<!-- title -->
			<h3 class="detail-title">
				<xsl:choose>
					<xsl:when test="dim:field[@element='title']">
						<xsl:value-of select="dim:field[@element='title'][1]/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</h3>

			<!-- author -->
			<p class="detail-author">
				<!-- thumbnail is a link-->
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
                                                                <!-- TODO CHANGE BACK TO THUMBNAIL -->
								<xsl:variable name="thumbnailUrl"
									select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg']/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
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

				<strong>Author:</strong>
				<xsl:choose>
					<xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
						<xsl:for-each
							select="dim:field[@element='contributor'][@qualifier='author']">
							<xsl:copy-of select="./node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="dim:field[@element='creator']">
						<xsl:for-each select="dim:field[@element='creator']">
							<xsl:copy-of select="node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='creator']) != 0">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="dim:field[@element='contributor']">
						<xsl:for-each select="dim:field[@element='contributor']">
							<xsl:copy-of select="node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='contributor']) != 0">
								<xsl:text>; </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</p>

			<p class="detail-date">
				<strong>Publication date:</strong>
				<xsl:if test="dim:field[@element='publisher']">
					<span class="publisher">
						<xsl:copy-of select="dim:field[@element='publisher']/node()"/>
					</span>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<span class="date">
					<xsl:value-of
						select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"
					/>
				</span>
			</p>

			<p class="detail-desc">
				<strong>Description:</strong>
				<xsl:if test="dim:field[@element='description']">
					<span class="description">
						<xsl:copy-of
							select="dim:field[@element='description'][not(@qualifier)]/node()"/>
					</span>
					<xsl:text>, </xsl:text>
				</xsl:if>
			</p>
			
			<p class="detail-link"><a  href="{ancestor::mets:METS/@OBJID}">Go To Image</a></p>

		</div>

	</xsl:template>

	<!-- 
        From structural.xsl
        
        Changes:
             1. Added a 'clearing' element 
        
        Summarylist case.  This template used to apply templates to the "pioneer" object (the first object
        in the set) and let it figure out what to do. This is no longer the case, as everything has been 
        moved to the list model. A special theme, called TableTheme, has beeen created for the purpose of 
        preserving the pioneer model. -->
	<xsl:template match="dri:referenceSet[@type = 'summaryList']" priority="2">
		<xsl:apply-templates select="dri:head"/>
		<!-- Here we decide whether we have a hierarchical list or a flat one -->
		<xsl:choose>
			<xsl:when
				test="descendant-or-self::dri:referenceSet/@rend='hierarchy' or ancestor::dri:referenceSet/@rend='hierarchy'">
				<ul>
					<xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
				</ul>
			</xsl:when>
			<xsl:otherwise>

				<ul class="ds-artifact-list">
					<xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
				</ul>

				<!-- 1. important: need to clear after floating list-->
				<div style="clear:both;">
					<p> </p>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
        From: structural.xsl
        
        Changes:
              1. modified to not use HTML list item: <li>
        
        Then we resolve the reference tag to an external mets object -->
	<xsl:template match="dri:reference" mode="summaryList">

		<xsl:variable name="externalMetadataURL">
			<xsl:text>cocoon:/</xsl:text>
			<xsl:value-of select="@url"/>
			<!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
			<xsl:text>?sections=dmdSec,fileSec</xsl:text>
			<!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
                <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
                </xsl:if>-->
		</xsl:variable>
		<xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/>
		</xsl:comment>
		<li>
			<xsl:attribute name="class">
				<xsl:text>ds-artifact-item </xsl:text>
				<xsl:choose>
					<xsl:when test="position() mod 2 = 0">even</xsl:when>
					<xsl:otherwise>odd</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
			<xsl:apply-templates/>
		</li>
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

<!-- COOL HACKS TO EMBED GOOGLE DOCS PREVIEWER -->
<!-- Generate the bitstream information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>

        <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
        <table class="ds-table file-list">
            <tr class="ds-table-header-row">
                <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                <!-- Display header for 'Description' only if at least one bitstream contains a description -->
                <xsl:if test="mets:file/mets:FLocat/@xlink:label != ''">
                    <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text></th>
                </xsl:if>
            </tr>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />
                        <xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Add the document previewer window -->
            <tr>
                <td colspan='5'>
                    <a name="preview"></a>
                    <div id="preview-embed"/>
                </td>
            </tr>
        </table>
    </xsl:template>

<!-- Build a single row in the bitsreams table of the item view page -->
    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title) > 50">
                            <xsl:variable name="title_length" select="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title)"/>
                            <xsl:value-of select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,1,15)"/>
                            <xsl:text> ... </xsl:text>
                            <xsl:value-of select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,$title_length - 25,$title_length)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </td>
            <!-- File size always comes in bytes and thus needs conversion -->
            <td>
                <xsl:choose>
                    <xsl:when test="@SIZE &lt; 1000">
                        <xsl:value-of select="@SIZE"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string(@SIZE div 1000000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- Lookup File Type description in local messages.xml based on MIME Type.
                In the original DSpace, this would get resolved to an application via
                the Bitstream Registry, but we are constrained by the capabilities of METS
                and can't really pass that info through. -->
            <td>
              <xsl:call-template name="getFileTypeDesc">
                <xsl:with-param name="mimetype">
                  <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                  <xsl:text>/</xsl:text>
                  <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                </xsl:with-param>
              </xsl:call-template>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                        <a class="image-link">
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                        mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                        </a> 
                        <xsl:choose>
                            <xsl:when test="@MIMETYPE='application/pdf'">
                                <xsl:text> or </xsl:text>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:text>#preview</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="onclick">
                                        <xsl:text>embeddedPreview("</xsl:text>
                                        <xsl:text>http://docs.google.com/viewer?url=</xsl:text>
                                        <xsl:text>http://kb.osu.edu/dspace/retrieve/</xsl:text>
                                        <xsl:value-of select="substring(@ID,6)"/>
                                        <xsl:text>&amp;embedded=true</xsl:text>
                                        <xsl:text>");</xsl:text>
                                    </xsl:attribute>
                                    Preview
                                </a>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
	    <!-- Display the contents of 'Description' as long as at least one bitstream contains a description -->
	    <xsl:if test="$context/mets:fileSec/mets:fileGrp/mets:file/mets:FLocat/@xlink:label != ''">
	        <td>
	            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
	        </td>
	    </xsl:if>

        </tr>
    </xsl:template>






</xsl:stylesheet>
