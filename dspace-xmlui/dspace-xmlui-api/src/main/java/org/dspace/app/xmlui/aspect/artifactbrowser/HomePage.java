/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;


import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.core.ConfigurationManager;

/**
 * Placeholder homepage to prevent PageNotFound, all the work is done by theme layer.
 *
 * @author Peter Dietz
 */
public class HomePage extends AbstractDSpaceTransformer
{
    /** language strings */
    private static final Message T_dspace_home = message("xmlui.ArtifactBrowser.HomePage.title");

    public void addPageMeta(PageMeta pageMeta) throws WingException
    {
        pageMeta.addMetadata("title").addContent(T_dspace_home);

        // Add RSS links if available
        String formats = ConfigurationManager.getProperty("webui.feed.formats");
        if (formats != null) {
            for (String format : formats.split(",")) {
                // Remove the protocol number, i.e. just list 'rss' or' atom'
                String[] parts = format.split("_");
                if (parts.length < 1) {
                    continue;
                }

                String feedFormat = parts[0].trim() + "+xml";

                String feedURL = contextPath + "/feed/" + format.trim() + "/site";
                pageMeta.addMetadata("feed", feedFormat).addContent(feedURL);
            }
        }
    }

    public void addBody(Body body) throws WingException
    {
        Division home = body.addDivision("the-homepage");
        home.setHead("Homepage content");
    }
}
