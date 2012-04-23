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
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.content.DSpaceObject;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.action.search.SearchRequestBuilder;
import org.xml.sax.SAXException;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 4/20/12
 * Time: 3:28 PM
 * To change this template use File | Settings | File Templates.
 */
public class CSVOutputter extends AbstractReader implements Recyclable 
{
    protected static final Logger log = Logger.getLogger(CSVOutputter.class);
    protected Response response;
    protected Request request;
    
    public void setup(SourceResolver sourceResolver, Map objectModel, String src, Parameters parameters) throws IOException, SAXException, ProcessingException {
        log.info("CSV Writer for stats");
        super.setup(sourceResolver, objectModel, src, parameters);
        CSVWriter writer = null;
        try {
            //super.setup(sourceResolver, objectModel, src, parameters);
            this.request = ObjectModelHelper.getRequest(objectModel);
            this.response = ObjectModelHelper.getResponse(objectModel);

            String requestURI = request.getRequestURI();
            String[] uriSegments = requestURI.split("/");
            String requestedReport = uriSegments[uriSegments.length-1];
            if(requestedReport == null || requestedReport.length() < 1) {
                return;
            }

            response.setContentType("text/csv; encoding='UTF-8'");
            response.setStatus(HttpServletResponse.SC_OK);
            writer = new CSVWriter(response.getWriter());
            DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
            response.setHeader("Content-Disposition", "attachment; filename=KB-StatisticsReport-" + dso.getHandle() + "-" + requestedReport +".csv");


            //String[] firstRow = new String[4];
            //firstRow[0] = "Community Name";
            //firstRow[1] = "communityID";
            //firstRow[2] = "Handle";
            //firstRow[3] = "community_item_count";
            //writer.writeNext(firstRow);

            if(requestedReport.equalsIgnoreCase("topCountries")) {
                log.info("Writing topCountries report");
                SearchRequestBuilder requestBuilder = ElasticSearchStatsViewer.facetedQueryBuilder(ElasticSearchStatsViewer.facetTopCountries, ElasticSearchStatsViewer.facetTopUSCities);
                SearchResponse searchResponse = requestBuilder.execute().actionGet();
                log.info(searchResponse.toString());
                String[] temp = new String[2];
                temp[0] = searchResponse.toString();
                temp[1] = "";
                writer.writeNext(temp);

                
            } else if (requestedReport.equalsIgnoreCase("fileDownloads")) {
                log.info("Writing topCountries report");
                //SearchRequestBuilder requestBuilder = ElasticSearchStatsViewer.facetedQueryBuilder(ElasticSearchStatsViewer.facetTopCountries, ElasticSearchStatsViewer.facetTopUSCities);
                //SearchResponse searchResponse = requestBuilder.execute().actionGet();
                //log.info(searchResponse.toString());
                String[] temp = new String[2];
                temp[0] = "File";
                //temp[0] = searchResponse.toString();
                temp[1] = "Downloads";
                writer.writeNext(temp);
            }




            




        } catch (SQLException e) {
            log.error("Some Error:" + e.getMessage());
        } catch (WingException e) {
            log.error("Some Error:" + e.getMessage());
        } catch (IOException e) {
            log.error("Some Error:" + e.getMessage());
        } finally {
            try {
                if(writer != null) {
                    writer.close();
                } else {
                    log.error("CSV Writer was null!!");
                }
            } catch (IOException e) {
                log.error("Hilarity Ensues... IO Exception while closing the csv writer.");
            }

        }
    }

    public void generate() throws IOException {
        log.info("CSV Writer generator for stats");
        out.flush();
        out.close();
    }
    
    public void recycle() {
        this.request = null;
        this.response = null;
    }
    
}
