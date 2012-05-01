package org.dspace.app.xmlui.aspect.dashboard;


import au.com.bytecode.opencsv.CSVWriter;
import org.apache.avalon.excalibur.pool.Recyclable;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.Response;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.reading.AbstractReader;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.xml.sax.SAXException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

/**
 * Exporting Community's in CSV format
 * User: peterdietz
 * Date: 7/28/11
 * Time: 11:56 AM
 * To change this template use File | Settings | File Templates.
 */
public class CommunityInfo extends AbstractReader implements Recyclable
{
    protected static final Logger log = Logger.getLogger(CommunityInfo.class);

    /** The Cocoon response */
    protected Response response;

    /** The Cocoon request */
    protected Request request;

    @Override
    public void generate() throws IOException, SAXException, ProcessingException {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par)
            throws ProcessingException, SAXException, IOException
    {
        super.setup(resolver, objectModel, src, par);
        try {
            this.request = ObjectModelHelper.getRequest(objectModel);
            this.response = ObjectModelHelper.getResponse(objectModel);
            response.setContentType("text/csv; encoding='UTF-8'");
            response.setStatus(HttpServletResponse.SC_OK);
            response.setHeader("Content-Disposition", "attachment; filename=community-list.csv") ;
            CSVWriter writer = new CSVWriter(response.getWriter());

            String[] firstRow = new String[4];
            firstRow[0] = "Community Name";
            firstRow[1] = "communityID";
            firstRow[2] = "Handle";
            firstRow[3] = "community_item_count";
            writer.writeNext(firstRow);

            TableRowIterator tri = null;
            try {
                tri = itemGrowth();
                while(tri.hasNext()) {
                    TableRow row = tri.next();
                    String[] rowString = new String[4];

                    rowString[0] = row.getStringColumn("name");
                    rowString[1] = String.valueOf(row.getIntColumn("community_id"));
                    rowString[2] = row.getStringColumn("handle");
                    rowString[3] = String.valueOf(row.getIntColumn("count"));

                    writer.writeNext(rowString);
                }
            } catch (SQLException e) {
                log.error("Error fetching row" + e.getMessage());
            }

            writer.close();
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }

    protected TableRowIterator itemGrowth() throws SQLException {
        Context context = new Context();

        String query = "SELECT community.\"name\", community.community_id, handle.handle, community_item_count.count " +
                "FROM public.community, public.handle, public.community_item_count " +
                "WHERE community.community_id = community_item_count.community_id AND handle.resource_id = community.community_id AND handle.resource_type_id = 4 " +
                "order by community.community_id asc;";

        TableRowIterator tri = DatabaseManager.query(context, query);

        return tri;

    }

    public void recycle() {
        this.response = null;
        this.request = null;
    }
}