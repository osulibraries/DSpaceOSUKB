/*
 * TidyService.java
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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;

import java.sql.SQLException;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.w3c.tidy.*;

/**
 * Clean up HTML in metadata fields of collection and community page to XHTML
 *
 * @author Peter Dietz
 */
public class TidyService
{
    private static Logger log = Logger.getLogger("TidyService");

    /**
     * Tidy up the community page metadata.
     * Fields in community page that are tidied are: introductory_text,
     * copyright, and side_bar_text
     * @throws SQLException
     * @throws IOException
     */
    public static void tidyCommunities() throws SQLException, IOException
    {
        Tidy tidy = initTidy();

        Context context = new Context();
        context.turnOffAuthorisationSystem();
        Community[] communities = Community.findAll(context);

        //Report on the communities
        for (int i = 0; i < communities.length; i++)
        {
            context.ignoreAuthorization();
            Community community = communities[i];
            log.fine("===========================");
            String name = community.getMetadata("name");
            log.fine("NAME:"+name);

            String intro = community.getMetadata("introductory_text");
            String outIntro = cleanString(tidy, intro);
            log.fine("--introductory_textORIG:"+intro);
            log.fine("--introductory_textTIDY:"+outIntro);
            community.setMetadata("introductory_text", outIntro);

            String copyright = community.getMetadata("copyright_text");
            String outCopyright = cleanString(tidy, copyright);
            log.fine("--copyrightORIG:"+copyright);
            log.fine("--copyrightTIDY:"+outCopyright);
            community.setMetadata("copyright_text", outCopyright);

            String sidebar = community.getMetadata("side_bar_text");
            String outSidebar = cleanString(tidy, sidebar);
            log.fine("--side_bar_textORIG:"+sidebar);
            log.fine("--side_bar_textTIDY:"+outSidebar);
            community.setMetadata("side_bar_text", outSidebar);

            try {
                community.update();
            } catch (AuthorizeException ex) {
                Logger.getLogger(TidyService.class.getName()).log(Level.SEVERE, null, ex);
            }

        }

        context.restoreAuthSystemState();
        context.complete();
    }

    /**
     * Tidy up the collection page metadata.
     * Fields in collection page that are tidied are: introductory_text,
     * copyright, and side_bar_text
     *
     * @throws SQLException
     * @throws IOException
     */
    public static void tidyCollections() throws SQLException, IOException
    {
        Tidy tidy = initTidy();

        Context context = new Context();
        context.turnOffAuthorisationSystem();
        Collection[] collections = Collection.findAll(context);

        for (int i = 0; i < collections.length; i++)
        {
            context.ignoreAuthorization();
            Collection collection = collections[i];
            log.fine("===========================");
            String name = collection.getMetadata("name");
            log.fine("NAME:"+name);

            String intro = collection.getMetadata("introductory_text");
            String outIntro = cleanString(tidy, intro);
            log.fine("--introductory_textORIG:"+intro);
            log.fine("--introductory_textTIDY:"+outIntro);
            collection.setMetadata("introductory_text", outIntro);

            String copyright = collection.getMetadata("copyright_text");
            String outCopyright = cleanString(tidy, copyright);
            log.fine("--copyrightORIG:"+copyright);
            log.fine("--copyrightTIDY:"+outCopyright);
            collection.setMetadata("copyright_text", outCopyright);

            String sidebar = collection.getMetadata("side_bar_text");
            String outSidebar = cleanString(tidy, sidebar);
            log.fine("--side_bar_textORIG:"+sidebar);
            log.fine("--side_bar_textTIDY:"+outSidebar);
            collection.setMetadata("side_bar_text", outSidebar);

            try {
                collection.update();
            } catch (AuthorizeException ex) {
                Logger.getLogger(TidyService.class.getName()).log(Level.SEVERE, null, ex);
            }

        }

        context.restoreAuthSystemState();
        context.complete();

    }

    /**
     * Helper to do the work required to clean a chunk of text
     * @param tidy the tidy instance already initialized
     * @param dirty a chunk of text that might have bad html
     * @return clean-html string
     * @throws IOException
     */
    public static String cleanString(Tidy tidy, String dirty) throws IOException
    {
        InputStream istream     = new ByteArrayInputStream(dirty.getBytes());
        OutputStream ostream    = new ByteArrayOutputStream();

        tidy.parseDOM(istream, ostream);
        String clean = ostream.toString();

        istream.close();
        ostream.close();
        return clean;
    }

    /**
     * Some defaults that we'll use to load up Tidy with, they work well for
     * just fixing a chunk of text
     * @return
     */
    public static Tidy initTidy()
    {
        Tidy tidy = new Tidy();
        tidy.setQuiet(true);
        tidy.setShowErrors(0);
        tidy.setShowWarnings(false);
        tidy.setXHTML(true);
        tidy.setPrintBodyOnly(true);
        tidy.setEncloseText(false);
        tidy.setInputEncoding("UTF8");
        tidy.setWriteback(false);

        return tidy;
    }

    /**
     * Tidy up the Collection and Community metadata, evidenced on community-list
     * @param args
     * @throws SQLException
     * @throws IOException
     */
    public static void main(String[] args) throws SQLException, IOException
    {
        log.info("Starting Tidying Collections");
        tidyCollections();
        log.info("Finished Tidying Collections");

        log.info("Starting Tidying Communities");
        tidyCommunities();
        log.info("Finished Tidying Communities");

        System.exit(0);
    }
}