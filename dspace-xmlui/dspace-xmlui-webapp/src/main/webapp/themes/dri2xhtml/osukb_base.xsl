<?xml version="1.0" encoding="UTF-8"?>

<!-- bds: todo: replace this legal statement with proper OSU boilerplating -->

<!--
  osukb_base.xsl

  Version: $Revision: 4098 $

  Date: $Date: 2009-07-21 22:09:29 -0400 (Tue, 21 Jul 2009) $

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
    Author: Peter Dietz
    Description: This stylesheet contains templates to override dspace ways of
                page layout and adds features as needed by OSU KB.
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

    <!-- bds: global variable base-url allows references to docs contained within KB

    Not used for generating links that will appear on pages, but rather for grabbing
    data not in the DRI but available on the localhost. In the CC-license case,
    used to fetch CC-license RDF info, from which the link to creativecommons.org is found.
    (see @USE='CC-LICENSE' later in this document)

Update 4/30/10: currently this isn't being used, because the CC-license info is now being
grabbed via a cocoon:/ link, but that linkage depends on the fixed-length of the
word "dspace" at the beginning of CC-license URLs in the METS item doc. (see CC-license section)
Generally cocoon:/ is a better way to reference items than this.

    <xsl:variable name="base-url" select="'http://localhost:8080'"/>

if localhost dosen't work, can return to this:
concat(
dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme'],'://',
dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName'],':',
dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']
)"/>
-->


<!-- Peter: from structural.xsl to add osukb_base.css -->
<!-- 2010-05-04 - PMBMD - Inserted dri:document and call buildBodyOSU -->
<!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">
        <html>
            <!-- First of all, build the HTML head element -->
            <xsl:call-template name="buildHead"/>
            <!-- Then proceed to the body -->
            <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                    <xsl:apply-templates select="dri:body/*"/>
                    <!-- add setup JS code if this is a choices lookup page -->
                    <xsl:if test="dri:body/dri:div[@n='lookup']">
                        <xsl:call-template name="choiceLookupPopUpSetup"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <body>
                        <xsl:call-template name="buildBodyOSU"/>
                        <div id="ds-main">
                            <!--
                        The header div, complete with title, subtitle, trail and other junk. The trail is
                        built by applying a template over pageMeta's trail children. -->
                            <xsl:call-template name="buildHeader"/>

                            <!--
                        Goes over the document tag's children elements: body, options, meta. The body template
                        generates the ds-body div that contains all the content. The options template generates
                        the ds-options div that contains the navigation and action options available to the
                        user. The meta element is ignored since its contents are not processed directly, but
                        instead referenced from the different points in the document. -->
                            <xsl:apply-templates />

                            <!--
                        The footer div, dropping whatever extra information is needed on the page. It will
                        most likely be something similar in structure to the currently given example. -->
                            <xsl:call-template name="buildFooter"/>

                        </div>
                    </body>
                </xsl:otherwise>
            </xsl:choose>
        </html>
    </xsl:template>




    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
        information is either user-provided bits of post-processing (as in the case of the JavaScript), or
        references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>

            <xsl:call-template name="buildHeadOSU"/>
            <!-- Add global theme(s) -->
            <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/static/css/osukb_base.css</xsl:text>
                </xsl:attribute>
            </link>

            <!-- Add stylesheets -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
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

            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='context']"/>
                        <xsl:text>description.xml</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script type="text/javascript">
                //Clear default text of emty text areas on focus
                function tFocus(element)
                {
                if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of emty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode;     //Internet Explorer
                else
                key = e.which;     //Firefox and Netscape

                if(key == 13)  //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }
            </script>

            <xsl:call-template name="extraHead"/>

            <!-- Add theme javascipt  -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
            </xsl:for-each>

            <!-- add "shared" javascript from static, path is relative to webapp root-->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
            </xsl:for-each>


            <!-- Add a google analytics script if the key is present -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
                <script type="text/javascript">
                    <xsl:text>var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");</xsl:text>
                    <xsl:text>document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));</xsl:text>
                </script>

                <script type="text/javascript">
                    <xsl:text>try {</xsl:text>
                    <xsl:text>var pageTracker = _gat._getTracker("</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>");</xsl:text>
                    <xsl:text>pageTracker._trackPageview();</xsl:text>
                    <xsl:text>} catch(err) {}</xsl:text>
                </script>
            </xsl:if>


            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
            <title>
                <xsl:choose>
                    <xsl:when test="not($page_title)">
                        <xsl:text>  </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>

            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

        </head>
    </xsl:template>




    <!-- from structural.xsl to add RSS links -->
    <!-- bds: added 'partners' section -->
        <!-- (following comments from DSpace people)
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the ds-options div and applying
        the templates inside it.

        In fact, the only bit of real work this template does is add the search box, which has to be
        handled specially in that it is not actually included in the options div, and is instead built
        from metadata available under pageMeta.
    -->
    <!-- TODO: figure out why i18n tags break the go button -->
    <xsl:template match="dri:options">
        <div id="ds-options">
            <h3 id="ds-search-option-head" class="ds-option-set-head"><i18n:text>xmlui.dri2xhtml.structural.search</i18n:text></h3>
            <div id="ds-search-option" class="ds-option-set">
                <!-- The form, complete with a text box and a button, all built from attributes referenced
                    from under pageMeta. -->
                <form id="ds-search-form" method="post">
                    <xsl:attribute name="action">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                    </xsl:attribute>
                    <fieldset>
                        <input class="ds-text-field " type="text">
                            <xsl:attribute name="name">
                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                            </xsl:attribute>
                        </input>
                        <input class="ds-button-field " name="submit" type="submit" i18n:attr="value" value="xmlui.general.go" >
                            <xsl:attribute name="onclick">
                                <xsl:text>
                                    var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                    if (radio != undefined &amp;&amp; radio.checked)
                                    {
                                    var form = document.getElementById(&quot;ds-search-form&quot;);
                                    form.action=
                                </xsl:text>
                                <xsl:text>&quot;</xsl:text>
                                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                <xsl:text>/handle/&quot; + radio.value + &quot;/search&quot; ; </xsl:text>
                                <xsl:text>
                                    }
                                </xsl:text>
                            </xsl:attribute>
                        </input>
                        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
                            <br/>
                            <label>
                                <input id="ds-search-form-scope-all" type="radio" name="scope" value="" checked="checked"/>
                                <i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
                            </label><br/>
                            <label>
                                <input id="ds-search-form-scope-container" type="radio" name="scope">
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
                                    </xsl:attribute>
                                </input>
                                <xsl:choose>
                                    <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </label>
                        </xsl:if>
                    </fieldset>
                </form>
                <!-- The "Advanced search" link, to be perched underneath the search box -->
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='advancedURL']"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.search-advanced</i18n:text>
                </a>
            </div>

            <!-- Once the search box is built, the other parts of the options are added -->
            <xsl:apply-templates />

            <!-- bds: KB partners links -->
            <h3 id="ds-partners-option-head" class="ds-option-set-head">
                <xsl:text>Partners</xsl:text>
            </h3>
            <div id="ds-partners-option" class="ds-option-set">
                <ul>
                    <!--<li><a href="http://library.osu.edu/sites/dlib/kb/projects.html">Digital Initiatives at OSU</a></li>-->
                    <li><a href="http://www.ohiolink.edu">OhioLink</a></li>
                    <li><a href="http://www.ohiolink.edu/etd">OhioLink-ETD Center</a></li>
                    <li><a href="http://library.osu.edu/sites/copyright/">Copyright Help Center</a></li>
                    <li><a href="http://wmc.ohio-state.edu">Web Media Collective</a></li>
                </ul>
            </div>

            <!-- Peter: Add RSS Links to Page -->
            <!-- bds: xsl:if test prevents box from appearing when there aren't any RSS feeds for a page -->
            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']) != 0">
                <h3 id="ds-feed-option-head" class="ds-option-set-head"><xsl:text>RSS Feeds</xsl:text></h3>
                <div id="ds-feed-option" class="ds-option-set">
                    <ul><xsl:call-template name="addRSSLinks"/></ul>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- Peter's RSS code for options box -->

    <xsl:template name="addRSSLinks">
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <li><a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:value-of select="@qualifier"/>
            </a></li>
        </xsl:for-each>
    </xsl:template>





    <!-- bds: from structural.xsl change footer text-->
    <xsl:template name="buildFooter">
        <div id="ds-footer">
            <div id="ds-footer-links">
                <!--      bds: JSPUI didn't have a contact link, so I comment this one out too

                                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/contact</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                </a> -->


                <a target="_blank" href="http://www.dspace.org/">DSpace</a>
                <xsl:text> | </xsl:text>
                <a target="_blank" href="http://library.osu.edu/">University Libraries</a>
                <xsl:text> | </xsl:text>
                <a target="_blank" href="http://cio.osu.edu/">Office of the CIO</a>
                <xsl:text> | </xsl:text>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/feedback</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                </a>
            </div>
        </div>
    </xsl:template>







    <!-- bds: for browse screens, limiting portion beneath title to just
    dc.creator, linkifying, not displaying 'unkown author', removing publisher/date -->
    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="@withdrawn" />
        <div class="artifact-description">
            <div class="artifact-title">
                <xsl:element name="a">
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
                    <!-- bds: no COinS, for now -->
<!--                    <span class="Z3988">
                        <xsl:attribute name="title">
                            <xsl:call-template name="renderCOinS"/>
                        </xsl:attribute>-->
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
<!--                    </span>-->
                </xsl:element>
            </div>
            <div class="artifact-info">
                <span class="author">
                    <xsl:for-each select="dim:field[@element='creator' and not(@qualifier)]">
                        <!-- bds: link to author browse magic -->
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
                    <!-- bds: removing DSpace default concept of 'Author'
                    <xsl:choose>

                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>

                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                     -->
                </span>
                <!-- bds: removing publisher and date, which had some issues anyway
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                    <span class="publisher-date">
                        <xsl:text>(</xsl:text>
                        <xsl:if test="dim:field[@element='publisher']">
                            <span class="publisher">
                                <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                            </span>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <span class="date">
                            <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                        </span>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
                -->
            </div>
        </div>
    </xsl:template>

<!-- bds: from DIM-Handler, removing COinS in item detail view -->
    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
<!--        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
        </span>-->
		<table class="ds-includeSet-table">
		    <xsl:apply-templates mode="itemDetailView-DIM"/>
		</table>
    </xsl:template>


    <!-- bds: from General-Handler.xsl to display CC-license info, logo, with links -->

    <!-- bds: inclusion of @USE='LICENSE' in this section so as to override same
         match in General-Handler.xsl and to prevent anything from displaying
         from the license bundle. -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
        <div class="license-info">
            <xsl:if test="@USE='CC-LICENSE'">
                <!-- bds: get pointer to RDF of CC-license info from METS doc -->
                <xsl:variable name="CC_license_RDF_URL">
                    <xsl:text>cocoon:/</xsl:text>
                    <!-- bds: using substring('foo',string-length($context-path) + 1) to remove "/dspace" from the URL found in the mets document,
    thus making the cocoon link correct, however this fixed length may cause problems in other systems.
   The other option would be to use base-url (probably http://localhost:8080) instead of the
    cocoon:/ connection, but that may have performance implications -->
                    <xsl:value-of select="substring(/mets:METS/mets:fileSec/mets:fileGrp/mets:file/mets:FLocat[@xlink:title='license_rdf']/@xlink:href,string-length($context-path) + 1)"/>
                </xsl:variable>
                <!-- bds: extract the creativecommons.org link from the RDF -->
                <xsl:variable name="CC_license_URL" select="document($CC_license_RDF_URL)/rdf:RDF/cc:License[1]/@*['rdf:about']" />
                <p>This item is licensed under a <a href="{$CC_license_URL}">Creative Commons License</a><br/>
                <a href="{$CC_license_URL}"><img src="{$context-path}/static/images/cc-somerights.gif" border="0" alt="Creative Commons" /></a></p>
            </xsl:if>
            <p>Items in Knowledge Bank are protected by copyright, with all rights reserved, unless otherwise indicated.</p>
        </div>
    </xsl:template>


    <!-- bds: this adds "Please use this URL to cite.." to "Show full item" link section
    copied from structural.xsl, with a more specific match pattern added -->
    <xsl:template match="dri:p[@rend='item-view-toggle item-view-toggle-top']" priority="5">
        <div class="notice">
            <p>
                Please use this identifier to cite or link to this item:
                <xsl:variable name="metsURL">
                    <xsl:text>cocoon:/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:body/dri:div/dri:referenceSet/dri:reference[@type='DSpace Item']/@url"/>
                    <xsl:text>?sections=dmdSec</xsl:text>
                </xsl:variable>
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


    <!-- bds: license suppression hack -->
<!-- FIXME FIXME FIXME FIXME FIXME FIXME -->
<!-- FIXME FIXME FIXME FIXME FIXME FIXME -->
<!-- FIXME FIXME FIXME FIXME FIXME FIXME -->
<!-- FIXME FIXME FIXME FIXME FIXME FIXME -->
<!-- This actually suppresses ALL items that are text/plain, not just licenses! -->

<!-- bds: from General-Handler.xsl to suppress mimetype='text/html' -->
    <!-- Build a single row in the bitsreams table of the item view page -->
    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>

        <!-- bds: this one line is the difference: -->
        <xsl:if test="not(@MIMETYPE='text/plain')">
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
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <!-- bds: adding [@USE='CONTENT'] to prevent labels from other bundles triggering this xsl:if test -->
                <!-- Display the contents of 'Description' as long as at least one bitstream contains a description -->
                <xsl:if test="$context/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:label != ''">
                    <td>
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                    </td>
                </xsl:if>

            </tr>
        </xsl:if> <!-- bds: closing tag for if not text/plain statement license suppression hack FIXME -->
    </xsl:template>


    <!-- bds: from DIM-Handler.xsl - modify item metadata display (webui styles) -->

    <!-- here in osukb_base is used to set defaults:

                dc.title
                dc.title.alternative
                dc.creator
                dc.contributor.*
                dc.subject
                dc.date.issued(date)
                dc.publisher
                dc.identifier.citation
                dc.relation.ispartofseries
                dc.description.abstract
                dc.identifier.govdoc
                dc.identifier.uri(link)
                dc.identifier.isbn
                dc.identifier.issn
                dc.identifier.ismn
                dc.identifier
    -->

    <!-- render each field on a row, alternating phase between odd and even -->
    <!-- recursion needed since not every row appears for each Item. -->


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
                <xsl:call-template name="itemFieldDisplay.dc.title.alternative">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 3">
                <xsl:call-template name="itemFieldDisplay.dc.creator">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 4">
                <xsl:call-template name="itemFieldDisplay.dc.contributor.ALL">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 5">
                <xsl:call-template name="itemFieldDisplay.dc.subject">
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
                <xsl:call-template name="itemFieldDisplay.dc.identifier.citation">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 9">
                <xsl:call-template name="itemFieldDisplay.dc.relation.ispartofseries">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 10">
                <xsl:call-template name="itemFieldDisplay.dc.description.abstract">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 11">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.govdoc">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 12">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.uri">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 13">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.isbn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 14">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.issn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 15">
                <xsl:call-template name="itemFieldDisplay.dc.identifier.ismn">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="$clause = 16">
                <xsl:call-template name="itemFieldDisplay.dc.identifier">
                    <xsl:with-param name="clause" select="$clause" />
                    <xsl:with-param name="phase" select="$phase" />
                    <xsl:with-param name="otherPhase" select="$otherPhase" />
                </xsl:call-template>
            </xsl:when>


            <xsl:otherwise>

                <xsl:if test="$clause &lt; 17">
                    <xsl:call-template name="itemSummaryView-DIM-fields">
                        <xsl:with-param name="clause" select="($clause + 1)"/>
                        <xsl:with-param name="phase" select="$phase"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 2010-05-04 PMBMD - Adds required head CSS/js for osu header navbar -->
    <xsl:template name="buildHeadOSU">
        <!-- Skipping the reset <link rel="stylesheet" type="text/css" href="/xmlui/static/osu-navbar-media/css-optional/reset.css" />-->
        <link rel="stylesheet" type="text/css">
            <xsl:attribute name="href">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/osu-navbar-media/css/navbar.css</xsl:text>
            </xsl:attribute>
        </link>
        <!-- TODO not currently calling IE specific navbar css files. Go screw yourself IE-->
        <script rel="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/osu-navbar-media/js/searchform.js</xsl:text>
            </xsl:attribute>
            <xsl:text>var x=0;</xsl:text>
        </script>
        <link rel="icon" type="image/x-icon">
            <xsl:attribute name="href">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/osu-navbar-media/img/favicon.ico</xsl:text>
            </xsl:attribute>
        </link>
        <link rel="shortcut icon" type="image/x-icon">
            <xsl:attribute name="href">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/static/osu-navbar-media/img/favicon.ico</xsl:text>
            </xsl:attribute>
        </link>
    </xsl:template>

    <!-- 2010-05-04 PMBMD - Adds the html pieces of the osu navbar -->
    <xsl:template name="buildBodyOSU">
        <div id="osu-Navbar">
            <p>
                <a href="#ds-main" id="skip" class="osu-semantic">skip to main content</a>
            </p>
            <h2 class="osu-semantic">OSU Navigation Bar</h2>
            <div id="osu-NavbarBreadcrumb">
                <p id="osu">
                    <a title="The Ohio State University homepage" href="http://www.osu.edu/">The Ohio State University</a>
                </p>
                <p id="site-name">
                    <a title="University Libraries at The Ohio State University" href="http://library.osu.edu/">University Libraries</a>
                </p>
                <p id="site-name">
                    <a title="Knowledge Bank of University Libraries at The Ohio State University" href="http://kb.osu.edu/">Knowledge Bank</a>
                </p>
            </div>
            <div id="osu-NavbarLinks">
                <ul>
                    <li><a href="http://www.osu.edu/help.php" title="OSU Help">Help</a></li>
                    <li><a href="http://buckeyelink.osu.edu/" title="Buckeye Link">Buckeye Link</a></li>
                    <li><a href="http://www.osu.edu/map/" title="Campus map">Map</a></li>
                    <li><a href="http://www.osu.edu/findpeople.php" title="Find people at OSU">Find People</a></li>
                    <li><a href="https://webmail.osu.edu" title="OSU Webmail">Webmail</a></li>
                    <li id="searchbox">
                        <form action="http://www.osu.edu/search/index.php" method="post">
                            <div class="osu-semantic">
                            </div>
                            <fieldset>
                                <legend><span class="osu-semantic">Search</span></legend>
                                <label class="osu-semantic" for="search-field">Search Ohio State</label>
                                <input type="text" alt-attribute="Search Ohio State" value="" name="searchOSU" class="textfield headerSearchInput" id="search-field"/>
                                <button name="go" type="submit">Go</button>
                            </fieldset>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </xsl:template>

    <!-- This is a named template to be an easy way to override to add something to the buildHead -->
    <xsl:template name="extraHead"></xsl:template>






    

    <!-- bds: from structural.xsl, removing the "&amp;fileGrpTypes=THUMBNAIL" limitation
    from the ?sections= limiter on the METS grab so that browse screens have access to the bitstream URLs.
    Also adding structMap to identify primary bitstream.
    -->

    <xsl:template match="dri:reference" mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <xsl:text>?sections=dmdSec,fileSec,structMap</xsl:text>
        </xsl:variable>
        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-artifact-item </xsl:text>
                <xsl:choose>
                    <xsl:when test="position() mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
            <xsl:apply-templates />
        </li>
    </xsl:template>

    <!-- bds: from General-Handler.xsl, make thumbnails point to bitstreams -->
    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <!-- first, see if any thumbnails exist -->
        <xsl:if test="mets:fileGrp[@USE='THUMBNAIL']">

            <!-- bds:
        Getting GROUPID by prefixing 'group' to the primary FILEID. This works because
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
                    <img alt="Thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=$GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                        </xsl:attribute>
                    </img>
                </a>
            </div>
        </xsl:if>
    </xsl:template>



</xsl:stylesheet>
