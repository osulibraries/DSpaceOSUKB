/*
 * ItemService.java
 *
 * Version: $Revision$
 *
 * Date: $Date$
 *
 * Copyright (c) 2002-2009, The DSpace Foundation.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the DSpace Foundation nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.content.service;

import java.io.IOException;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.dao.ItemDAO;
import org.dspace.content.dao.ItemDAOFactory;
import org.dspace.content.Bitstream;
import org.dspace.content.Thumbnail;
import org.dspace.content.Item;
import org.dspace.core.Context;

import java.sql.SQLException;
import java.util.Iterator;
import org.dspace.content.Bundle;

public class ItemService
{
    public static Thumbnail getThumbnail(Context context, int itemId, boolean requireOriginal) throws SQLException
    {
        ItemDAO dao = ItemDAOFactory.getInstance(context);

        Bitstream thumbBitstream = null;
        Bitstream primaryBitstream = dao.getPrimaryBitstream(itemId, "ORIGINAL");
        if (primaryBitstream != null)
        {
            if (primaryBitstream.getFormat().getMIMEType().equals("text/html"))
                return null;

            thumbBitstream = dao.getNamedBitstream(itemId, "THUMBNAIL", primaryBitstream.getName() + ".jpg");
        }
        else
        {
            if (requireOriginal)
                primaryBitstream = dao.getFirstBitstream(itemId, "ORIGINAL");

            thumbBitstream   = dao.getFirstBitstream(itemId, "THUMBNAIL");
        }

        if (thumbBitstream != null)
            return new Thumbnail(thumbBitstream, primaryBitstream);

        return null;
    }

    /**
     *
     *
     *
     * Assumptions:
     *  - one item which houses this bitstream
     *  - one receiver, one loser
     * @param context
     * @param bitstream_id
     * @param destinationBundleName
     * @throws SQLException
     */
    public static void moveBitstreamToBundle(Context context, int bitstream_id, String destinationBundleName) throws SQLException, AuthorizeException, IOException
    {
        context.turnOffAuthorisationSystem();
        //Get all background info
        Bitstream currentBitstream = Bitstream.find(context, bitstream_id);
        System.out.println("bitstream_id:"+bitstream_id);

        Bundle[] losingBundles = currentBitstream.getBundles();

        for (int i = 0; i < losingBundles.length; i++) {
            System.out.print(" LosingBundle:"+losingBundles[i].getName()+" -- bundle_id:"+losingBundles[i].getID());
        }

        Item parentItem = losingBundles[0].getItems()[0];
        System.out.print(" Parent item_id:"+parentItem.getID());

        // Get movers and loser bundles
        Bundle[] destinationBundles = parentItem.getBundles(destinationBundleName);
        Bundle destinationBundle = null;
        if(destinationBundles.length > 0)
        {
            destinationBundle = destinationBundles[0];
            System.out.print(" Existing dest bundle -- bundle_id:"+destinationBundle.getID());
        }
        else
        {
            //Doesn't exist, must create
            destinationBundle = parentItem.createBundle(destinationBundleName);
            System.out.print(" new dest bundle -- bundle_id:"+destinationBundle.getID());
        }

        // Add this bitstream to dest bundle, remove from exist bundle
        if(destinationBundle.getID() == losingBundles[0].getID()) {
            System.out.println("HOLD THE PHONE!!! -- Losing Bundle and gain bundle should not be the same, aborting!!!");
            context.restoreAuthSystemState();
            return;
        }


        destinationBundle.addBitstream(currentBitstream);
        destinationBundle.update();
        losingBundles[0].removeBitstream(currentBitstream);
        losingBundles[0].update();

        System.out.println(" Move Completed!");

        context.commit();

        context.restoreAuthSystemState();
    }

    public static void moveBitstreamToBundleTest() throws SQLException, AuthorizeException, IOException
    {
        Context context = new Context();
        //TODO: REFACTOR SO I CAN SPECIFY FROM COMMAND LINE, not have to rewrite the code.
        moveBitstreamToBundle(context, 217683, "PROXY-LICENSE");
        moveBitstreamToBundle(context, 176040, "PROXY-LICENSE");
        moveBitstreamToBundle(context, 175334, "PROXY-LICENSE");
    }

    public static void main(String[] args) throws SQLException, AuthorizeException, IOException
    {
        moveBitstreamToBundleTest();
        System.exit(0);
    }
}
