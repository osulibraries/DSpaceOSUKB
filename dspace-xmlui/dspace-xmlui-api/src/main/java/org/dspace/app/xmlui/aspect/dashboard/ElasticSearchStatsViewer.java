package org.dspace.app.xmlui.aspect.dashboard;

import edu.osu.library.dspace.statistics.ElasticSearchLogger;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.aspect.statistics.ReportGenerator;
import org.dspace.app.xmlui.aspect.statistics.StatisticsTransformer;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.content.*;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.Client;
import org.elasticsearch.client.action.search.SearchRequestBuilder;
import org.elasticsearch.index.query.*;
import org.elasticsearch.search.facet.FacetBuilders;
import org.elasticsearch.search.facet.Facets;
import org.elasticsearch.search.facet.datehistogram.DateHistogramFacet;
import org.elasticsearch.search.facet.terms.TermsFacet;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: peterdietz
 * Date: 3/7/12
 * Time: 11:54 AM
 * To change this template use File | Settings | File Templates.
 */
public class ElasticSearchStatsViewer extends AbstractDSpaceTransformer {
    private static Logger log = Logger.getLogger(ElasticSearchStatsViewer.class);

    private static SimpleDateFormat monthAndYearFormat = new SimpleDateFormat("MMMMM yyyy");
    private static SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    private static Client client;
    private static Division division;
    private static DSpaceObject dso;
    private static Date dateStart;
    private static Date dateEnd;

    private static TermFilterBuilder justOriginals = FilterBuilders.termFilter("bundleName", "ORIGINAL");

    private static AbstractFacetBuilder facetTopCountries = FacetBuilders.termsFacet("top_countries").field("country.untouched").size(150)
            .facetFilter(FilterBuilders.andFilter(
                justOriginals,
                FilterBuilders.notFilter(FilterBuilders.termFilter("country.untouched", "")))
            );

    private static AbstractFacetBuilder facetMonthlyDownloads = FacetBuilders.dateHistogramFacet("monthly_downloads").field("time").interval("month")
            .facetFilter(FilterBuilders.andFilter(
                FilterBuilders.termFilter("type", "bitstream"),
                justOriginals
            ));
    
    private static AbstractFacetBuilder facetTopBitstreamsAllTime = FacetBuilders.termsFacet("top_bitstreams_alltime").field("id")
            .facetFilter(FilterBuilders.andFilter(
                    FilterBuilders.termFilter("type", "bitstream"),
                    justOriginals
            ));
    
    private static AbstractFacetBuilder facetTopUSCities = FacetBuilders.termsFacet("top_US_cities").field("city.untouched").size(50)
            .facetFilter(FilterBuilders.andFilter(
                FilterBuilders.termFilter("countryCode", "US"),
                justOriginals,
                FilterBuilders.notFilter(FilterBuilders.termFilter("city.untouched", ""))
            ));
    
    private static AbstractFacetBuilder facetTopUniqueIP = FacetBuilders.termsFacet("top_unique_ips").field("ip");
    
    private static AbstractFacetBuilder facetTopTypes = FacetBuilders.termsFacet("top_types").field("type");

    public void addPageMeta(PageMeta pageMeta) throws WingException {
        pageMeta.addMetadata("title").addContent("Elastic Search Data Display");
    }

    public void addBody(Body body) throws WingException, SQLException {
        client = ElasticSearchLogger.createElasticClient(false);
        try {
            //Try to find our dspace object
            dso = HandleUtil.obtainHandle(objectModel);

            division = body.addDivision("elastic-stats");
            division.setHead("Elastic Data Display");
            division.addPara(dso.getType() + " " + dso.getName());

            division.addHidden("baseURLStats").setValue(contextPath + "/handle/" + dso.getHandle() + "/elasticstatistics");
            Request request = ObjectModelHelper.getRequest(objectModel);
            String[] requestURIElements = request.getRequestURI().split("/");

            // If we are on the homepage of the statistics portal, then we just show the summary report
            // Otherwise we will show a form to let user enter more information for deeper detail.
            if(requestURIElements[requestURIElements.length-1].trim().equalsIgnoreCase("elasticstatistics")) {
                //Homepage will show the last 5 years worth of Data, and no form generator.
                Calendar cal = Calendar.getInstance();
                dateEnd = cal.getTime();
                
                cal.roll(Calendar.YEAR, -5);
                cal.set(Calendar.MONTH, 0);
                dateStart = cal.getTime();

                division.addHidden("reportDepth").setValue("summary");
                division.addPara("Showing Last Five Years of Data");
                showAllReports();
                
            } else {
                //Other pages will show a form to choose which date range.
                ReportGenerator reportGenerator = new ReportGenerator();
                reportGenerator.addReportGeneratorForm(division, request);
                
                dateStart = reportGenerator.getDateStart();
                dateEnd = reportGenerator.getDateEnd();

                String requestedReport = requestURIElements[requestURIElements.length-1];
                log.info("Requested report is: "+ requestedReport);
                division.addHidden("reportDepth").setValue("detail");
                if(dateStart != null && dateEnd != null) {
                    division.addPara("Showing Data from:"+dateFormat.format(dateStart) + " to:"+dateFormat.format(dateEnd));
                } else {
                    division.addPara("Showing Data from: no range limit");
                }
                if(requestedReport.equalsIgnoreCase("topCountries")) {
                    showTopCountries(division, client, dso, dateStart, dateEnd);
                } else if(requestedReport.equalsIgnoreCase("fileDownloads")) {
                    facetedQueryBuilder(facetMonthlyDownloads);
                }
            }

        } finally {
            client.close();
        }
    }
    
    public void showAllReports() throws WingException, SQLException{
        // Show some non-usage-stats.
        // @TODO Refactor the non-usage stats out of the StatsTransformer
        StatisticsTransformer statisticsTransformerInstance = new StatisticsTransformer(dateStart, dateEnd);

        // 1 - Number of Items in The Container (Community/Collection) (monthly and cumulative for the year)
        if(dso instanceof org.dspace.content.Collection || dso instanceof Community) {
            statisticsTransformerInstance.addItemsInContainer(dso, division);
        }

        // 2 - Number of Files in The Container (monthly and cumulative)
        if(dso instanceof org.dspace.content.Collection || dso instanceof Community) {
            statisticsTransformerInstance.addFilesInContainer(dso, division);
        }

        List<AbstractFacetBuilder> summaryFacets = new ArrayList<AbstractFacetBuilder>();
        summaryFacets.add(facetTopTypes);
        summaryFacets.add(facetTopUniqueIP);
        TermQueryBuilder termQuery = QueryBuilders.termQuery(getOwningText(dso), dso.getID());
        summaryFacets.add(facetTopCountries);
        summaryFacets.add(facetTopUSCities);
        summaryFacets.add(facetTopBitstreamsLastMonth());
        summaryFacets.add(facetTopBitstreamsAllTime);
        summaryFacets.add(facetMonthlyDownloads);



    
    public AbstractFacetBuilder facetTopBitstreamsLastMonth() {
        Calendar calendar = Calendar.getInstance();

        // Show Previous Whole Month
        calendar.add(Calendar.MONTH, -1);

        calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMinimum(Calendar.DAY_OF_MONTH));
        String lowerBound = dateFormat.format(calendar.getTime());

        calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
        String upperBound = dateFormat.format(calendar.getTime());

        log.info("Lower:"+lowerBound+" -- Upper:"+upperBound);
        
        return FacetBuilders.termsFacet("top_bitstreams_lastmonth").field("id")
                .facetFilter(FilterBuilders.andFilter(
                        FilterBuilders.termFilter("type", "bitstream"),
                        justOriginals,
                        FilterBuilders.rangeFilter("time").from(lowerBound).to(upperBound)
                ));
    }


        SearchRequestBuilder searchRequestBuilder = client.prepareSearch(ElasticSearchLogger.indexName)
                .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                .setQuery(termQuery)
                .setSize(0)
                .addFacet(FacetBuilders.termsFacet("top_bitstreams_lastmonth").field("id")
                        .facetFilter(FilterBuilders.andFilter(
                                FilterBuilders.termFilter("type", "bitstream"),
                                justOriginals,
                                FilterBuilders.rangeFilter("time").from(lowerBound).to(upperBound)
                        )))

        division.addHidden("request").setValue(searchRequestBuilder.toString());

        SearchResponse resp = searchRequestBuilder.execute().actionGet();

        if(resp == null) {
            log.info("Elastic Search is down for searching.");
            division.addPara("Elastic Search seems to be down :(");
            return;
        }

        //division.addPara(resp.toString());
        division.addHidden("response").setValue(resp.toString());


        division.addPara("Querying bitstreams for elastic, Took " + resp.tookInMillis() + " ms to get " + resp.getHits().totalHits() + " hits.");

        // Number of File Downloads Per Month
        Facets facets = resp.getFacets();
        if(facets == null) {
            log.info("Elastic Search gives no facets");
            return;
        }

        division.addDivision("chart_div");

        //DateHistogramFacet monthlyDownloadsFacet = facets.facet(DateHistogramFacet.class, "monthly_downloads");
        //addDateHistogramToTable(monthlyDownloadsFacet, division, "MonthlyDownloads", "Number of Downloads (per month)");

        // Number of Unique Visitors per Month
        //TermsFacet uniquesFacet = resp.getFacets().facet(TermsFacet.class, "top_unique_ips");
        //addTermFacetToTable(uniquesFacet, division, "Uniques", "Unique Visitors (per year)");

        //TermsFacet countryFacet = resp.getFacets().facet(TermsFacet.class, "top_countries");
        //addTermFacetToTable(countryFacet, division, "Country", "Top Country Views (all time)");

        // Need to cast the facets to a TermsFacet so that we can get things like facet count. I think this is obscure.
        //TermsFacet termsFacet = resp.getFacets().facet(TermsFacet.class, "top_types");
        //addTermFacetToTable(termsFacet, division, "types", "Facetting of Hits to this owningObject by resource type");

        // Top Downloads to Owning Object
        TermsFacet bitstreamsFacet = resp.getFacets().facet(TermsFacet.class, "top_bitstreams_lastmonth");
        addTermFacetToTable(bitstreamsFacet, division, "Bitstream", "Top Downloads for " + monthAndYearFormat.format(calendar.getTime()));

        //TermsFacet bitstreamsAllTimeFacet = resp.getFacets().facet(TermsFacet.class, "top_bitstreams_alltime");
        //addTermFacetToTable(bitstreamsAllTimeFacet, division, "Bitstream", "Top Downloads (all time)");
    }
    
    public SearchResponse facetedQueryBuilder(List<AbstractFacetBuilder> facetList) throws WingException {
        TermQueryBuilder termQuery = QueryBuilders.termQuery(getOwningText(dso), dso.getID());
        FilterBuilder rangeFilter = FilterBuilders.rangeFilter("time").from(dateStart).to(dateEnd);
        FilteredQueryBuilder filteredQueryBuilder = QueryBuilders.filteredQuery(termQuery, rangeFilter);

        SearchRequestBuilder searchRequestBuilder = client.prepareSearch(ElasticSearchLogger.indexName)
                .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                .setQuery(filteredQueryBuilder)
                .setSize(0);

        for(AbstractFacetBuilder facet : facetList) {
            searchRequestBuilder.addFacet(facet);
        }


        division.addHidden("request").setValue(searchRequestBuilder.toString());

        SearchResponse resp = searchRequestBuilder.execute().actionGet();

        if(resp == null) {
            log.info("Elastic Search is down for searching.");
            division.addPara("Elastic Search seems to be down :(");
            return;
        }

        //division.addPara(resp.toString());
        division.addHidden("response").setValue(resp.toString());
        division.addDivision("chart_div");
    }



    private void addTermFacetToTable(TermsFacet termsFacet, Division division, String termName, String tableHeader) throws WingException, SQLException {
        List<? extends TermsFacet.Entry> termsFacetEntries = termsFacet.getEntries();

        if(termsFacetEntries.size() == 0) {
            division.addPara("Empty result set for: "+termName);
            return;
        }

        log.info("Country or "+termName);
        if(termName.equalsIgnoreCase("country")) {
            division.addDivision("chart_div_map");
        }

        Table facetTable = division.addTable("facet-"+termName, termsFacetEntries.size(), 10);
        facetTable.setHead(tableHeader);

        Row facetTableHeaderRow = facetTable.addRow(Row.ROLE_HEADER);
        if(termName.equalsIgnoreCase("bitstream")) {
            facetTableHeaderRow.addCellContent("Title");
            facetTableHeaderRow.addCellContent("Creator");
            facetTableHeaderRow.addCellContent("Publisher");
            facetTableHeaderRow.addCellContent("Date");
        } else {
            facetTableHeaderRow.addCell().addContent(termName);
        }

        facetTableHeaderRow.addCell().addContent("Count");

        for(TermsFacet.Entry facetEntry : termsFacetEntries) {
            Row row = facetTable.addRow();

            if(termName.equalsIgnoreCase("bitstream")) {
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
        }
    }

    private void addDateHistogramToTable(DateHistogramFacet monthlyDownloadsFacet, Division division, String termName, String termDescription) throws WingException {
        List<? extends DateHistogramFacet.Entry> monthlyFacetEntries = monthlyDownloadsFacet.getEntries();

        if(monthlyFacetEntries.size() == 0) {
            division.addPara("Empty result set for: "+termName);
            return;
        }

        Table monthlyTable = division.addTable(termName, monthlyFacetEntries.size(), 10);
        monthlyTable.setHead(termDescription);
        Row tableHeaderRow = monthlyTable.addRow(Row.ROLE_HEADER);
        tableHeaderRow.addCell("date", Cell.ROLE_HEADER,null).addContent("Month/Date");
        tableHeaderRow.addCell("count", Cell.ROLE_HEADER,null).addContent("Count");

        for(DateHistogramFacet.Entry histogramEntry : monthlyFacetEntries) {
            Row dataRow = monthlyTable.addRow();
            Date facetDate = new Date(histogramEntry.getTime());
            dataRow.addCell("date", Cell.ROLE_DATA,"date").addContent(dateFormat.format(facetDate));
            dataRow.addCell("count", Cell.ROLE_DATA,"count").addContent("" + histogramEntry.getCount());
        }
    }
    
    private String getOwningText(DSpaceObject dso) {
        switch (dso.getType()) {
            case Constants.COLLECTION:
                return "owningColl";
            case Constants.COMMUNITY:
                return "owningComm";
            default:
                return "";
        }
    }
    
    private String getFirstMetadataValue(Item item, String metadataKey) {
        DCValue[] dcValue = item.getMetadata(metadataKey);
        if(dcValue.length > 0) {
            return dcValue[0].value;
        } else {
            return "";
        }
    }
}
