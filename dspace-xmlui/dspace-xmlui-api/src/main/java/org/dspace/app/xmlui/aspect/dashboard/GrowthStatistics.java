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
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.xml.sax.SAXException;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.Writer;
import java.sql.SQLException;
import java.util.Map;

/**
 * Exporting Tchera's stats in CSV format.
 * User: peterdietz
 * Date: 7/28/11
 * Time: 11:56 AM
 * To change this template use File | Settings | File Templates.
 */
public class GrowthStatistics extends AbstractReader implements Recyclable
{
    protected static final Logger log = Logger.getLogger(GrowthStatistics.class);

    /** The Cocoon response */
    protected Response response;

    /** The Cocoon request */
    protected Request request;

    private CSVWriter writer;
    
    private String typeString;

    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters par)
            throws ProcessingException, SAXException, IOException
    {
        super.setup(resolver, objectModel, src, par);
        try {
            this.request = ObjectModelHelper.getRequest(objectModel);
            this.response = ObjectModelHelper.getResponse(objectModel);
            Context context = ContextUtil.obtainContext(objectModel);

            //Allow for the content type to be passed in. 0 = BITSTREAM, 1 = ITEM, ...
            String typeParam = request.getParameter("type");
            Integer type;
            if(typeParam == null) {
                type = 1;
            } else {
                type = Integer.parseInt(typeParam);
            }
            log.info("Got parameter type:"+type);

            TableRowIterator tri;
            switch(type) {
                case 0:
                    typeString = "bitstream";
                    tri = bitstreamGrowth(context);
                    break;
                case 1:
                default:
                    typeString = "item";
                    tri = itemGrowth(context);
            }

            response.setContentType("text/csv; encoding='UTF-8'");
            response.setStatus(HttpServletResponse.SC_OK);
            response.setHeader("Content-Disposition", "attachment; filename=growth-"+typeString+".csv");
            writer = new CSVWriter(response.getWriter());

            String[] firstRow = new String[3];
            firstRow[0] = "YYYY-MM";
            firstRow[1] = "count";
            firstRow[2] = "total"+typeString;
            writer.writeNext(firstRow);

            Integer total = 0;
            while(tri.hasNext()) {
                TableRow row = tri.next();
                String date = row.getStringColumn("yearmo");
                Long count = row.getLongColumn("count");
                total += count.intValue();
                String[] rowString = new String[3];
                rowString[0] = date;
                rowString[1] = count.toString();
                rowString[2] = total.toString();

                writer.writeNext(rowString);
            }
            writer.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
    }

    @Override
    public void generate() throws IOException, SAXException, ProcessingException {
        // Had to move all work here to setup.
    }

    protected TableRowIterator itemGrowth(Context context) {
        String query = "SELECT to_char(date_trunc('month', t1.ts), 'YYYY-MM') AS yearmo, count(*) as count " +
                "FROM ( SELECT to_timestamp(text_value, 'YYYY-MM-DD') AS ts FROM metadatavalue, item " +
                "WHERE metadata_field_id = 12 AND metadatavalue.item_id = item.item_id AND item.in_archive=true	) t1 " +
                "GROUP BY date_trunc('month', t1.ts) order by yearmo asc;";

        TableRowIterator tri = null;

        try {
            tri = DatabaseManager.query(context, query);
        } catch (SQLException e) {
            log.error(e.getMessage());
        }
        return tri;
    }

    protected TableRowIterator bitstreamGrowth(Context context) {
        String query = "select to_char(date_trunc('month', t1.ts), 'YYYY-MM') as yearmo, count(*) as count from\n" +
                "(SELECT to_timestamp(text_value, 'YYYY-MM-DD') as ts \n" +
                "FROM public.metadatavalue, public.item, public.item2bundle, public.bundle, public.bitstream, public.bundle2bitstream\n" +
                "WHERE metadatavalue.item_id = item.item_id AND item.item_id = item2bundle.item_id AND bundle.bundle_id = item2bundle.bundle_id AND\n" +
                "  bundle.bundle_id = bundle2bitstream.bundle_id AND bundle2bitstream.bitstream_id = bitstream.bitstream_id AND\n" +
                "  metadatavalue.metadata_field_id = 12 AND bundle.\"name\" = 'ORIGINAL' AND item.in_archive = true\n" +
                ") t1 group by date_trunc('month', t1.ts) order by yearmo asc;";

        TableRowIterator tri = null;

        try {
            tri = DatabaseManager.query(context, query);
        } catch (SQLException e) {
            log.error(e.getMessage());
        }
        return tri;
    }

    public void recycle() {
        this.response = null;
        this.request = null;
    }
}
