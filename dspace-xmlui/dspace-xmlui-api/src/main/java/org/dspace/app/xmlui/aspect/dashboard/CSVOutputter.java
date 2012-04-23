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
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.content.DSpaceObject;
import org.dspace.core.Context;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.action.search.SearchRequestBuilder;
import org.elasticsearch.search.facet.datehistogram.DateHistogramFacet;
import org.elasticsearch.search.facet.terms.TermsFacet;
import org.xml.sax.SAXException;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
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
    private static SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    protected Response response;
    protected Request request;
    protected Context context;
    protected CSVWriter writer = null;
    
    public void setup(SourceResolver sourceResolver, Map objectModel, String src, Parameters parameters) throws IOException, SAXException, ProcessingException {
        log.info("CSV Writer for stats");
        super.setup(sourceResolver, objectModel, src, parameters);

        try {
            //super.setup(sourceResolver, objectModel, src, parameters);
            this.request = ObjectModelHelper.getRequest(objectModel);
            this.response = ObjectModelHelper.getResponse(objectModel);

            context = ContextUtil.obtainContext(objectModel);

            String requestURI = request.getRequestURI();
            String[] uriSegments = requestURI.split("/");
            String requestedReport = uriSegments[uriSegments.length-1];
            if(requestedReport == null || requestedReport.length() < 1) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            response.setContentType("text/csv; encoding='UTF-8'");
            response.setStatus(HttpServletResponse.SC_OK);
            writer = new CSVWriter(response.getWriter());
            DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
            response.setHeader("Content-Disposition", "attachment; filename=KBStats-" + dso.getHandle() + "-" + requestedReport +".csv");

            //TODO Accept dates as input filter.
            ElasticSearchStatsViewer esStatsViewer = new ElasticSearchStatsViewer(dso, null, null);

            if(requestedReport.equalsIgnoreCase("topCountries"))
            {
                SearchRequestBuilder requestBuilder = esStatsViewer.facetedQueryBuilder(esStatsViewer.facetTopCountries);
                SearchResponse searchResponse = requestBuilder.execute().actionGet();

                TermsFacet topCountriesFacet = searchResponse.getFacets().facet(TermsFacet.class, "top_countries");
                addTermFacetToWriter(topCountriesFacet);
            }
            else if (requestedReport.equalsIgnoreCase("fileDownloads"))
            {
                SearchRequestBuilder requestBuilder = esStatsViewer.facetedQueryBuilder(esStatsViewer.facetMonthlyDownloads);
                SearchResponse searchResponse = requestBuilder.execute().actionGet();

                DateHistogramFacet monthlyDownloadsFacet = searchResponse.getFacets().facet(DateHistogramFacet.class, "monthly_downloads");
                addDateHistogramFacetToWriter(monthlyDownloadsFacet);
            }
            else if (requestedReport.equalsIgnoreCase("itemsAdded"))
            {
                response.setStatus(HttpServletResponse.SC_NOT_IMPLEMENTED);
            }
            else if(requestedReport.equalsIgnoreCase("filesAdded"))
            {
                response.setStatus(HttpServletResponse.SC_NOT_IMPLEMENTED);
            }
            else if(requestedReport.equalsIgnoreCase("topDownloads"))
            {
                response.setStatus(HttpServletResponse.SC_NOT_IMPLEMENTED);
            }
            else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
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

    private void addTermFacetToWriter(TermsFacet termsFacet) throws SQLException {
        List<? extends TermsFacet.Entry> termsFacetEntries = termsFacet.getEntries();

        writer.writeNext(new String[]{"term", "count"});
        

        /*
        if(termName.equalsIgnoreCase("bitstream")) {
            facetTableHeaderRow.addCellContent("Title");
            facetTableHeaderRow.addCellContent("Creator");
            facetTableHeaderRow.addCellContent("Publisher");
            facetTableHeaderRow.addCellContent("Date");
        } else {
            facetTableHeaderRow.addCell().addContent(termName);
        }
        */

        if(termsFacetEntries.size() == 0) {
            return;
        }

        
        for(TermsFacet.Entry facetEntry : termsFacetEntries) {

            /*if(termName.equalsIgnoreCase("bitstream")) {
                Bitstream bitstream = Bitstream.find(context, Integer.parseInt(facetEntry.getTerm()));
                Item item = (Item) bitstream.getParentObject();
                row.addCell().addXref(contextPath + "/handle/" + item.getHandle(), item.getName());
                row.addCellContent(getFirstMetadataValue(item, "dc.creator"));
                row.addCellContent(getFirstMetadataValue(item, "dc.publisher"));
                row.addCellContent(getFirstMetadataValue(item, "dc.date.issued"));
            } else if(termName.equalsIgnoreCase("country")) {
                row.addCell("country", Cell.ROLE_DATA,"country").addContent(new Locale("en", facetEntry.getTerm()).getDisplayCountry());
            } else {
                row.addCell().addContent(facetEntry.getTerm());
            }
            row.addCell("count", Cell.ROLE_DATA, "count").addContent(facetEntry.getCount());
            */
            writer.writeNext(new String[]{facetEntry.getTerm(), String.valueOf(facetEntry.getCount())});
            
        }
    }
    
    private void addDateHistogramFacetToWriter(DateHistogramFacet dateHistogramFacet) {
        List<? extends DateHistogramFacet.Entry> monthlyFacetEntries = dateHistogramFacet.getEntries();

        if(monthlyFacetEntries.size() == 0) {
            return;
        }

        writer.writeNext(new String[]{"Month", "Count"});

        for(DateHistogramFacet.Entry histogramEntry : monthlyFacetEntries) {
            Date facetDate = new Date(histogramEntry.getTime());
            writer.writeNext(new String[]{dateFormat.format(facetDate), String.valueOf(histogramEntry.getCount())});
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
