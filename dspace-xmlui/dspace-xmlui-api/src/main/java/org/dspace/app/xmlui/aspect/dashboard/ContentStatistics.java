/* ContentStatistics -- expose simple measures of repository size as a web document
 *
 * Copyright (c) 2002-2008, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
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
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
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

package org.dspace.app.xmlui.aspect.dashboard;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.TimeZone;

import javax.servlet.http.HttpServletResponse;

import org.apache.avalon.excalibur.pool.Recyclable;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.Response;
import org.apache.cocoon.reading.AbstractReader;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.log4j.Logger;

import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.*;
import org.xml.sax.SAXException;

/**
 * Expose some simple measures of the repository's size as an XML document via a
 * web service.
 *
 * <p><em>NOTE WELL:</em>  we go straight to the database for much of this
 * information.  This could break if there are significant changes in the
 * schema.  The object model doesn't provide these statistics, though.</p>
 * 
 * @author Mark H. Wood
 */
public class ContentStatistics extends AbstractReader implements Recyclable
{
    /** The Cocoon response */
    protected Response response;

    /** The Cocoon request */
    protected Request request;

    /**
     * How big of a buffer should we use when reading from the bitstream before
     * writting to the HTTP response?
     */
    protected static final int BUFFER_SIZE = 8192;

    protected static final int expires = 60*60*60000;

	private static final TimeZone utcZone = TimeZone.getTimeZone("UTC");

	protected static final Logger log
    	= Logger.getLogger(ContentStatistics.class);

    StringBuilder xmlData = null;

    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par)
            throws ProcessingException, SAXException, IOException
    {
        super.setup(resolver, objectModel, src, par);

        try {
            this.request = ObjectModelHelper.getRequest(objectModel);
            this.response = ObjectModelHelper.getResponse(objectModel);
            Context context = ContextUtil.obtainContext(objectModel);


            xmlData = new StringBuilder();

            xmlData.append("<?xml version='1.0' encoding='UTF-8'?>");

            xmlData.append("<dspace-repository-statistics date='");
            log.debug("Ready to write date");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            df.setTimeZone(utcZone);
            SimpleDateFormat tf = new SimpleDateFormat("HHmmss");
            tf.setTimeZone(utcZone);
            Date now = new Date();
            xmlData.append(df.format(now));
            xmlData.append('T');
            xmlData.append(tf.format(now));
            xmlData.append("Z'>");
            log.debug("Wrote the date");

            TableRow row = DatabaseManager.querySingle(context, "SELECT count(community_id) AS communities FROM community;");
            if (null != row) {
                xmlData.append(" <statistic name='communities'>" + row.getLongColumn("communities") + "</statistic>");
            }

            row = DatabaseManager.querySingle(context, "SELECT count(collection_id) AS collections FROM collection;");
            if (null != row)
                xmlData.append(" <statistic name='collections'>"+row.getLongColumn("collections")+"</statistic>");

            row = DatabaseManager.querySingle(context, "SELECT count(item_id) AS items FROM item WHERE NOT withdrawn;");
            if (null != row) {
                xmlData.append(" <statistic name='items'>"+row.getLongColumn("items")+"</statistic>");
            }

            log.debug("Counting, summing bitstreams");
            // Get # bitstreams, and MB
            row = DatabaseManager.querySingle(context,
                    "SELECT count(bitstream_id) AS bitstreams," +
                            " sum(size_bytes)/1048576 AS totalMBytes" +
                            " FROM bitstream" +
                    		"  JOIN bundle2bitstream USING(bitstream_id)" +
                    		"  JOIN bundle USING(bundle_id)" +
                    		"  JOIN item2bundle USING(bundle_id)" +
                    		"  JOIN item USING(item_id)" +
                    		" WHERE NOT withdrawn" +
                    		"  AND NOT deleted" +
                    		"  AND bundle.name = 'ORIGINAL';");
            if (null != row)
            {
                log.debug("Writing count");
                xmlData.append(" <statistic name='bitstreams'>"+row.getLongColumn("bitstreams")+"</statistic>");
                log.debug("Writing total size");
                xmlData.append(" <statistic name='totalMBytes'>"+row.getLongColumn("totalMBytes")+"</statistic>");
                log.debug("Completed writing count, size");
            }

            log.debug("Counting, summing image bitstreams");
            row = DatabaseManager.querySingle(context,
                    "SELECT count(bitstream_id) AS images," +
                    " sum(size_bytes)/1048576 AS imageMBytes" +
                    " FROM bitstream" +
                    " JOIN bitstreamformatregistry USING(bitstream_format_id)" +
                    " JOIN bundle2bitstream USING(bitstream_id)" +
                    " JOIN bundle USING(bundle_id)" +
                    " JOIN item2bundle USING(bundle_id)" +
                    " JOIN item USING(item_id)" +
                    " WHERE bundle.name = 'ORIGINAL'" +
                    "  AND mimetype LIKE 'image/%'" +
                    "  AND NOT deleted" +
                    "  AND NOT withdrawn;"
                    );
            if (null != row)
            {
                xmlData.append(" <statistic name='images'>"+row.getLongColumn("images")+"</statistic>");
                xmlData.append(" <statistic name='imageMBytes'>"+row.getLongColumn("imageMBytes")+"</statistic>");
            }

            context.abort();	// nothing to commit

            xmlData.append("</dspace-repository-statistics>");
            log.debug("Finished report");

        } catch (SQLException e) {
            log.debug("caught SQLException");
            //if (null != context) context.abort();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }



    }

    public void generate() throws IOException, SAXException, ProcessingException {
        response.setContentType("text/xml; encoding='UTF-8'");
        response.setStatus(HttpServletResponse.SC_OK);

        out.write(xmlData.toString().getBytes("UTF-8"));
        out.flush();
        out.close();

    }

    public void recycle() {
        this.response = null;
        this.request = null;
    }

}
