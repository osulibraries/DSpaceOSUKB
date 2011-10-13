/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.curate.demo;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.eperson.Group;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 *
 * PolicyChecker
 * ------------
 * Checks fulltext bitstreams for anonymous: read access, and reports
 * if conditions are met
 *
 * @author Kim Shepherd
 *
 */


public class PolicyChecker extends AbstractCurationTask
{

    private static int status = Curator.CURATE_UNSET;
    private static String results = "The task was not run";

    private static final String PLUGIN_PREFIX = "policychecker";

    private static String[] bundlesToCurate = {"ORIGINAL", "TEXT"};

    private static Logger log = Logger.getLogger(PolicyChecker.class);

    private static Context c;
    private static final int ANONYMOUS = 0;
    private static final int READ = org.dspace.core.Constants.getActionID("READ");


    @Override
    public void init(Curator curator, String taskId) throws IOException
    {

        super.init(curator,  taskId);

        try {
            c = new Context();
        } catch(Exception e) {
            status = Curator.CURATE_ERROR;
            String results = "Could not obtain context: " + e.getLocalizedMessage();
            setResult(results);
            report(results);
            return;
        }

        report("Handle, Bitstream filename");

    }

    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        results = "";

        if(dso instanceof Item)
        {
            Item item = (Item) dso;
            status = Curator.CURATE_SUCCESS;
            try {
                checkReadAccess(item);
            } catch(Exception e) {
                e.printStackTrace();
            }
        }

        setResult(results);
        report(results);
        return status;

    }

    private static void checkReadAccess(Item item) throws SQLException, AuthorizeException
    {

        String handle = item.getHandle();
        for (String bundleName : bundlesToCurate)
        {
            Bundle[] bundles = item.getBundles(bundleName);

            for (Bundle bundle : bundles)
            {

                for (Bitstream bs : bundle.getBitstreams())
                {
                    List<ResourcePolicy> rps =  AuthorizeManager.getPoliciesActionFilter(c, bs, READ);
                    for(ResourcePolicy rp : rps)
                    {
                        // Anonymous has read access?
                        if(rp.getGroupID() == ANONYMOUS)
                        {
                            results += handle + ",\"" + bs.getName() + "\"" + "\n";
                        }
                    }

                }
            }
        }
    }

}