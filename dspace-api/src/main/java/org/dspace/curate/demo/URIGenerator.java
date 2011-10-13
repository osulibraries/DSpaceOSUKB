/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate.demo;

import org.apache.log4j.Logger;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;

/**
 * URIGenerator
 * ------------
 * URIGenerator is an example of re-generating dc.identifier.uri
 * values from the configured handle prefix and item handle.
 * Useful if you've changed handle prefixes recently and want to
 * update all your existing dc.identifier.uri metadata.
 *
 * @author Kim Shepherd
 */

public class URIGenerator extends AbstractCurationTask
{
    private int status = Curator.CURATE_UNSET;
    private String result = null;

    private static Logger log = Logger.getLogger(URIGenerator.class);


    @Override
    public int perform(DSpaceObject dso)
    {
        if(dso instanceof Item)
        {
            Item item = (Item) dso;

            // Get new handle prefix from [dspace]/config/dspace.cfg
            String newUri = ConfigurationManager.getProperty("handle.canonical.prefix");
            newUri += item.getHandle();

            // Clear existing dc.identifer.uri fields (all languages)
            item.clearMetadata("dc", "identifier", "uri", Item.ANY);

            // Add the new
            item.addMetadata("dc","identifier","uri", null, newUri);

            try {
                item.update();
                item.decache();
                status = Curator.CURATE_SUCCESS;
                result = "Generated URI for " + item.getHandle() + ": " + newUri;
            }
            catch(Exception e)
            {
                status = Curator.CURATE_ERROR;
                log.info("Curation task failed with error: " + e.getLocalizedMessage());
            }

            setResult(result);
            report(result);
        }

        return status;
    }
}