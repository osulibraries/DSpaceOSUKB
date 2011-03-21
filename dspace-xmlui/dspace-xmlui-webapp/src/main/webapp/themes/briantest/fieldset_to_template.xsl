<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">
    <xsl:output indent="yes"/>

    <xsl:template name="writeFieldset" match="/">
        <xsl:text>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;
            &lt;xsl:stylesheet xmlns:i18n=&quot;http://apache.org/cocoon/i18n/2.1&quot;
            xmlns:dri=&quot;http://di.tamu.edu/DRI/1.0/&quot;
            xmlns:mets=&quot;http://www.loc.gov/METS/&quot;
            xmlns:xlink=&quot;http://www.w3.org/TR/xlink/&quot;
            xmlns:xsl=&quot;http://www.w3.org/1999/XSL/Transform&quot; version=&quot;1.0&quot;
            xmlns:dim=&quot;http://www.dspace.org/xmlns/dspace/dim&quot;
            xmlns:xhtml=&quot;http://www.w3.org/1999/xhtml&quot;
            xmlns:mods=&quot;http://www.loc.gov/mods/v3&quot;
            xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot;
            xmlns=&quot;http://www.w3.org/1999/xhtml&quot;
            exclude-result-prefixes=&quot;i18n dri mets xlink xsl dim xhtml mods dc&quot;&gt;

            &lt;xsl:import href=&quot;../dri2xhtml.xsl&quot;/&gt;
            &lt;xsl:output indent=&quot;yes&quot;/&gt;
            &lt;xsl:template name=&quot;itemSummaryView-DIM-fields&quot;&gt;
            &lt;xsl:param name=&quot;clause&quot; select=&quot;&apos;1&apos;&quot;/&gt;
            &lt;xsl:param name=&quot;phase&quot; select=&quot;&apos;even&apos;&quot;/&gt;
            &lt;xsl:variable name=&quot;otherPhase&quot;&gt;
            &lt;xsl:choose&gt;
            &lt;xsl:when test=&quot;$phase = &apos;even&apos;&quot;&gt;
            &lt;xsl:text&gt;odd&lt;/xsl:text&gt;
            &lt;/xsl:when&gt;
            &lt;xsl:otherwise&gt;
            &lt;xsl:text&gt;even&lt;/xsl:text&gt;
            &lt;/xsl:otherwise&gt;
            &lt;/xsl:choose&gt;
            &lt;/xsl:variable&gt;

            &lt;xsl:choose&gt;

        </xsl:text>
        <xsl:call-template name="nextField">
            <xsl:with-param name="clause" select="'1'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nextField">
        <xsl:param name="clause" />
        <xsl:text>&lt;xsl:when test=&quot;$clause = </xsl:text><xsl:value-of select="$clause"/><xsl:text>&quot;&gt;</xsl:text>
        <xsl:text>&lt;xsl:call-template name=&quot;itemFieldDisplay.</xsl:text><xsl:value-of select="/fieldset/field[$clause]"/><xsl:text>&quot;&gt;</xsl:text>
        <xsl:text>
            &lt;xsl:with-param name=&quot;clause&quot; select=&quot;$clause&quot; /&gt;
            &lt;xsl:with-param name=&quot;phase&quot; select=&quot;$phase&quot; /&gt;
            &lt;xsl:with-param name=&quot;otherPhase&quot; select=&quot;$otherPhase&quot; /&gt;
            &lt;/xsl:call-template&gt;
        &lt;/xsl:when&gt;</xsl:text>
        <xsl:choose>
            <xsl:when test="$clause &lt; count(/fieldset/field)">
                <xsl:call-template name="nextField">
                    <xsl:with-param name="clause" select="$clause + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>
                    &lt;xsl:otherwise&gt;

                &lt;xsl:if test=&quot;$clause &amp;lt; </xsl:text>
                <xsl:value-of select="$clause"/>
                <xsl:text>&quot;&gt;
                    &lt;xsl:call-template name=&quot;itemSummaryView-DIM-fields&quot;&gt;
                    &lt;xsl:with-param name=&quot;clause&quot; select=&quot;($clause + 1)&quot;/&gt;
                    &lt;xsl:with-param name=&quot;phase&quot; select=&quot;$phase&quot;/&gt;
                    &lt;/xsl:call-template&gt;
                    &lt;/xsl:if&gt;
                    &lt;/xsl:otherwise&gt;
                    &lt;/xsl:choose&gt;
                    &lt;/xsl:template&gt;

                    &lt;/xsl:stylesheet&gt;
                </xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
