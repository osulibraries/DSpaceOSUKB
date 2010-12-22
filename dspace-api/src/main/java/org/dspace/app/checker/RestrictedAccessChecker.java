/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.dspace.app.checker;

import java.sql.SQLException;
import java.util.Iterator;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Constants;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.Context;

/**
 *
 * @author peter
 */
public class RestrictedAccessChecker {
    private RestrictedAccessChecker()
    {
        ;
    }
    public static void main(String[] args) throws SQLException
    {
        Context context = new Context();
        AuthorizeManager auth = new AuthorizeManager();

        //c.setSpecialGroup(0);   // Anonymous group
        RestrictedAccessChecker rac = new RestrictedAccessChecker();

        Community[] communities = Community.findAllTop(context);
        for (int com = 0; com < communities.length; com++)
        {
            
            rac.CheckCommunity(auth, context, communities[com]);
        }

        ItemIterator items = Item.findAll(context);
        Item item;
        while(items.hasNext())
        {
            item = items.next();
            rac.CheckItem(auth, context, item);
        }


        System.exit(0);
    }

    public void CheckCommunity(AuthorizeManager auth, Context context, Community comm) throws SQLException
    {
        //Check itself
        if(auth.authorizeActionBoolean(context, comm, Constants.READ) == false)
        {
            System.out.println("Can't Access Community: " + comm.getHandle() + " -- " + comm.getName());
        }

        //check subCols
        Collection[] colls = comm.getCollections();
        for (int col=0; col < colls.length; col++)
        {
            CheckCollection(auth, context, colls[col]);
        }

        //check subComms (recursive)
        Community[] comms = comm.getSubcommunities();
        for (int com=0; com < comms.length; com++)
        {
            CheckCommunity(auth, context, comms[com]);
        }

    }

    public void CheckCollection(AuthorizeManager auth, Context context, Collection coll) throws SQLException
    {
        if(auth.authorizeActionBoolean(context, coll, Constants.READ) == false)
        {
            System.out.println("Can't Access Collection: " + coll.getHandle() + " -- " + coll.getName());
        }

    }

    public void CheckItem(AuthorizeManager auth, Context context, Item item) throws SQLException
    {
        if(auth.authorizeActionBoolean(context, item, Constants.READ) == false)
        {
            System.out.println("Can't Access Item: " + item.getHandle() + " -- " + item.getName());
        }
    }

}
