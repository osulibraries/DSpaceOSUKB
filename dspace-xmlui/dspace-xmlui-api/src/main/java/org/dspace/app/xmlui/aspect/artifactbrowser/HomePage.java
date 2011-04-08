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
    }

    public void addBody(Body body) throws WingException
    {
        Division home = body.addDivision("the-homepage");
        home.setHead("Homepage content");
    }
}
