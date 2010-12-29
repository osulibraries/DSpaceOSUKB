/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.dspace.app.checker;

import java.sql.SQLException;
import java.util.Iterator;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Constants;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.Context;
import org.dspace.eperson.Group;

/**
 * Command line access to checking comms, colls, items that the anonymous group
 * can access each one.
 * @author peter
 */
public class RestrictedAccessChecker {
    private static boolean PERFORM_FIX = false;
    private static final Logger log = Logger.getLogger(RestrictedAccessChecker.class);

    private RestrictedAccessChecker()
    {
        ;
    }
    public static void main(String[] args) throws SQLException, AuthorizeException
    {
        // set up command line parser
        CommandLineParser parser = new PosixParser();
        CommandLine line = null;

        // create an options object and populate it
        Options options = new Options();

        options.addOption("f", "fix", false, "Fix permissions to anonymous read on all checked objects");
        options.addOption("c", "commcoll",false, "Perform check on communities and collections");
        options.addOption("i", "item", false, "Perform check on items");
        // TODO Add help option

        try
        {
            line = parser.parse(options, args);
        }
        catch (ParseException e)
        {
            log.fatal(e);
            System.exit(1);
        }

        Context context = new Context();
        RestrictedAccessChecker rac = new RestrictedAccessChecker();

        if(line.hasOption('f'))
        {
            PERFORM_FIX = true;
        }

        if(line.hasOption('c'))
        {
            Community[] communities = Community.findAllTop(context);
            for (int com = 0; com < communities.length; com++)
            {
                rac.CheckCommunity(context, communities[com]);
            }
        }

        if(line.hasOption('i'))
        {
            ItemIterator items = Item.findAll(context);
            Item item;
            while(items.hasNext())
            {
                item = items.next();
                rac.CheckItem(context, item);
            }
        }

        if(PERFORM_FIX)
        {
            context.commit();
            context.complete();
        }


        System.exit(0);
    }

    public void CheckCommunity(Context context, Community comm) throws SQLException, AuthorizeException
    {
        //Check itself
        if(AuthorizeManager.authorizeActionBoolean(context, comm, Constants.READ) == false)
        {
            log.info("AnonRead not set on Community: " + comm.getHandle() + " -- " + comm.getName());
            SetAnonymousRead(context, comm);
        }

        //check subCols
        Collection[] colls = comm.getCollections();
        for (int col=0; col < colls.length; col++)
        {
            CheckCollection(context, colls[col]);
        }

        //check subComms (recursive)
        Community[] comms = comm.getSubcommunities();
        for (int com=0; com < comms.length; com++)
        {
            CheckCommunity(context, comms[com]);
        }

    }

    public void CheckCollection(Context context, Collection coll) throws SQLException
    {
        if(AuthorizeManager.authorizeActionBoolean(context, coll, Constants.READ) == false)
        {
            log.info("AnonRead not set on Collection: " + coll.getHandle() + " -- " + coll.getName());
            SetAnonymousRead(context, coll);
        }

    }

    public void CheckItem(Context context, Item item) throws SQLException
    {
        if(AuthorizeManager.authorizeActionBoolean(context, item, Constants.READ) == false)
        {
            log.info("AnonRead not set on Item: " + item.getHandle() + " -- " + item.getName());
            SetAnonymousRead(context, item);
        }
    }

    public void SetAnonymousRead(Context context, DSpaceObject dso)
    {
        try{
            if(PERFORM_FIX == true)
            {
                Group anonymousGroup = Group.find(context, 0);
                AuthorizeManager.addPolicy(context, dso, Constants.READ, anonymousGroup);
                log.info("Fixing Anonymous Read for object:" + dso.getHandle() + " -- " + dso.getName());
            }
        }
        catch(Exception e)
        {
            log.warn("ERROR SETTING ANONYMOUS READ");
        }
    }

}
